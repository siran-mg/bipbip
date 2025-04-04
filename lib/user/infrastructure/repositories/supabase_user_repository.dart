import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of UserRepository using Supabase
class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _client;

  /// Creates a new SupabaseUserRepository with the given client
  SupabaseUserRepository(this._client);

  @override
  Future<UserEntity> saveUser(UserEntity user) async {
    try {
      // Insert the user into the database
      await _client.from('users').insert({
        'id': user.id,
        'given_name': user.givenName,
        'family_name': user.familyName,
        'email': user.email,
        'phone_number': user.phoneNumber,
        'profile_picture_url': user.profilePictureUrl,
      });

      // Insert roles
      for (final role in user.roles) {
        await _client.from('user_roles').insert({
          'user_id': user.id,
          'role': role,
        });
      }

      // Insert driver details if the user is a driver
      if (user.isDriver && user.driverDetails != null) {
        await _client.from('driver_details').insert({
          'user_id': user.id,
          'is_available': user.driverDetails!.isAvailable,
          'current_latitude': user.driverDetails!.currentLatitude,
          'current_longitude': user.driverDetails!.currentLongitude,
          'vehicle_license_plate': user.driverDetails!.licensePlate,
          'vehicle_model': user.driverDetails!.model,
          'vehicle_color': user.driverDetails!.color,
          'vehicle_type': user.driverDetails!.vehicleType,
          'rating': user.driverDetails!.rating,
        });
      }

      // Insert client details if the user is a client
      if (user.isClient && user.clientDetails != null) {
        await _client.from('client_details').insert({
          'user_id': user.id,
          'rating': user.clientDetails!.rating,
        });
      }

      return user;
    } catch (e) {
      throw Exception('Failed to save user: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getUserById(String id) async {
    try {
      // Get the user
      final userResponse =
          await _client.from('users').select().eq('id', id).single();

      // Get the user's roles
      final rolesResponse =
          await _client.from('user_roles').select().eq('user_id', id);

      final roles =
          rolesResponse.map<String>((role) => role['role'] as String).toList();

      // Get driver details if the user is a driver
      DriverDetails? driverDetails;
      if (roles.contains('driver')) {
        final driverResponse = await _client
            .from('driver_details')
            .select()
            .eq('user_id', id)
            .maybeSingle();

        if (driverResponse != null) {
          driverDetails = DriverDetails(
            isAvailable: driverResponse['is_available'] ?? false,
            currentLatitude: driverResponse['current_latitude'],
            currentLongitude: driverResponse['current_longitude'],
            licensePlate: driverResponse['vehicle_license_plate'],
            model: driverResponse['vehicle_model'],
            color: driverResponse['vehicle_color'],
            vehicleType: driverResponse['vehicle_type'],
            rating: driverResponse['rating'],
          );
        }
      }

      // Get client details if the user is a client
      ClientDetails? clientDetails;
      if (roles.contains('client')) {
        final clientResponse = await _client
            .from('client_details')
            .select()
            .eq('user_id', id)
            .maybeSingle();

        if (clientResponse != null) {
          clientDetails = ClientDetails(
            rating: clientResponse['rating'],
          );
        }
      }

      // Create and return the user entity
      return UserEntity(
        id: userResponse['id'],
        givenName: userResponse['given_name'],
        familyName: userResponse['family_name'],
        email: userResponse['email'],
        phoneNumber: userResponse['phone_number'],
        profilePictureUrl: userResponse['profile_picture_url'],
        roles: roles,
        driverDetails: driverDetails,
        clientDetails: clientDetails,
      );
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    try {
      // Update the user
      await _client.from('users').update({
        'given_name': user.givenName,
        'family_name': user.familyName,
        'email': user.email,
        'phone_number': user.phoneNumber,
        'profile_picture_url': user.profilePictureUrl,
      }).eq('id', user.id);

      // Update driver details if the user is a driver
      if (user.isDriver && user.driverDetails != null) {
        await _client.from('driver_details').upsert({
          'user_id': user.id,
          'is_available': user.driverDetails!.isAvailable,
          'current_latitude': user.driverDetails!.currentLatitude,
          'current_longitude': user.driverDetails!.currentLongitude,
          'vehicle_license_plate': user.driverDetails!.licensePlate,
          'vehicle_model': user.driverDetails!.model,
          'vehicle_color': user.driverDetails!.color,
          'vehicle_type': user.driverDetails!.vehicleType,
          'rating': user.driverDetails!.rating,
        });
      }

      // Update client details if the user is a client
      if (user.isClient && user.clientDetails != null) {
        await _client.from('client_details').upsert({
          'user_id': user.id,
          'rating': user.clientDetails!.rating,
        });
      }

      return user;
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteUser(String id) async {
    try {
      // Delete the user (cascade will delete related records)
      await _client.from('users').delete().eq('id', id);
      return true;
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> addRole(String userId, String role) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user already has the role
      if (user.roles.contains(role)) {
        return user;
      }

      // Add the role
      await _client.from('user_roles').insert({
        'user_id': userId,
        'role': role,
      });

      // If adding driver role, add placeholder driver details
      if (role == 'driver' && user.driverDetails == null) {
        await _client.from('driver_details').insert({
          'user_id': userId,
          'vehicle_license_plate': 'UNKNOWN',
          'vehicle_model': 'UNKNOWN',
          'vehicle_color': 'UNKNOWN',
          'vehicle_type': 'motorcycle',
        });
      }

      // If adding client role, add placeholder client details
      if (role == 'client' && user.clientDetails == null) {
        await _client.from('client_details').insert({
          'user_id': userId,
        });
      }

      // Return the updated user
      return user.addRole(role);
    } catch (e) {
      throw Exception('Failed to add role: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> removeRole(String userId, String role) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user has the role
      if (!user.roles.contains(role)) {
        return user;
      }

      // Remove the role
      await _client
          .from('user_roles')
          .delete()
          .eq('user_id', userId)
          .eq('role', role);

      // Return the updated user
      return user.removeRole(role);
    } catch (e) {
      throw Exception('Failed to remove role: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateDriverDetails(
      String userId, DriverDetails driverDetails) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a driver
      if (!user.isDriver) {
        throw Exception('User is not a driver');
      }

      // Update driver details
      await _client.from('driver_details').upsert({
        'user_id': userId,
        'is_available': driverDetails.isAvailable,
        'current_latitude': driverDetails.currentLatitude,
        'current_longitude': driverDetails.currentLongitude,
        'vehicle_license_plate': driverDetails.licensePlate,
        'vehicle_model': driverDetails.model,
        'vehicle_color': driverDetails.color,
        'vehicle_type': driverDetails.vehicleType,
        'rating': driverDetails.rating,
      });

      // Return the updated user
      return user.copyWith(driverDetails: driverDetails);
    } catch (e) {
      throw Exception('Failed to update driver details: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateClientDetails(
      String userId, ClientDetails clientDetails) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a client
      if (!user.isClient) {
        throw Exception('User is not a client');
      }

      // Update client details
      await _client.from('client_details').upsert({
        'user_id': userId,
        'rating': clientDetails.rating,
      });

      // Return the updated user
      return user.copyWith(clientDetails: clientDetails);
    } catch (e) {
      throw Exception('Failed to update client details: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateDriverPosition(
      String userId, double latitude, double longitude) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a driver
      if (!user.isDriver) {
        throw Exception('User is not a driver');
      }

      // Update driver position
      await _client.from('driver_details').update({
        'current_latitude': latitude,
        'current_longitude': longitude,
      }).eq('user_id', userId);

      // Return the updated user
      final updatedDriverDetails = user.driverDetails?.copyWith(
        currentLatitude: latitude,
        currentLongitude: longitude,
      );

      return user.copyWith(driverDetails: updatedDriverDetails);
    } catch (e) {
      throw Exception('Failed to update driver position: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateDriverAvailability(
      String userId, bool isAvailable) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a driver
      if (!user.isDriver) {
        throw Exception('User is not a driver');
      }

      // Update driver availability
      await _client.from('driver_details').update({
        'is_available': isAvailable,
      }).eq('user_id', userId);

      // Return the updated user
      final updatedDriverDetails = user.driverDetails?.copyWith(
        isAvailable: isAvailable,
      );

      return user.copyWith(driverDetails: updatedDriverDetails);
    } catch (e) {
      throw Exception('Failed to update driver availability: ${e.toString()}');
    }
  }

  @override
  Future<List<UserEntity>> getAvailableDrivers() async {
    try {
      // Get all available drivers
      final response = await _client
          .from('driver_details')
          .select('user_id')
          .eq('is_available', true);

      // Get the user details for each driver
      final drivers = <UserEntity>[];
      for (final driver in response) {
        final userId = driver['user_id'];
        final user = await getUserById(userId);
        if (user != null) {
          drivers.add(user);
        }
      }

      return drivers;
    } catch (e) {
      throw Exception('Failed to get available drivers: ${e.toString()}');
    }
  }
}
