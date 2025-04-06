import 'package:flutter_test/flutter_test.dart';
import 'package:ndao/core/infrastructure/storage/session_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SessionStorage sessionStorage;

  setUp(() {
    // Set up a mock for SharedPreferences
    SharedPreferences.setMockInitialValues({});
    sessionStorage = SessionStorage();
  });

  group('SessionStorage', () {
    test('should save and retrieve session data', () async {
      // Arrange
      const sessionId = 'test_session_id';
      const userId = 'test_user_id';

      // Act
      await sessionStorage.saveSession(sessionId, userId);
      final retrievedSessionId = await sessionStorage.getSessionId();
      final retrievedUserId = await sessionStorage.getUserId();

      // Assert
      expect(retrievedSessionId, equals(sessionId));
      expect(retrievedUserId, equals(userId));
    });

    test('should clear session data', () async {
      // Arrange
      const sessionId = 'test_session_id';
      const userId = 'test_user_id';
      await sessionStorage.saveSession(sessionId, userId);

      // Act
      await sessionStorage.clearSession();
      final retrievedSessionId = await sessionStorage.getSessionId();
      final retrievedUserId = await sessionStorage.getUserId();

      // Assert
      expect(retrievedSessionId, isNull);
      expect(retrievedUserId, isNull);
    });

    test('should check if session exists', () async {
      // Arrange
      const sessionId = 'test_session_id';
      const userId = 'test_user_id';

      // Act & Assert - No session initially
      expect(await sessionStorage.hasSession(), isFalse);

      // Act & Assert - After saving session
      await sessionStorage.saveSession(sessionId, userId);
      expect(await sessionStorage.hasSession(), isTrue);

      // Act & Assert - After clearing session
      await sessionStorage.clearSession();
      expect(await sessionStorage.hasSession(), isFalse);
    });
  });
}
