import '../../../api/requests/restrr_errors.dart';

/// Represents a response from a REST request.
/// This can either hold data, [T], or an [ErrorResponse].
class RestResponse<T> {
  final T? data;
  final RestrrError? error;
  final int? statusCode;

  const RestResponse({this.data, this.error, required this.statusCode});

  bool get hasData => data != null;
  bool get hasError => error != null;
  bool get hasStatusCode => statusCode != null;
}
