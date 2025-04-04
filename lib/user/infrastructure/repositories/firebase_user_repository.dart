import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  
  FirebaseUserRepository(this._firestore);
  
  @override
  Future<UserEntity> saveUser(UserEntity user) async {
    try {
      // Save user data to Firestore
      await _firestore.collection('users').doc(user.id).set({
        'given_name': user.givenName,
        'family_name': user.familyName,
        'email': user.email,
        'phone_number': user.phoneNumber,
        'profile_picture_url': user.profilePictureUrl,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Save roles
      for (final role in user.roles) {
        await _firestore.collection('user_roles').doc('${user.id}_$role').set({
          'user_id': user.id,
          'role': role,
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      
      // Save driver details if applicable
      if (user.isDriver && user.driverDetails != null) {
        await _firestore.collection('driver_details').doc(user.id).set({
          'user_id': user.id,
          'is_available': user.driverDetails!.isAvailable,
          'current_latitude': user.driverDetails!.currentLatitude,
          'current_longitude': user.driverDetails!.currentLongitude,
          'vehicle_license_plate': user.driverDetails!.licensePlate,
          'vehicle_model': user.driverDetails!.model,
          'vehicle_color': user.driverDetails!.color,
          'vehicle_type': user.driverDetails!.vehicleType,
          'rating': user.driverDetails!.rating,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      // Save client details if applicable
      if (user.isClient && user.clientDetails != null) {
        await _firestore.collection('client_details').doc(user.id).set({
          'user_id': user.id,
          'rating': user.clientDetails!.rating,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      return user;
    } catch (e) {
      throw Exception('Failed to save user: ${e.toString()}');
    }
  }
  
  @override
  Future<UserEntity?> getUserById(String id) async {
    try {
      // Get user data
      final userDoc = await _firestore.collection('users').doc(id).get();
      
      if (!userDoc.exists) {
        return null;
      }
      
      final userData = userDoc.data()!;
      
      // Get user roles
      final rolesSnapshot = await _firestore
          .collection('user_roles')
          .where('user_id', isEqualTo: id)
          .where('is_active', isEqualTo: true)
          .get();
      
      final roles = rolesSnapshot.docs
          .map((doc) => doc.data()['role'] as String)
          .toList();
      
      // Get driver details if user is a driver
      DriverDetails? driverDetails;
      if (roles.contains('driver')) {
        final driverDoc = await _firestore.collection('driver_details').doc(id).get();
        
        if (driverDoc.exists && driverDoc.data() != null) {
          final driverData = driverDoc.data()!;
          
          driverDetails = DriverDetails(
            isAvailable: driverData['is_available'] ?? false,
            currentLatitude: driverData['current_latitude'],
            currentLongitude: driverData['current_longitude'],
            licensePlate: driverData['vehicle_license_plate'] ?? '',
            model: driverData['vehicle_model'] ?? '',
            color: driverData['vehicle_color'] ?? '',
            vehicleType: driverData['vehicle_type'] ?? '',
            rating: driverData['rating'],
          );
        }
      }
      
      // Get client details if user is a client
      ClientDetails? clientDetails;
      if (roles.contains('client')) {
        final clientDoc = await _firestore.collection('client_details').doc(id).get();
        
        if (clientDoc.exists && clientDoc.data() != null) {
          final clientData = clientDoc.data()!;
          
          clientDetails = ClientDetails(
            rating: clientData['rating'],
          );
        }
      }
      
      return UserEntity(
        id: id,
        givenName: userData['given_name'] ?? '',
        familyName: userData['family_name'] ?? '',
        email: userData['email'] ?? '',
        phoneNumber: userData['phone_number'] ?? '',
        profilePictureUrl: userData['profile_picture_url'],
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
      // Update user data
      await _firestore.collection('users').doc(user.id).update({
        'given_name': user.givenName,
        'family_name': user.familyName,
        'email': user.email,
        'phone_number': user.phoneNumber,
        'profile_picture_url': user.profilePictureUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // Update driver details if applicable
      if (user.isDriver && user.driverDetails != null) {
        await _firestore.collection('driver_details').doc(user.id).set({
          'is_available': user.driverDetails!.isAvailable,
          'current_latitude': user.driverDetails!.currentLatitude,
          'current_longitude': user.driverDetails!.currentLongitude,
          'vehicle_license_plate': user.driverDetails!.licensePlate,
          'vehicle_model': user.driverDetails!.model,
          'vehicle_color': user.driverDetails!.color,
          'vehicle_type': user.driverDetails!.vehicleType,
          'rating': user.driverDetails!.rating,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      // Update client details if applicable
      if (user.isClient && user.clientDetails != null) {
        await _firestore.collection('client_details').doc(user.id).set({
          'rating': user.clientDetails!.rating,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      return user;
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> deleteUser(String id) async {
    try {
      // Delete user data
      await _firestore.collection('users').doc(id).delete();
      
      // Delete user roles
      final rolesSnapshot = await _firestore
          .collection('user_roles')
          .where('user_id', isEqualTo: id)
          .get();
      
      for (final doc in rolesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete driver details
      await _firestore.collection('driver_details').doc(id).delete();
      
      // Delete client details
      await _firestore.collection('client_details').doc(id).delete();
      
      return true;
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }
  
  @override
  Future<UserEntity> addRole(String userId, String role) async {
    try {
      // Add role
      await _firestore.collection('user_roles').doc('${userId}_$role').set({
        'user_id': userId,
        'role': role,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      });
      
      // If adding driver role, add placeholder driver details
      if (role == 'driver') {
        final driverDoc = await _firestore.collection('driver_details').doc(userId).get();
        
        if (!driverDoc.exists) {
          await _firestore.collection('driver_details').doc(userId).set({
            'user_id': userId,
            'is_available': false,
            'vehicle_license_plate': 'UNKNOWN',
            'vehicle_model': 'UNKNOWN',
            'vehicle_color': 'UNKNOWN',
            'vehicle_type': 'motorcycle',
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
      
      // If adding client role, add placeholder client details
      if (role == 'client') {
        final clientDoc = await _firestore.collection('client_details').doc(userId).get();
        
        if (!clientDoc.exists) {
          await _firestore.collection('client_details').doc(userId).set({
            'user_id': userId,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
      
      // Get the updated user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      return user;
    } catch (e) {
      throw Exception('Failed to add role: ${e.toString()}');
    }
  }
  
  @override
  Future<UserEntity> removeRole(String userId, String role) async {
    try {
      // Remove role
      await _firestore.collection('user_roles').doc('${userId}_$role').update({
        'is_active': false,
      });
      
      // Get the updated user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      return user;
    } catch (e) {
      throw Exception('Failed to remove role: ${e.toString()}');
    }
  }
  
  @override
  Future<UserEntity> updateDriverDetails(String userId, DriverDetails driverDetails) async {
    try {
      // Update driver details
      await _firestore.collection('driver_details').doc(userId).set({
        'is_available': driverDetails.isAvailable,
        'current_latitude': driverDetails.currentLatitude,
        'current_longitude': driverDetails.currentLongitude,
        'vehicle_license_plate': driverDetails.licensePlate,
        'vehicle_model': driverDetails.model,
        'vehicle_color': driverDetails.color,
        'vehicle_type': driverDetails.vehicleType,
        'rating': driverDetails.rating,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Get the updated user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      return user;
    } catch (e) {
      throw Exception('Failed to update driver details: ${e.toString()}');
    }
  }
  
  @override
  Future<UserEntity> updateClientDetails(String userId, ClientDetails clientDetails) async {
    try {
      // Update client details
      await _firestore.collection('client_details').doc(userId).set({
        'rating': clientDetails.rating,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Get the updated user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      return user;
    } catch (e) {
      throw Exception('Failed to update client details: ${e.toString()}');
    }
  }
  
  @override
  Future<UserEntity> updateDriverPosition(String userId, double latitude, double longitude) async {
    try {
      // Update driver position
      await _firestore.collection('driver_details').doc(userId).update({
        'current_latitude': latitude,
        'current_longitude': longitude,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // Get the updated user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      return user;
    } catch (e) {
      throw Exception('Failed to update driver position: ${e.toString()}');
    }
  }
  
  @override
  Future<UserEntity> updateDriverAvailability(String userId, bool isAvailable) async {
    try {
      // Update driver availability
      await _firestore.collection('driver_details').doc(userId).update({
        'is_available': isAvailable,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // Get the updated user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      return user;
    } catch (e) {
      throw Exception('Failed to update driver availability: ${e.toString()}');
    }
  }
  
  @override
  Future<List<UserEntity>> getAvailableDrivers() async {
    try {
      final snapshot = await _firestore
          .collection('driver_details')
          .where('is_available', isEqualTo: true)
          .get();
      
      final drivers = <UserEntity>[];
      for (final doc in snapshot.docs) {
        final userId = doc.data()['user_id'] as String;
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
