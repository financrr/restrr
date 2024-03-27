import 'package:restrr/src/api/requests/route.dart';

class StatusRoutes {
  const StatusRoutes._();

  static final Route health = Route.get('/status/health', isVersioned: false);
  static final Route coffee = Route.get('/status/coffee', isVersioned: false);
}

class SessionRoutes {
  const SessionRoutes._();

  static final Route getCurrent = Route.get('/session/current');
  static final Route deleteCurrent = Route.post('/session/current');
  static final Route getById = Route.get('/session/{sessionId}');
  static final Route deleteById = Route.get('/session/{sessionId}');
  static final Route getAll = Route.get('/session');
  static final Route deleteAll = Route.delete('/session');
  static final Route create = Route.post('/session');
  static final Route refresh = Route.patch('/session/refresh');
}

class UserRoutes {
  const UserRoutes._();

  static final Route getSelf = Route.get('/user/@me');
  static final Route create = Route.post('/user/register');
}

class AccountRoutes {
  const AccountRoutes._();

  static final Route getAll = Route.get('/account');
  static final Route getById = Route.get('/account/{accountId}');
  static final Route deleteById = Route.delete('/account/{accountId}');
  static final Route patchById = Route.patch('/account/{accountId}');
  static final Route getTransactions = Route.get('/account/{accountId}/transactions');
  static final Route create = Route.post('/account');
}

class CurrencyRoutes {
  const CurrencyRoutes._();

  static final Route getAll = Route.get('/currency');
  static final Route create = Route.post('/currency');
  static final Route getById = Route.get('/currency/{currencyId}');
  static final Route deleteById = Route.delete('/currency/{currencyId}');
  static final Route patchById = Route.patch('/currency/{currencyId}');
}

class TransactionRoutes {
  const TransactionRoutes._();

  static final Route getAll = Route.get('/transaction');
  static final Route getById = Route.get('/transaction/{transactionId}');
  static final Route deleteById = Route.delete('/transaction/{transactionId}');
  static final Route patchById = Route.patch('/transaction/{transactionId}');
  static final Route create = Route.post('/transaction');
}
