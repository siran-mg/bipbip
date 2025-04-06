import 'package:flutter_test/flutter_test.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';

void main() {
  group('UserEntity', () {
    test('should create a user with required fields', () {
      // Arrange
      const id = 'user123';
      const givenName = 'John';
      const familyName = 'Doe';
      const email = 'john.doe@example.com';
      const phoneNumber = '+1234567890';
      final roles = ['client'];

      // Act
      final user = UserEntity(
        id: id,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: phoneNumber,
        roles: roles,
      );

      // Assert
      expect(user.id, equals(id));
      expect(user.givenName, equals(givenName));
      expect(user.familyName, equals(familyName));
      expect(user.email, equals(email));
      expect(user.phoneNumber, equals(phoneNumber));
      expect(user.roles, equals(roles));
      expect(user.isClient, isTrue);
      expect(user.isDriver, isFalse);
      expect(user.driverDetails, isNull);
      expect(user.clientDetails, isNull);
      expect(user.profilePictureUrl, isNull);
    });

    test('should create a user with all fields', () {
      // Arrange
      const id = 'user123';
      const givenName = 'John';
      const familyName = 'Doe';
      const email = 'john.doe@example.com';
      const phoneNumber = '+1234567890';
      const profilePictureUrl = 'https://example.com/profile.jpg';
      final roles = ['client', 'driver'];
      final driverDetails = DriverDetails(
        isAvailable: true,
        currentLatitude: 37.7749,
        currentLongitude: -122.4194,
        rating: 4.5,
        vehicles: [
          VehicleEntity(
            id: 'vehicle123',
            licensePlate: 'ABC123',
            brand: 'Toyota',
            model: 'Corolla',
            type: 'car',
            isPrimary: true,
          ),
        ],
      );
      final clientDetails = ClientDetails(rating: 4.8);

      // Act
      final user = UserEntity(
        id: id,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: phoneNumber,
        profilePictureUrl: profilePictureUrl,
        roles: roles,
        driverDetails: driverDetails,
        clientDetails: clientDetails,
      );

      // Assert
      expect(user.id, equals(id));
      expect(user.givenName, equals(givenName));
      expect(user.familyName, equals(familyName));
      expect(user.email, equals(email));
      expect(user.phoneNumber, equals(phoneNumber));
      expect(user.profilePictureUrl, equals(profilePictureUrl));
      expect(user.roles, equals(roles));
      expect(user.isClient, isTrue);
      expect(user.isDriver, isTrue);
      expect(user.driverDetails, equals(driverDetails));
      expect(user.clientDetails, equals(clientDetails));
    });

    test('should return full name correctly', () {
      // Arrange
      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        roles: ['client'],
      );

      // Act & Assert
      expect(user.fullName, equals('John Doe'));
    });

    test('should copy with new values', () {
      // Arrange
      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        roles: ['client'],
      );

      // Act
      final updatedUser = user.copyWith(
        givenName: 'Jane',
        familyName: 'Smith',
        email: 'jane.smith@example.com',
      );

      // Assert
      expect(updatedUser.id, equals('user123'));
      expect(updatedUser.givenName, equals('Jane'));
      expect(updatedUser.familyName, equals('Smith'));
      expect(updatedUser.email, equals('jane.smith@example.com'));
      expect(updatedUser.phoneNumber, equals('+1234567890'));
      expect(updatedUser.roles, equals(['client']));
    });

    test('should add role correctly', () {
      // Arrange
      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        roles: ['client'],
      );

      // Act
      final updatedUser = user.addRole('driver');

      // Assert
      expect(updatedUser.roles, containsAll(['client', 'driver']));
      expect(updatedUser.isClient, isTrue);
      expect(updatedUser.isDriver, isTrue);
    });

    test('should not add duplicate role', () {
      // Arrange
      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        roles: ['client'],
      );

      // Act
      final updatedUser = user.addRole('client');

      // Assert
      expect(updatedUser.roles, equals(['client']));
      expect(updatedUser.roles.length, equals(1));
    });

    test('should remove role correctly', () {
      // Arrange
      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        roles: ['client', 'driver'],
      );

      // Act
      final updatedUser = user.removeRole('driver');

      // Assert
      expect(updatedUser.roles, equals(['client']));
      expect(updatedUser.isClient, isTrue);
      expect(updatedUser.isDriver, isFalse);
    });

    test('should not remove non-existent role', () {
      // Arrange
      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        roles: ['client'],
      );

      // Act
      final updatedUser = user.removeRole('admin');

      // Assert
      expect(updatedUser.roles, equals(['client']));
    });
  });

  group('DriverDetails', () {
    test('should create driver details with default values', () {
      // Act
      final driverDetails = DriverDetails();

      // Assert
      expect(driverDetails.isAvailable, isFalse);
      expect(driverDetails.currentLatitude, isNull);
      expect(driverDetails.currentLongitude, isNull);
      expect(driverDetails.rating, isNull);
      expect(driverDetails.vehicles, isEmpty);
      expect(driverDetails.primaryVehicle, isNull);
    });

    test('should create driver details with provided values', () {
      // Arrange
      final vehicles = [
        VehicleEntity(
          id: 'vehicle1',
          licensePlate: 'ABC123',
          brand: 'Toyota',
          model: 'Corolla',
          type: 'car',
          isPrimary: true,
        ),
        VehicleEntity(
          id: 'vehicle2',
          licensePlate: 'XYZ789',
          brand: 'Honda',
          model: 'Civic',
          type: 'car',
          isPrimary: false,
        ),
      ];

      // Act
      final driverDetails = DriverDetails(
        isAvailable: true,
        currentLatitude: 37.7749,
        currentLongitude: -122.4194,
        rating: 4.5,
        vehicles: vehicles,
      );

      // Assert
      expect(driverDetails.isAvailable, isTrue);
      expect(driverDetails.currentLatitude, equals(37.7749));
      expect(driverDetails.currentLongitude, equals(-122.4194));
      expect(driverDetails.rating, equals(4.5));
      expect(driverDetails.vehicles, equals(vehicles));
      expect(driverDetails.primaryVehicle, equals(vehicles[0]));
    });

    test('should return primary vehicle correctly', () {
      // Arrange
      final vehicles = [
        VehicleEntity(
          id: 'vehicle1',
          licensePlate: 'ABC123',
          brand: 'Toyota',
          model: 'Corolla',
          type: 'car',
          isPrimary: false,
        ),
        VehicleEntity(
          id: 'vehicle2',
          licensePlate: 'XYZ789',
          brand: 'Honda',
          model: 'Civic',
          type: 'car',
          isPrimary: true,
        ),
      ];

      // Act
      final driverDetails = DriverDetails(vehicles: vehicles);

      // Assert
      expect(driverDetails.primaryVehicle, equals(vehicles[1]));
    });

    test('should return first vehicle as primary when no primary is set', () {
      // Arrange
      final vehicles = [
        VehicleEntity(
          id: 'vehicle1',
          licensePlate: 'ABC123',
          brand: 'Toyota',
          model: 'Corolla',
          type: 'car',
          isPrimary: false,
        ),
        VehicleEntity(
          id: 'vehicle2',
          licensePlate: 'XYZ789',
          brand: 'Honda',
          model: 'Civic',
          type: 'car',
          isPrimary: false,
        ),
      ];

      // Act
      final driverDetails = DriverDetails(vehicles: vehicles);

      // Assert
      expect(driverDetails.primaryVehicle, equals(vehicles[0]));
    });

    test('should copy with new values', () {
      // Arrange
      final driverDetails = DriverDetails(
        isAvailable: false,
        currentLatitude: 37.7749,
        currentLongitude: -122.4194,
        rating: 4.5,
      );

      // Act
      final updatedDriverDetails = driverDetails.copyWith(
        isAvailable: true,
        rating: 4.8,
      );

      // Assert
      expect(updatedDriverDetails.isAvailable, isTrue);
      expect(updatedDriverDetails.currentLatitude, equals(37.7749));
      expect(updatedDriverDetails.currentLongitude, equals(-122.4194));
      expect(updatedDriverDetails.rating, equals(4.8));
    });
  });

  group('ClientDetails', () {
    test('should create client details with default values', () {
      // Act
      final clientDetails = ClientDetails();

      // Assert
      expect(clientDetails.rating, isNull);
    });

    test('should create client details with provided values', () {
      // Act
      final clientDetails = ClientDetails(rating: 4.8);

      // Assert
      expect(clientDetails.rating, equals(4.8));
    });

    test('should copy with new values', () {
      // Arrange
      final clientDetails = ClientDetails(rating: 4.5);

      // Act
      final updatedClientDetails = clientDetails.copyWith(rating: 4.8);

      // Assert
      expect(updatedClientDetails.rating, equals(4.8));
    });
  });
}
