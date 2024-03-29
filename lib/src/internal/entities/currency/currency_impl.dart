import 'package:restrr/restrr.dart';
import 'package:restrr/src/internal/entities/restrr_entity_impl.dart';

class CurrencyImpl extends RestrrEntityImpl implements Currency {
  @override
  final String name;
  @override
  final String symbol;
  @override
  final int decimalPlaces;
  @override
  final String? isoCode;

  const CurrencyImpl({
    required super.api,
    required super.id,
    required this.name,
    required this.symbol,
    required this.decimalPlaces,
    required this.isoCode,
  });
}
