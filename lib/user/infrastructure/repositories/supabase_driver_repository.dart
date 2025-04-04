import 'package:ndao/location/domain/entities/position_entity.dart';
import 'package:ndao/user/domain/entities/driver_entity.dart';
import 'package:ndao/user/domain/repositories/driver_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Implementation of DriverRepository using Supabase
class SupabaseDriverRepository implements DriverRepository {
  final supabase.SupabaseClient _client;
  final String _tableName = 'drivers';

  /// Creates a new SupabaseDriverRepository with the given client
  SupabaseDriverRepository(this._client);

  @override
  Future<DriverEntity> saveDriver(DriverEntity driver) async {
    try {
      // Check if the driver already exists
      if (driver.id.isNotEmpty) {
        return updateDriver(driver);
      }

      // Insert the driver into the database
      final response = await _client.from(_tableName).insert({
        'name': driver.name,
        'email': driver.email,
        'phone_number': driver.phoneNumber,
        'profile_picture_url': driver.profilePictureUrl,
        'rating': driver.rating,
        'is_available': driver.isAvailable,
        'current_latitude': driver.currentPosition?.latitude,
        'current_longitude': driver.currentPosition?.longitude,
        'vehicle_license_plate': driver.vehicleInfo.licensePlate,
        'vehicle_model': driver.vehicleInfo.model,
        'vehicle_color': driver.vehicleInfo.color,
        'vehicle_type': driver.vehicleInfo.type.name,
      }).select().single();

      // Return the driver with the generated ID
      return _mapToDriverEntity(response);
    } catch (e) {
      throw Exception('Failed to save driver: ${e.toString()}');
    }
  }

  @override
  Future<DriverEntity?> getDriverById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapToDriverEntity(response);
    } catch (e) {
      throw Exception('Failed to get driver: ${e.toString()}');
    }
  }

  @override
  Future<DriverEntity> updateDriver(DriverEntity driver) async {
    try {
      await _client.from(_tableName).update({
        'name': driver.name,
        'email': driver.email,
        'phone_number': driver.phoneNumber,
        'profile_picture_url': driver.profilePictureUrl,
        'rating': driver.rating,
        'is_available': driver.isAvailable,
        'current_latitude': driver.currentPosition?.latitude,
        'current_longitude': driver.currentPosition?.longitude,
        'vehicle_license_plate': driver.vehicleInfo.licensePlate,
        'vehicle_model': driver.vehicleInfo.model,
        'vehicle_color': driver.vehicleInfo.color,
        'vehicle_type': driver.vehicleInfo.type.name,
      }).eq('id', driver.id);

      return driver;
    } catch (e) {
      throw Exception('Failed to update driver: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteDriver(String id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      throw Exception('Failed to delete driver: ${e.toString()}');
    }
  }

  @override
  Future<DriverEntity> updateDriverPosition(
      String driverId, double latitude, double longitude) async {
    try {
      await _client.from(_tableName).update({
        'current_latitude': latitude,
        'current_longitude': longitude,
      }).eq('id', driverId);

      // Get the updated driver
      final driver = await getDriverById(driverId);
      if (driver == null) {
        throw Exception('Driver not found');
      }

      return driver;
    } catch (e) {
      throw Exception('Failed to update driver position: ${e.toString()}');
    }
  }

  @override
  Future<DriverEntity> updateDriverAvailability(
      String driverId, bool isAvailable) async {
    try {
      await _client.from(_tableName).update({
        'is_available': isAvailable,
      }).eq('id', driverId);

      // Get the updated driver
      final driver = await getDriverById(driverId);
      if (driver == null) {
        throw Exception('Driver not found');
      }

      return driver;
    } catch (e) {
      throw Exception('Failed to update driver availability: ${e.toString()}');
    }
  }

  @override
  Future<List<DriverEntity>> getAvailableDrivers() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_available', true);

      return response.map((data) => _mapToDriverEntity(data)).toList();
    } catch (e) {
      throw Exception('Failed to get available drivers: ${e.toString()}');
    }
  }

  /// Maps a database response to a DriverEntity
  DriverEntity _mapToDriverEntity(Map<String, dynamic> data) {
    // Create position entity if latitude and longitude are available
    PositionEntity? position;
    if (data['current_latitude'] != null && data['current_longitude'] != null) {
      position = PositionEntity(
        latitude: data['current_latitude'],
        longitude: data['current_longitude'],
      );
    }

    // Map vehicle type string to enum
    VehicleType vehicleType;
    switch (data['vehicle_type']) {
      case 'motorcycle':
        vehicleType = VehicleType.motorcycle;
        break;
      case 'car':
        vehicleType = VehicleType.car;
        break;
      case 'bicycle':
        vehicleType = VehicleType.bicycle;
        break;
      default:
        vehicleType = VehicleType.other;
    }

    // Create vehicle info
    final vehicleInfo = VehicleInfo(
      licensePlate: data['vehicle_license_plate'],
      model: data['vehicle_model'],
      color: data['vehicle_color'],
      type: vehicleType,
    );

    // Create and return driver entity
    return DriverEntity(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phone_number'],
      profilePictureUrl: data['profile_picture_url'],
      rating: data['rating'],
      currentPosition: position,
      vehicleInfo: vehicleInfo,
      isAvailable: data['is_available'] ?? false,
    );
  }
}
