import 'package:flutter_test/flutter_test.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';

void main() {
  group('VehicleEntity', () {
    test('should create a vehicle with required fields', () {
      // Arrange
      const id = 'vehicle123';
      const licensePlate = 'ABC123';
      const brand = 'Toyota';
      const model = 'Corolla';
      const type = 'car';

      // Act
      final vehicle = VehicleEntity(
        id: id,
        licensePlate: licensePlate,
        brand: brand,
        model: model,
        type: type,
      );

      // Assert
      expect(vehicle.id, equals(id));
      expect(vehicle.licensePlate, equals(licensePlate));
      expect(vehicle.brand, equals(brand));
      expect(vehicle.model, equals(model));
      expect(vehicle.type, equals(type));
      expect(vehicle.photoUrl, isNull);
      expect(vehicle.isPrimary, isTrue); // Default value
    });

    test('should create a vehicle with all fields', () {
      // Arrange
      const id = 'vehicle123';
      const licensePlate = 'ABC123';
      const brand = 'Toyota';
      const model = 'Corolla';
      const type = 'car';
      const photoUrl = 'https://example.com/vehicle.jpg';
      const isPrimary = false;

      // Act
      final vehicle = VehicleEntity(
        id: id,
        licensePlate: licensePlate,
        brand: brand,
        model: model,
        type: type,
        photoUrl: photoUrl,
        isPrimary: isPrimary,
      );

      // Assert
      expect(vehicle.id, equals(id));
      expect(vehicle.licensePlate, equals(licensePlate));
      expect(vehicle.brand, equals(brand));
      expect(vehicle.model, equals(model));
      expect(vehicle.type, equals(type));
      expect(vehicle.photoUrl, equals(photoUrl));
      expect(vehicle.isPrimary, equals(isPrimary));
    });

    test('should copy with new values', () {
      // Arrange
      final vehicle = VehicleEntity(
        id: 'vehicle123',
        licensePlate: 'ABC123',
        brand: 'Toyota',
        model: 'Corolla',
        type: 'car',
      );

      // Act
      final updatedVehicle = vehicle.copyWith(
        licensePlate: 'XYZ789',
        brand: 'Honda',
        model: 'Civic',
        isPrimary: false,
      );

      // Assert
      expect(updatedVehicle.id, equals('vehicle123'));
      expect(updatedVehicle.licensePlate, equals('XYZ789'));
      expect(updatedVehicle.brand, equals('Honda'));
      expect(updatedVehicle.model, equals('Civic'));
      expect(updatedVehicle.type, equals('car'));
      expect(updatedVehicle.photoUrl, isNull);
      expect(updatedVehicle.isPrimary, isFalse);
    });
  });
}
