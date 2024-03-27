import 'package:restrr/restrr.dart';
import 'package:restrr/src/internal/requests/responses/rest_response.dart';

import 'currency_impl.dart';

class CustomCurrencyImpl extends CurrencyImpl implements CustomCurrency {
  @override
  final int? user;

  const CustomCurrencyImpl({
    required super.api,
    required super.id,
    required super.name,
    required super.symbol,
    required super.isoCode,
    required super.decimalPlaces,
    required this.user,
  });

  @override
  bool isCreatedBy(User user) => this.user == user.id;

  @override
  Future<bool> delete() async {
    final RestResponse<bool> response =
        await api.requestHandler.noResponseApiRequest(route: CurrencyRoutes.deleteById.compile(params: [id]));
    return response.hasData && response.data!;
  }

  @override
  Future<Currency> update({String? name, String? symbol, String? isoCode, int? decimalPlaces}) async {
    if (name == null && symbol == null && isoCode == null && decimalPlaces == null) {
      throw ArgumentError('At least one field must be set');
    }
    final RestResponse<Currency> response = await api.requestHandler.apiRequest(
        route: CurrencyRoutes.patchById.compile(params: [id]),
        mapper: (json) => api.entityBuilder.buildCurrency(json),
        body: {
          if (name != null) 'name': name,
          if (symbol != null) 'symbol': symbol,
          if (isoCode != null) 'iso_code': isoCode,
          if (decimalPlaces != null) 'decimal_places': decimalPlaces,
        });
    if (response.hasError) {
      throw response.error!;
    }
    return response.data!;
  }
}
