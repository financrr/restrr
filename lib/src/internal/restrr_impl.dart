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
  late final EntityCacheView<User> userCache = EntityCacheView(this);

  late final PageCacheView<Currency> currencyPageCache = PageCacheView(this);
  late final PageCacheView<PartialSession> sessionPageCache = PageCacheView(this);

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
    currencyCache.clear();
    return response.data!;
  }

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
}
