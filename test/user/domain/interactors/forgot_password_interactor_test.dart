import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ndao/user/domain/interactors/forgot_password_interactor.dart';
import '../../../mocks/mock_repositories.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late ForgotPasswordInteractor forgotPasswordInteractor;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    forgotPasswordInteractor = ForgotPasswordInteractor(mockAuthRepository);
  });

  group('ForgotPasswordInteractor', () {
    test('should call sendPasswordResetEmail with correct parameters',
        () async {
      // Arrange
      const email = 'test@example.com';

      when(mockAuthRepository.sendPasswordResetEmail(email))
          .thenAnswer((_) async {});

      // Act
      await forgotPasswordInteractor.execute(email);

      // Assert
      verify(mockAuthRepository.sendPasswordResetEmail(email)).called(1);
    });

    test('should throw exception when email is empty', () async {
      // Arrange
      const email = '';

      // Act & Assert
      expect(() => forgotPasswordInteractor.execute(email),
          throwsA(isA<ArgumentError>()));

      verifyNever(mockAuthRepository.sendPasswordResetEmail(any));
    });

    test('should throw exception when email is invalid', () async {
      // Arrange
      const email = 'invalid-email';

      // Act & Assert
      expect(() => forgotPasswordInteractor.execute(email),
          throwsA(isA<ArgumentError>()));

      verifyNever(mockAuthRepository.sendPasswordResetEmail(any));
    });

    test('should propagate repository exceptions', () async {
      // Arrange
      const email = 'test@example.com';

      when(mockAuthRepository.sendPasswordResetEmail(email))
          .thenThrow(Exception('Password reset failed'));

      // Act & Assert
      expect(() => forgotPasswordInteractor.execute(email),
          throwsA(isA<Exception>()));

      verify(mockAuthRepository.sendPasswordResetEmail(email)).called(1);
    });
  });
}
