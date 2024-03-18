## 0.8
- Added `Account`
  - Added `AccountRoutes`
  - Added `Account#delete`
  - Added `Account#update`
  - Added `Restrr#createAccount`
  - Added `Restrr#retrieveAccountById`
  - Added `Restrr#retrieveAllAccounts`
- Added `Transaction`
  - Added `TransactionRoutes`
  - Added `Transaction#delete`
  - Added `Transaction#update`
  - Added `Restrr#createTransaction`
  - Added `Restrr#retrieveTransactionById`
  - Added `Restrr#retrieveAllTransactions`
- Fixed `Session#delete` using a wrong route
- Implemented actual `RestrrError` error codes
  - Added `ErrorResponse#apiCode` 

## 0.7
- Restructured package (many breaking changes!)
  - Split package into `api` (abstraction) and `internal` (implementation)
- Added `Session`-based authentication
- Reworked `RestrrBuilder` to support new `Session`s
  - Added `RestrrBuilder#refresh`
- Implemented Pagination (see `Paginated<T>`)

## 0.6.2
- Fixed `Restrr#on` (and similar methods)

## 0.6.1
- Fixed `RestrrEventHandler#fire`

## 0.6
- Added `RestrrBuilder#on` & `Restrr#on`
- Added `ReadyEvent` & `RequestEvent`
- Added `RestrrOptions#disableLogging`
- Further improved Logging

## 0.5
- Added `Currency`
- Added `Restrr#retrieveAllCurrencies`
- Added `Restrr#createCurrency`
- Added `Restrr#retrieveCurrencyById`
- Added `Restrr#deleteCurrencyById`
- Added `Restrr#updateCurrencyById`
- Added `Restrr#retrieveSelf`
- Implemented (Batch)CacheViews (some retrieve methods now have a `forceRetrieve` parameter)

## 0.4.2
- Fixed missing `isWeb` in `RestrrBuilder#create`

## 0.4.1
- Added missing `isWeb` in `RequestHandler` methods

## 0.4
- Added `statusCode` to `RestResponse`
- Moved route config to `RouteOptions`
- Removed export of `ApiService`s

## 0.3.3
- Fixed missing options param

## 0.3.2
- Added `RestrrBuilder#refresh`
- Fixed `RestrrOptions` and added `isWeb` attribute
- Removed network check when no CookieJar is set (web)

## 0.3.1 
- Added ability to customize & disable Cookie Jar

## 0.3
- Added `User#displayName`
- Added `Restrr#logout`
- Added `Restrr#register`
- Further refactored error handling
  - Added `errorMap` to `ApiService#request` (and similar methods)
- Added more tests

## 0.2.1
- Removed `ErrorResponse`
- Replaced `RestResponse#error` with `RestrrError?`
- Added `Route#translateDioException`
- Added `IOUtils#checkConnection`

## 0.2
- Added `RestrrBuilder#login`
- More cleanup

## 0.1.1
- Added Dart Action

## 0.1
- Added `Restrr#checkUri`
- Added tests
- Further laid out concrete package structure

## 0.0.1
- Initial commit
- Implemented concrete structure
