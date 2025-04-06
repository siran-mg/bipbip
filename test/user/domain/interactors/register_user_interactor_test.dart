import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/domain/interactors/vehicle_interactor.dart';
import '../../../mocks/mock_repositories.mocks.dart';

// Mock VehicleInteractor
class MockVehicleInteractor extends Mock implements VehicleInteractor {
  @override
  Future<VehicleEntity> createVehicle({
    required String driverId,
    required String licensePlate,
    required String brand,
    required String model,
    required String type,
    bool isPrimary = true,
    File? photo,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #createVehicle,
        [],
        {
          #driverId: driverId,
          #licensePlate: licensePlate,
          #brand: brand,
          #model: model,
          #type: type,
          #isPrimary: isPrimary,
          #photo: photo,
        },
      ),
      returnValue: Future.value(VehicleEntity(
        id: 'mock-vehicle-id',
        licensePlate: licensePlate,
        brand: brand,
        model: model,
        type: type,
        isPrimary: isPrimary,
      )),
    ) as Future<VehicleEntity>;
  }
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockVehicleInteractor mockVehicleInteractor;
  late RegisterUserInteractor registerUserInteractor;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    mockVehicleInteractor = MockVehicleInteractor();
    registerUserInteractor = RegisterUserInteractor(
      mockAuthRepository,
      mockUserRepository,
      mockVehicleInteractor,
    );
  });

  group('RegisterUserInteractor - Client Registration', () {
    test('should register a client successfully', () async {
      // Arrange
      const givenName = 'John';
      const familyName = 'Doe';
      const email = 'john.doe@example.com';
      const phoneNumber = '+1234567890';
      const password = 'password123';
      const userId = 'user123';

      final user = UserEntity(
        id: userId,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: phoneNumber,
        roles: ['client'],
      );

      when(mockAuthRepository.signUpWithEmailAndPassword(
              givenName, familyName, email, phoneNumber, password))
          .thenAnswer((_) async => userId);

      when(mockUserRepository.getUserById(userId))
          .thenAnswer((_) async => user);

      // Act
      final result = await registerUserInteractor.registerClient(
        givenName,
        familyName,
        email,
        phoneNumber,
        password,
      );

      // Assert
      verify(mockAuthRepository.signUpWithEmailAndPassword(
              givenName, familyName, email, phoneNumber, password))
          .called(1);
      verify(mockUserRepository.getUserById(userId)).called(1);
      expect(result, equals(userId));
    });

    test('should throw exception when client registration fails', () async {
      // Arrange
      const givenName = 'John';
      const familyName = 'Doe';
      const email = 'john.doe@example.com';
      const phoneNumber = '+1234567890';
      const password = 'password123';

      when(mockAuthRepository.signUpWithEmailAndPassword(
              givenName, familyName, email, phoneNumber, password))
          .thenThrow(Exception('Registration failed'));

      // Act & Assert
      expect(
          () => registerUserInteractor.registerClient(
                givenName,
                familyName,
                email,
                phoneNumber,
                password,
              ),
          throwsA(isA<Exception>()));

      verify(mockAuthRepository.signUpWithEmailAndPassword(
              givenName, familyName, email, phoneNumber, password))
          .called(1);
      verifyNever(mockUserRepository.getUserById(any));
    });

    test('should throw exception when user is not created properly', () async {
      // Arrange
      const givenName = 'John';
      const familyName = 'Doe';
      const email = 'john.doe@example.com';
      const phoneNumber = '+1234567890';
      const password = 'password123';
      const userId = 'user123';

      when(mockAuthRepository.signUpWithEmailAndPassword(
              givenName, familyName, email, phoneNumber, password))
          .thenAnswer((_) async => userId);

      when(mockUserRepository.getUserById(userId))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
          () => registerUserInteractor.registerClient(
                givenName,
                familyName,
                email,
                phoneNumber,
                password,
              ),
          throwsA(isA<Exception>()));

      verify(mockAuthRepository.signUpWithEmailAndPassword(
              givenName, familyName, email, phoneNumber, password))
          .called(1);
    });
  });

  group('RegisterUserInteractor - Driver Registration', () {
    test('should register a driver successfully', () async {
      // Arrange
      const givenName = 'John';
      const familyName = 'Doe';
      const email = 'john.doe@example.com';
      const phoneNumber = '+1234567890';
      const password = 'password123';
      const userId = 'user123';
      const licensePlate = 'ABC123';
      const vehicleBrand = 'Toyota';
      const vehicleModel = 'Corolla';
      const vehicleType = 'car';

      final user = UserEntity(
        id: userId,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: phoneNumber,
        roles: ['driver'],
      );

      when(mockAuthRepository.signUpDriverWithEmailAndPassword(
              givenName, familyName, email, phoneNumber, password))
          .thenAnswer((_) async => userId);

      when(mockUserRepository.getUserById(userId))
          .thenAnswer((_) async => user);

      final mockVehicle = VehicleEntity(
        id: 'vehicle123',
        licensePlate: licensePlate,
        brand: vehicleBrand,
        model: vehicleModel,
        type: vehicleType,
        isPrimary: true,
      );

      when(mockVehicleInteractor.createVehicle(
        driverId: userId,
        licensePlate: licensePlate,
        brand: vehicleBrand,
        model: vehicleModel,
        type: vehicleType,
        isPrimary: true,
        photo: null,
      )).thenAnswer((_) async => mockVehicle);

      // Act
      final result = await registerUserInteractor.registerDriver(
        givenName,
        familyName,
        email,
        phoneNumber,
        password,
        licensePlate,
        vehicleModel,
        vehicleBrand,
        vehicleType,
        null, // profilePhoto
        null, // vehiclePhoto
      );

      // Assert
      verify(mockAuthRepository.signUpDriverWithEmailAndPassword(
              givenName, familyName, email, phoneNumber, password))
          .called(1);
      verify(mockUserRepository.getUserById(userId)).called(1);
      verify(mockVehicleInteractor.createVehicle(
        driverId: userId,
        licensePlate: licensePlate,
        brand: vehicleBrand,
        model: vehicleModel,
        type: vehicleType,
        isPrimary: true,
        photo: null,
      )).called(1);
      expect(result, equals(userId));
    });

    test('should throw exception when driver registration fails', () async {
      // Arrange
      const givenName = 'John';
      const familyName = 'Doe';
      const email = 'john.doe@example.com';
      const phoneNumber = '+1234567890';
      const password = 'password123';
      const licensePlate = 'ABC123';
      const vehicleBrand = 'Toyota';
      const vehicleModel = 'Corolla';
      const vehicleType = 'car';

      when(mockAuthRepository.signUpDriverWithEmailAndPassword(
              any, any, any, any, any))
          .thenThrow(Exception('Registration failed'));

      // Act & Assert
      expect(
          () => registerUserInteractor.registerDriver(
                givenName,
                familyName,
                email,
                phoneNumber,
                password,
                licensePlate,
                vehicleModel,
                vehicleBrand,
                vehicleType,
                null, // profilePhoto
                null, // vehiclePhoto
              ),
          throwsA(isA<Exception>()));

      verify(mockAuthRepository.signUpDriverWithEmailAndPassword(
              givenName, familyName, email, phoneNumber, password))
          .called(1);
      verifyNever(mockUserRepository.getUserById(any));
      // Vehicle creation should not be called
    });
  });
}
