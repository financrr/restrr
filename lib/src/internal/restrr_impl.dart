import 'package:restrr/src/internal/cache/cache_view.dart';
import 'package:restrr/src/internal/requests/responses/rest_response.dart';
import 'package:restrr/src/internal/utils/request_utils.dart';

import '../../restrr.dart';
import '../api/events/event_handler.dart';
import 'entity_builder.dart';

class RestrrImpl implements Restrr {
  @override
  final RestrrOptions options;
  @override
  final RouteOptions routeOptions;

  late final RestrrEventHandler eventHandler;
  late final RequestHandler requestHandler = RequestHandler(this);
  late final EntityBuilder entityBuilder = EntityBuilder(api: this);

  /* Caches */

  late final EntityCacheView<Currency> currencyCache = EntityCacheView(this);
  late final EntityCacheView<PartialSession> sessionCache = EntityCacheView(this);
  late final EntityCacheView<Account> accountCache = EntityCacheView(this);
  late final EntityCacheView<Transaction> transactionCache = EntityCacheView(this);
  late final EntityCacheView<User> userCache = EntityCacheView(this);

  late final PageCacheView<Currency> currencyPageCache = PageCacheView(this);
  late final PageCacheView<PartialSession> sessionPageCache = PageCacheView(this);
  late final PageCacheView<Account> accountPageCache = PageCacheView(this);
  late final PageCacheView<Transaction> transactionPageCache = PageCacheView(this);

  RestrrImpl({required this.routeOptions, required Map<Type, Function> eventMap, this.options = const RestrrOptions()})
      : eventHandler = RestrrEventHandler(eventMap);

  @override
  late final Session session;

  @override
  User get selfUser => session.user;

  @override
  void on<T extends RestrrEvent>(Type type, void Function(T) func) => eventHandler.on(type, func);

  /* Users */

  @override
  Future<User> retrieveSelf({bool forceRetrieve = false}) async {
    return RequestUtils.getOrRetrieveSingle(
        key: selfUser.id,
        cacheView: userCache,
        compiledRoute: UserRoutes.getSelf.compile(),
        mapper: (json) => entityBuilder.buildUser(json),
        forceRetrieve: forceRetrieve);
  }

  /* Sessions */

  @override
  Future<PartialSession> retrieveCurrentSession({bool forceRetrieve = false}) {
    return RequestUtils.getOrRetrieveSingle(
        key: session.id,
        cacheView: sessionCache,
        compiledRoute: SessionRoutes.getCurrent.compile(),
        mapper: (json) => entityBuilder.buildSession(json),
        forceRetrieve: forceRetrieve);
  }

  @override
  Future<PartialSession> retrieveSessionById(Id id, {bool forceRetrieve = false}) {
    return RequestUtils.getOrRetrieveSingle(
        key: id,
        cacheView: sessionCache,
        compiledRoute: SessionRoutes.getById.compile(params: [id]),
        mapper: (json) => entityBuilder.buildSession(json),
        forceRetrieve: forceRetrieve);
  }

  @override
  Future<Paginated<PartialSession>> retrieveAllSessions({int page = 1, int limit = 25, bool forceRetrieve = false}) {
    return RequestUtils.getOrRetrievePage(
        pageCache: sessionPageCache,
        compiledRoute: SessionRoutes.getAll.compile(),
        page: page,
        limit: limit,
        mapper: (json) => entityBuilder.buildSession(json),
        forceRetrieve: forceRetrieve);
  }

