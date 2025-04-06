import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import '../../../mocks/mock_repositories.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginInteractor loginInteractor;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginInteractor = LoginInteractor(mockAuthRepository);
  });

  group('LoginInteractor', () {
    test('should call signInWithEmailAndPassword with correct parameters',
        () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const userId = 'user123';

      when(mockAuthRepository.signInWithEmailAndPassword(email, password))
          .thenAnswer((_) async => userId);

      // Act
      final result = await loginInteractor.execute(email, password);

      // Assert
      verify(mockAuthRepository.signInWithEmailAndPassword(email, password))
          .called(1);
      expect(result, equals(userId));
    });

    test('should throw exception when email is empty', () async {
      // Arrange
      const email = '';
      const password = 'password123';

      // Act & Assert
      expect(() => loginInteractor.execute(email, password),
          throwsA(isA<ArgumentError>()));

      verifyNever(mockAuthRepository.signInWithEmailAndPassword(any, any));
    });

    test('should throw exception when email is invalid', () async {
      // Arrange
      const email = 'invalid-email';
      const password = 'password123';

      // Act & Assert
      expect(() => loginInteractor.execute(email, password),
          throwsA(isA<ArgumentError>()));

      verifyNever(mockAuthRepository.signInWithEmailAndPassword(any, any));
    });

    test('should throw exception when password is empty', () async {
      // Arrange
      const email = 'test@example.com';
      const password = '';

      // Act & Assert
      expect(() => loginInteractor.execute(email, password),
          throwsA(isA<ArgumentError>()));

      verifyNever(mockAuthRepository.signInWithEmailAndPassword(any, any));
    });

    test('should throw exception when password is too short', () async {
      // Arrange
      const email = 'test@example.com';
      const password = '123'; // Too short

      // Act & Assert
      expect(() => loginInteractor.execute(email, password),
          throwsA(isA<ArgumentError>()));

      verifyNever(mockAuthRepository.signInWithEmailAndPassword(any, any));
    });

    test('should propagate repository exceptions', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      when(mockAuthRepository.signInWithEmailAndPassword(email, password))
          .thenThrow(Exception('Authentication failed'));

      // Act & Assert
      expect(() => loginInteractor.execute(email, password),
          throwsA(isA<Exception>()));

      verify(mockAuthRepository.signInWithEmailAndPassword(email, password))
          .called(1);
    });
  });
}
