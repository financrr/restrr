import 'package:restrr/src/internal/entities/restrr_entity_impl.dart';

import '../../../restrr.dart';
import '../requests/responses/rest_response.dart';

class TransactionImpl extends RestrrEntityImpl implements Transaction {
  @override
  final int? sourceId;
  @override
  final int? destinationId;
  @override
  final int amount;
  @override
  final Id currencyId;
  @override
  final String? description;
  @override
  final Id? budgetId;
  @override
  final DateTime createdAt;
  @override
  final DateTime executedAt;

  const TransactionImpl({
    required super.api,
    required super.id,
    required this.sourceId,
    required this.destinationId,
    required this.amount,
    required this.currencyId,
    required this.description,
    required this.budgetId,
    required this.createdAt,
    required this.executedAt,
  }) : assert(sourceId != null || destinationId != null);

  @override
  TransactionType get type {
    if (sourceId != null && destinationId != null) {
      return TransactionType.transfer;
    }
    if (sourceId != null) {
      return TransactionType.withdrawal;
    }
    return TransactionType.deposit;
  }

  @override
  Future<bool> delete() async {
    final RestResponse<bool> response =
        await api.requestHandler.noResponseApiRequest(route: TransactionRoutes.deleteById.compile(params: [id]));
    return response.hasData && response.data!;
  }

  @override
  Future<Transaction> update(
      {int? sourceId,
      int? destinationId,
      int? amount,
      int? currencyId,
      String? description,
      Id? budgetId,
      DateTime? executedAt}) async {
    if (sourceId == null &&
        destinationId == null &&
        amount == null &&
        currencyId == null &&
        description == null &&
        budgetId == null &&
        executedAt == null) {
      throw ArgumentError('At least one field must be set');
    }
    final RestResponse<Transaction> response = await api.requestHandler.apiRequest(
        route: TransactionRoutes.patchById.compile(params: [id]),
        mapper: (json) => api.entityBuilder.buildTransaction(json),
        body: {
          if (sourceId != null) 'source_id': sourceId,
          if (destinationId != null) 'destination_id': destinationId,
          if (amount != null) 'amount': amount,
          if (currencyId != null) 'currency': currencyId,
          if (description != null) 'description': description,
          if (budgetId != null) 'budget_id': budgetId,
          if (executedAt != null) 'executed_at': executedAt.toUtc().toIso8601String(),
        });
    return response.data!;
  }

  @override
  Account? getSourceAccount() => sourceId == null ? null : api.accountCache.get(sourceId!);

  @override
  Future<Account>? retrieveSourceAccount({bool forceRetrieve = false}) {
    if (sourceId == null) {
      return null;
    }
    return api.retrieveAccountById(sourceId!, forceRetrieve: forceRetrieve);
  }

  @override
  Account? getDestinationAccount() => destinationId == null ? null : api.accountCache.get(destinationId!);

  @override
  Future<Account>? retrieveDestinationAccount({bool forceRetrieve = false}) {
    if (destinationId == null) {
      return null;
    }
    return api.retrieveAccountById(destinationId!, forceRetrieve: forceRetrieve);
  }
}
