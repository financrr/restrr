import 'package:logging/logging.dart';
import 'package:restrr/src/internal/requests/responses/rest_response.dart';

import '../../restrr.dart';

class RestrrOptions {
  final bool isWeb;
  final bool disableLogging;
  const RestrrOptions({this.isWeb = false, this.disableLogging = false});
}

class RouteOptions {
  final Uri hostUri;
  final int apiVersion;
  const RouteOptions({required this.hostUri, this.apiVersion = -1});
}

abstract class Restrr {
  static final Logger log = Logger('Restrr');

  RestrrOptions get options;
  RouteOptions get routeOptions;

  Session get session;

  /// The currently authenticated user.
  User get selfUser => session.user;

  /// Checks whether the specified URI is valid and points to a valid
  /// financrr API.
  static Future<RestResponse<ServerInfo>> checkUri(Uri uri, {bool isWeb = false}) async {
    return await RequestHandler.request(
      route: StatusRoutes.health.compile(),
      mapper: (json) => ServerInfo.fromJson(json),
      routeOptions: RouteOptions(hostUri: uri),
    );
  }

  void on<T extends RestrrEvent>(Type type, void Function(T) func);

  /// Retrieves the currently authenticated user.
  Future<User?> retrieveSelf({bool forceRetrieve = false});

  /// Logs out the current user.
  Future<bool> logout();

  Future<List<Currency>?> retrieveAllCurrencies({bool forceRetrieve = false});

  /* Sessions */

  Future<Session?> retrieveCurrentSession({bool forceRetrieve = false});

  Future<Session?> retrieveSessionById(Id id, {bool forceRetrieve = false});

  Future<bool> deleteSessionById(Id id);

  Future<bool> deleteAllSessions();

  /* Currencies */

  Future<Currency?> createCurrency(
      {required String name, required String symbol, required String isoCode, required int decimalPlaces});

  Future<Currency?> retrieveCurrencyById(Id id, {bool forceRetrieve = false});

  Future<bool> deleteCurrencyById(Id id);

  Future<Currency?> updateCurrencyById(Id id, {String? name, String? symbol, String? isoCode, int? decimalPlaces});
}