  @override
  Future<bool> deleteCurrentSession() async {
    final RestResponse<bool> response =
        await requestHandler.noResponseApiRequest(route: SessionRoutes.deleteCurrent.compile());
    if (response.hasData && response.data!) {
      eventHandler.fire(SessionDeleteEvent(api: this));
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteAllSessions() async {
    final RestResponse<bool> response =
        await requestHandler.noResponseApiRequest(route: SessionRoutes.deleteAll.compile());
    return response.hasData && response.data!;
  }

  /* Accounts */

  @override
  Future<Account> createAccount(
      {required String name,
      required int originalBalance,
      required Id currency,
      String? description,
      String? iban}) async {
    final RestResponse<Account> response = await requestHandler
        .apiRequest(route: AccountRoutes.create.compile(), mapper: (json) => entityBuilder.buildAccount(json), body: {
      'name': name,
      'original_balance': originalBalance,
      'currency_id': currency,
      if (description != null) 'description': description,
      if (iban != null) 'iban': iban
    });
    if (response.hasError) {
      throw response.error!;
    }
    return accountCache.cache(response.data!);
  }

  @override
  List<Account> getAccounts() => accountCache.getAll();

  @override
  Future<Account> retrieveAccountById(Id id, {bool forceRetrieve = false}) async {
    return RequestUtils.getOrRetrieveSingle(
        key: id,
        cacheView: accountCache,
        compiledRoute: AccountRoutes.getById.compile(params: [id]),
        mapper: (json) => entityBuilder.buildAccount(json),
        forceRetrieve: forceRetrieve);
  }

  @override
  Future<Paginated<Account>> retrieveAllAccounts({int page = 1, int limit = 25, bool forceRetrieve = false}) async {
    return RequestUtils.getOrRetrievePage(
        pageCache: accountPageCache,
        compiledRoute: AccountRoutes.getAll.compile(),
        page: page,
        limit: limit,
        mapper: (json) => entityBuilder.buildAccount(json),
        forceRetrieve: forceRetrieve);
  }

  /* Currencies */

  @override
  Future<Currency> createCurrency(
      {required String name, required String symbol, required int decimalPlaces, String? isoCode}) async {
    final RestResponse<Currency> response = await requestHandler.apiRequest(
        route: CurrencyRoutes.create.compile(),
        mapper: (json) => entityBuilder.buildCurrency(json),
        body: {
          'name': name,
          'symbol': symbol,
          'decimal_places': decimalPlaces,
          if (isoCode != null) 'iso_code': isoCode
        });
    if (response.hasError) {
      throw response.error!;
    }
    // invalidate cache
    return currencyCache.cache(response.data!);
  }

  @override
  List<Currency> getCurrencies() => currencyCache.getAll();

  @override
  Future<Currency> retrieveCurrencyById(Id id, {bool forceRetrieve = false}) async {
    return RequestUtils.getOrRetrieveSingle(
        key: id,
        cacheView: currencyCache,
        compiledRoute: CurrencyRoutes.getById.compile(params: [id]),
        mapper: (json) => entityBuilder.buildCurrency(json),
        forceRetrieve: forceRetrieve);
  }

  @override
  Future<Paginated<Currency>> retrieveAllCurrencies({int page = 1, int limit = 25, bool forceRetrieve = false}) async {
    return RequestUtils.getOrRetrievePage(
        pageCache: currencyPageCache,
        compiledRoute: CurrencyRoutes.getAll.compile(),
        page: page,
        limit: limit,
        mapper: (json) => entityBuilder.buildCurrency(json),
        forceRetrieve: forceRetrieve);
  }

  /* Transactions */

  @override
  Future<Transaction> createTransaction(
      {required int amount,
      required Id currencyId,
      required DateTime executedAt,
      String? description,
      Id? sourceId,
      Id? destinationId,
      Id? budgetId}) async {
    if (sourceId == null && destinationId == null) {
      throw ArgumentError('Either source or destination must be set!');
    }
    final RestResponse<Transaction> response = await requestHandler.apiRequest(
        route: TransactionRoutes.create.compile(),
        mapper: (json) => entityBuilder.buildTransaction(json),
        body: {
          'amount': amount,
          'currency_id': currencyId,
          'executed_at': executedAt.toUtc().toIso8601String(),
          if (description != null) 'description': description,
          if (sourceId != null) 'source_id': sourceId,
          if (destinationId != null) 'destination_id': destinationId,
          if (budgetId != null) 'budget_id': budgetId
        });
    if (response.hasError) {
      throw response.error!;
    }
    // invalidate cache
    transactionCache.clear();
    return response.data!;
  }

  @override
  Future<Transaction> retrieveTransactionById(Id id, {bool forceRetrieve = false}) async {
    return RequestUtils.getOrRetrieveSingle(
        key: id,
        cacheView: transactionCache,
        compiledRoute: TransactionRoutes.getById.compile(params: [id]),
        mapper: (json) => entityBuilder.buildTransaction(json),
        forceRetrieve: forceRetrieve);
  }

  @override
  Future<Paginated<Transaction>> retrieveAllTransactions(
      {int page = 1, int limit = 25, bool forceRetrieve = false}) async {
    return RequestUtils.getOrRetrievePage(
        pageCache: transactionPageCache,
        compiledRoute: TransactionRoutes.getAll.compile(),
        page: page,
        limit: limit,
        mapper: (json) => entityBuilder.buildTransaction(json),
        forceRetrieve: forceRetrieve);
  }
}
