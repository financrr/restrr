import 'package:restrr/src/internal/entities/restrr_entity_impl.dart';

import '../../../restrr.dart';
import '../requests/responses/rest_response.dart';

class AccountImpl extends RestrrEntityImpl implements Account {
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? iban;
  @override
  final int balance;
  @override
  final int originalBalance;
  @override
  final Id currency;
  @override
  final DateTime createdAt;

  const AccountImpl({
    required super.api,
    required super.id,
    required this.name,
    required this.description,
    required this.iban,
    required this.balance,
    required this.originalBalance,
    required this.currency,
    required this.createdAt,
  });

  @override
  Future<bool> delete() async {
    final RestResponse<bool> response =
        await api.requestHandler.noResponseApiRequest(route: AccountRoutes.deleteById.compile(params: [id]));
    return response.hasData && response.data!;
  }

  @override
  Future<Account> update(
      {String? name, String? description, String? iban, int? originalBalance, Id? currency}) async {
    if (name == null &&
        description == null &&
        iban == null &&
        originalBalance == null &&
        currency == null) {
      throw ArgumentError('At least one field must be set');
    }
    final RestResponse<Account> response = await api.requestHandler.apiRequest(
        route: AccountRoutes.patchById.compile(params: [id]),
        mapper: (json) => api.entityBuilder.buildAccount(json),
        body: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (iban != null) 'iban': iban,
          if (originalBalance != null) 'original_balance': originalBalance,
          if (currency != null) 'currency': currency,
        });
    if (response.hasError) {
      throw response.error!;
    }
    return response.data!;
  }
}
