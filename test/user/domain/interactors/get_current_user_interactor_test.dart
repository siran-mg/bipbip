import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';

import 'get_current_user_interactor_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetCurrentUserInteractor interactor;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    interactor = GetCurrentUserInteractor(mockAuthRepository);
  });

  group('GetCurrentUserInteractor', () {
    test('should get current user from repository', () async {
      // Arrange
      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        roles: ['client'],
      );
      
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => user);

      // Act
      final result = await interactor.execute();

      // Assert
      expect(result, equals(user));
      verify(mockAuthRepository.getCurrentUser()).called(1);
    });

    test('should return null when no user is authenticated', () async {
      // Arrange
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      final result = await interactor.execute();

      // Assert
      expect(result, isNull);
      verify(mockAuthRepository.getCurrentUser()).called(1);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      final exception = Exception('Test error');
      when(mockAuthRepository.getCurrentUser()).thenThrow(exception);

      // Act & Assert
      expect(() => interactor.execute(), throwsA(equals(exception)));
      verify(mockAuthRepository.getCurrentUser()).called(1);
    });
  });
}
