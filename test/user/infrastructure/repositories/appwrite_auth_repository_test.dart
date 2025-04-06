import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ndao/core/infrastructure/storage/session_storage.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/infrastructure/repositories/appwrite_auth_repository.dart';

import 'appwrite_auth_repository_test.mocks.dart';

@GenerateMocks([Account, UserRepository, SessionStorage])
void main() {
  late AppwriteAuthRepository repository;
  late MockAccount mockAccount;
  late MockUserRepository mockUserRepository;
  late MockSessionStorage mockSessionStorage;

  setUp(() {
    mockAccount = MockAccount();
    mockUserRepository = MockUserRepository();
    mockSessionStorage = MockSessionStorage();
    repository = AppwriteAuthRepository(
      mockAccount,
      mockUserRepository,
      mockSessionStorage,
    );
  });

  group('AppwriteAuthRepository', () {
    group('signInWithEmailAndPassword', () {
      test('should handle existing session and create a new one', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password';
        const sessionId = 'session123';
        const userId = 'user123';

        // Mock session storage has a session
        when(mockSessionStorage.hasSession()).thenAnswer((_) async => true);
        when(mockSessionStorage.getSessionId())
            .thenAnswer((_) async => sessionId);
        when(mockSessionStorage.getUserId()).thenAnswer((_) async => userId);

        // Mock successful session deletion
        when(mockAccount.deleteSession(sessionId: sessionId))
            .thenAnswer((_) async => {});

        // Mock user repository returns a user with the same email
        final user = UserEntity(
          id: userId,
          givenName: 'Test',
          familyName: 'User',
          email: email,
          phoneNumber: '+1234567890',
          roles: ['client'],
        );
        when(mockUserRepository.getUserById(userId))
            .thenAnswer((_) async => user);

        // Mock successful session creation
        final session = Session(
          $id: 'newSession123',
          $createdAt: '',
          userId: userId,
          expire: '0',
          provider: '',
          providerUid: '',
          providerAccessToken: '',
          providerAccessTokenExpiry: '0',
          providerRefreshToken: '',
          ip: '',
          osCode: '',
          osName: '',
          osVersion: '',
          clientType: '',
          clientCode: '',
          clientName: '',
          clientVersion: '',
          clientEngine: '',
          clientEngineVersion: '',
          deviceName: '',
          deviceBrand: '',
          deviceModel: '',
          countryCode: '',
          countryName: '',
          current: true,
        );
        when(mockAccount.createEmailSession(
          email: email,
          password: password,
        )).thenAnswer((_) async => session);

        // Mock successful session storage
        when(mockSessionStorage.saveSession(session.$id, userId))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email,
          password,
        );

        // Assert
        expect(result, equals(userId));
        verify(mockSessionStorage.hasSession()).called(1);
        verify(mockSessionStorage.getSessionId()).called(1);
        verify(mockAccount.deleteSession(sessionId: sessionId)).called(1);
        verify(mockUserRepository.getUserById(userId)).called(1);
        verify(mockAccount.createEmailSession(
          email: email,
          password: password,
        )).called(1);
        verify(mockSessionStorage.saveSession(session.$id, userId)).called(1);
      });

      test('should handle session conflict error and retry', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password';
        const userId = 'user123';

        // Mock session storage has no session
        when(mockSessionStorage.hasSession()).thenAnswer((_) async => false);

        // First attempt throws a session conflict error
        when(mockAccount.createEmailSession(
          email: email,
          password: password,
        )).thenThrow(AppwriteException(
          'Creation of a session is prohibited when a session is active',
          400,
        ));

        // Mock session storage clear
        when(mockSessionStorage.clearSession()).thenAnswer((_) async => {});

        // Mock list sessions
        final sessionsList = SessionList(
          total: 1,
          sessions: [
            Session(
              $id: 'session123',
              $createdAt: '',
              userId: userId,
              expire: '0',
              provider: '',
              providerUid: '',
              providerAccessToken: '',
              providerAccessTokenExpiry: '0',
              providerRefreshToken: '',
              ip: '',
              osCode: '',
              osName: '',
              osVersion: '',
              clientType: '',
              clientCode: '',
              clientName: '',
              clientVersion: '',
              clientEngine: '',
              clientEngineVersion: '',
              deviceName: '',
              deviceBrand: '',
              deviceModel: '',
              countryCode: '',
              countryName: '',
              current: true,
            ),
          ],
        );
        when(mockAccount.listSessions()).thenAnswer((_) async => sessionsList);

        // Mock delete session
        when(mockAccount.deleteSession(sessionId: 'session123'))
            .thenAnswer((_) async => {});

        // Second attempt succeeds
        final session = Session(
          $id: 'newSession123',
          $createdAt: '',
          userId: userId,
          expire: '0',
          provider: '',
          providerUid: '',
          providerAccessToken: '',
          providerAccessTokenExpiry: '0',
          providerRefreshToken: '',
          ip: '',
          osCode: '',
          osName: '',
          osVersion: '',
          clientType: '',
          clientCode: '',
          clientName: '',
          clientVersion: '',
          clientEngine: '',
          clientEngineVersion: '',
          deviceName: '',
          deviceBrand: '',
          deviceModel: '',
          countryCode: '',
          countryName: '',
          current: true,
        );
        when(mockAccount.createEmailSession(
          email: email,
          password: password,
        )).thenAnswer((_) async => session);

        // Mock successful session storage
        when(mockSessionStorage.saveSession(session.$id, userId))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email,
          password,
        );

        // Assert
        expect(result, equals(userId));
        verify(mockSessionStorage.hasSession()).called(1);
        verify(mockSessionStorage.clearSession()).called(1);
        verify(mockAccount.listSessions()).called(1);
        verify(mockAccount.deleteSession(sessionId: 'session123')).called(1);
        verify(mockAccount.createEmailSession(
          email: email,
          password: password,
        )).called(2); // Called twice due to retry
        verify(mockSessionStorage.saveSession(session.$id, userId)).called(1);
      });
    });

    group('isAuthenticated', () {
      test('should return true when session is valid', () async {
        // Arrange
        const sessionId = 'session123';

        // Mock session storage has a session
        when(mockSessionStorage.hasSession()).thenAnswer((_) async => true);
        when(mockSessionStorage.getSessionId())
            .thenAnswer((_) async => sessionId);

        // Mock successful session verification
        when(mockAccount.getSession(sessionId: sessionId))
            .thenAnswer((_) async => Session(
                  $id: sessionId,
                  $createdAt: '',
                  userId: 'user123',
                  expire: '0',
                  provider: '',
                  providerUid: '',
                  providerAccessToken: '',
                  providerAccessTokenExpiry: '0',
                  providerRefreshToken: '',
                  ip: '',
                  osCode: '',
                  osName: '',
                  osVersion: '',
                  clientType: '',
                  clientCode: '',
                  clientName: '',
                  clientVersion: '',
                  clientEngine: '',
                  clientEngineVersion: '',
                  deviceName: '',
                  deviceBrand: '',
                  deviceModel: '',
                  countryCode: '',
                  countryName: '',
                  current: true,
                ));

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isTrue);
        verify(mockSessionStorage.hasSession()).called(1);
        verify(mockSessionStorage.getSessionId()).called(1);
        verify(mockAccount.getSession(sessionId: sessionId)).called(1);
      });

      test('should return false and clear session when session is invalid',
          () async {
        // Arrange
        const sessionId = 'session123';

        // Mock session storage has a session
        when(mockSessionStorage.hasSession()).thenAnswer((_) async => true);
        when(mockSessionStorage.getSessionId())
            .thenAnswer((_) async => sessionId);

        // Mock session verification fails
        when(mockAccount.getSession(sessionId: sessionId))
            .thenThrow(AppwriteException('Session not found', 404));

        // Mock session storage clear
        when(mockSessionStorage.clearSession()).thenAnswer((_) async => {});

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isFalse);
        verify(mockSessionStorage.hasSession()).called(1);
        verify(mockSessionStorage.getSessionId()).called(1);
        verify(mockAccount.getSession(sessionId: sessionId)).called(1);
        verify(mockSessionStorage.clearSession()).called(1);
      });
    });
  });
}
