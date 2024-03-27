import 'package:restrr/restrr.dart';

abstract class Transaction extends RestrrEntity {
  int? get sourceId;
  int? get destinationId;
  int get amount;
  Id get currencyId;
  String? get description;
  Id? get budgetId;
  DateTime get createdAt;
  DateTime get executedAt;

  TransactionType get type;

  Future<bool> delete();

  Future<Transaction> update({
    int? sourceId,
    int? destinationId,
    int? amount,
    Id? currencyId,
    String? description,
    Id? budgetId,
    DateTime? executedAt,
  });

  Account? getSourceAccount();

  Future<Account>? retrieveSourceAccount({bool forceRetrieve = false});

  Account? getDestinationAccount();

  Future<Account>? retrieveDestinationAccount({bool forceRetrieve = false});
}
