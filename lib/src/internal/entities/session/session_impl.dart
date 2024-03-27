import 'package:restrr/src/internal/entities/session/partial_session_impl.dart';

import '../../../../restrr.dart';

class SessionImpl extends PartialSessionImpl implements Session {
  @override
  final String token;

  const SessionImpl(
      {required super.api,
      required super.id,
      required super.name,
      required super.createdAt,
      required super.expiresAt,
      required super.user,
      required this.token});
}
