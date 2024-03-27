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
  static Future<ServerInfo> checkUri(Uri uri, {bool isWeb = false}) async {
    final RestResponse<ServerInfo> response = await RequestHandler.request(
      route: StatusRoutes.health.compile(),
      mapper: (json) => ServerInfo.fromJson(json),
      routeOptions: RouteOptions(hostUri: uri),
    );
    if (response.hasError) {
      throw response.error!;
    }
    return response.data!;
  }

  void on<T extends RestrrEvent>(Type type, void Function(T) func);

  /* Users */

  /// Retrieves the currently authenticated user.
  Future<User> retrieveSelf({bool forceRetrieve = false});

  /* Sessions */

  Future<PartialSession> retrieveCurrentSession({bool forceRetrieve = false});

  Future<PartialSession> retrieveSessionById(Id id, {bool forceRetrieve = false});

  Future<Paginated<PartialSession>> retrieveAllSessions({int page = 1, int limit = 25, bool forceRetrieve = false});

  /// Deletes the current session, effectively logging out the user.
  Future<bool> deleteCurrentSession();

  Future<bool> deleteAllSessions();

  /* Accounts */

  Future<Account> createAccount(
      {required String name, required int originalBalance, required Id currency, String? description, String? iban});

  List<Account> getAccounts();

  Future<Account> retrieveAccountById(Id id, {bool forceRetrieve = false});

  Future<Paginated<Account>> retrieveAllAccounts({int page = 1, int limit = 25, bool forceRetrieve = false});

  /* Currencies */

  Future<Currency> createCurrency(
      {required String name, required String symbol, required int decimalPlaces, String? isoCode});

  List<Currency> getCurrencies();

  Future<Currency> retrieveCurrencyById(Id id, {bool forceRetrieve = false});

  Future<Paginated<Currency>> retrieveAllCurrencies({int page = 1, int limit = 25, bool forceRetrieve = false});

  /* Transactions */

  Future<Transaction> createTransaction(
      {required int amount,
      required Id currencyId,
      required DateTime executedAt,
      String? description,
      Id? sourceId,
      Id? destinationId,
      Id? budgetId});

  Future<Transaction> retrieveTransactionById(Id id, {bool forceRetrieve = false});

  Future<Paginated<Transaction>> retrieveAllTransactions({int page = 1, int limit = 25, bool forceRetrieve = false});
}
