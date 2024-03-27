import '../../../restrr.dart';

abstract class Account extends RestrrEntity {
  String get name;
  String? get description;
  String? get iban;
  int get balance;
  int get originalBalance;
  Id get currencyId;
  DateTime get createdAt;

  Future<bool> delete();

  Future<Account> update({String? name, String? description, String? iban, int? originalBalance, Id? currencyId});

  Future<Paginated<Transaction>> retrieveAllTransactions({int page = 1, int limit = 25, bool forceRetrieve = false});

  Currency? getCurrency();

  Future<Currency> retrieveCurrency({bool forceRetrieve = false});
}
