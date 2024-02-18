import 'dart:convert';

import 'package:restrr/restrr.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

const String healthJson = '''
{
  "healthy": true,
  "api_version": 1,
  "details": null
}
''';

const String userJson = '''
{
  "id": 1,
  "username": "admin",
  "email": null,
  "created_at": "+002024-02-17T20:48:43.391176000Z",
  "is_admin": true
}
''';

void main() {
  group('[EntityBuilder] ', () {
    test('.buildHealthResponse', () {
      final HealthResponse healthResponse = EntityBuilder.buildHealthResponse(jsonDecode(healthJson));
      expect(healthResponse.healthy, true);
      expect(healthResponse.apiVersion, 1);
      expect(healthResponse.details, null);
    });

    test('.buildUser', () {
      final User user = EntityBuilder.buildUser(jsonDecode(userJson));
      expect(user.id, 1);
      expect(user.username, 'admin');
      expect(user.email, null);
      expect(user.createdAt, DateTime.parse('+002024-02-17T20:48:43.391176000Z'));
      expect(user.isAdmin, true);
    });
  });
}