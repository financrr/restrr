import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:restrr/restrr.dart';

import '../requests/route.dart';

/// Utility class for handling requests.
class RequestHandler {
  const RequestHandler._();

  /// Tries to execute a request, using the [CompiledRoute] and maps the received data using the
  /// specified [mapper] function, ultimately returning the entity in an [RestResponse].
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<T>> request<T>(
      {required CompiledRoute route,
      required T Function(dynamic) mapper,
      required RouteOptions routeOptions,
      bool isWeb = false,
      String? bearerToken,
      Map<int, RestrrError> errorMap = const {},
      dynamic body,
      String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response = await route.submit(
          routeOptions: routeOptions, body: body, isWeb: isWeb, bearerToken: bearerToken, contentType: contentType);
      return RestResponse(data: mapper.call(response.data), statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleDioException(e, isWeb, errorMap);
    }
  }

  /// Tries to execute a request, using the [CompiledRoute], without expecting any response.
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<bool>> noResponseRequest<T>(
      {required CompiledRoute route,
      required RouteOptions routeOptions,
      bool isWeb = false,
      String? bearerToken,
      dynamic body,
      Map<int, RestrrError> errorMap = const {},
      String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response = await route.submit(
          routeOptions: routeOptions, body: body, isWeb: isWeb, bearerToken: bearerToken, contentType: contentType);
      return RestResponse(data: true, statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleDioException(e, isWeb, errorMap);
    }
  }

  /// Tries to execute a request, using the [CompiledRoute] and maps the received list of data using the
  /// specified [mapper] function, ultimately returning the list of entities in an [RestResponse].
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<List<T>>> multiRequest<T>(
      {required CompiledRoute route,
      required RouteOptions routeOptions,
      bool isWeb = false,
      String? bearerToken,
      required T Function(dynamic) mapper,
      Map<int, RestrrError> errorMap = const {},
      Function(String)? fullRequest,
      dynamic body,
      String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response = await route.submit(
          routeOptions: routeOptions, body: body, isWeb: isWeb, bearerToken: bearerToken, contentType: contentType);
      if (response.data is! List<dynamic>) {
        throw StateError('Received response is not a list!');
      }
      fullRequest?.call(response.data.toString());
      return RestResponse(
          data: (response.data as List<dynamic>).map((single) => mapper.call(single)).toList(),
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleDioException(e, isWeb, errorMap);
    }
  }

  static Future<RestResponse<T>> _handleDioException<T>(
      DioException ex, bool isWeb, Map<int, RestrrError> errorMap) async {
    // check internet connection
    if (!isWeb && !await IOUtils.checkConnection()) {
      return RestrrError.noInternetConnection.toRestResponse();
    }
    // check status code
    final int? statusCode = ex.response?.statusCode;
    if (statusCode != null) {
      if (errorMap.containsKey(statusCode)) {
        return errorMap[statusCode]!.toRestResponse(statusCode: statusCode);
      }
      final RestrrError? err = switch (statusCode) {
        400 => RestrrError.badRequest,
        500 => RestrrError.internalServerError,
        503 => RestrrError.serviceUnavailable,
        _ => null
      };
      if (err != null) {
        return err.toRestResponse(statusCode: statusCode);
      }
    }
    // check timeout
    if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout) {
      return RestrrError.serverUnreachable.toRestResponse(statusCode: statusCode);
    }
    Restrr.log.warning('Unknown error occurred: ${ex.message}, ${ex.stackTrace}');
    return RestrrError.unknown.toRestResponse(statusCode: statusCode);
  }
}

/// A service that provides methods to interact with the API.
abstract class ApiService {
  final Restrr api;

  const ApiService({required this.api});

  Future<RestResponse<T>> request<T>(
      {required CompiledRoute route,
      required T Function(dynamic) mapper,
      String? customBearerToken,
      bool noAuth = false,
      Map<int, RestrrError> errorMap = const {},
      dynamic body,
      String contentType = 'application/json'}) async {
    return RequestHandler.request(
            route: route,
            routeOptions: api.routeOptions,
            isWeb: api.options.isWeb,
            bearerToken: customBearerToken ?? (noAuth ? null : api.session.token),
            mapper: mapper,
            errorMap: errorMap,
            body: body,
            contentType: contentType)
        .then((response) => _fireEvent(route, response));
  }

  Future<RestResponse<bool>> noResponseRequest<T>(
      {required CompiledRoute route,
      String? customBearerToken,
      bool noAuth = false,
      dynamic body,
      Map<int, RestrrError> errorMap = const {},
      String contentType = 'application/json'}) async {
    return RequestHandler.noResponseRequest(
            route: route,
            routeOptions: api.routeOptions,
            isWeb: api.options.isWeb,
            bearerToken: customBearerToken ?? (noAuth ? null : api.session.token),
            body: body,
            errorMap: errorMap,
            contentType: contentType)
        .then((response) => _fireEvent(route, response));
  }

  Future<RestResponse<List<T>>> multiRequest<T>(
      {required CompiledRoute route,
      required T Function(dynamic) mapper,
      String? customBearerToken,
      bool noAuth = false,
      Map<int, RestrrError> errorMap = const {},
      Function(String)? fullRequest,
      dynamic body,
      String contentType = 'application/json'}) async {
    return RequestHandler.multiRequest(
            route: route,
            routeOptions: api.routeOptions,
            isWeb: api.options.isWeb,
            bearerToken: customBearerToken ?? (noAuth ? null : api.session.token),
            mapper: mapper,
            errorMap: errorMap,
            fullRequest: fullRequest,
            body: body,
            contentType: contentType)
        .then((response) => _fireEvent(route, response));
  }

  Future<RestResponse<T>> _fireEvent<T>(CompiledRoute route, RestResponse<T> response) async {
    if (!api.options.disableLogging) {
      Restrr.log.log(
          response.statusCode != null && response.statusCode! >= 400 ? Level.WARNING : Level.INFO,
          '[${DateTime.now().toIso8601String()}] ${route.baseRoute.method} '
          '${api.routeOptions.hostUri}${route.baseRoute.isVersioned ? '/api/v${api.routeOptions.apiVersion}' : ''}'
          '${route.compiledRoute} => ${response.statusCode} (${response.hasData ? 'OK' : response.error?.name})');
    }
    api.eventHandler.fire(RequestEvent(api: api, route: route.compiledRoute, statusCode: response.statusCode));
    return response;
  }
}
