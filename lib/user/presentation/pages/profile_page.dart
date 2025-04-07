import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/presentation/components/file_picker_profile_photo.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

/// Profile page for displaying and editing user information
class ProfilePage extends StatefulWidget {
  /// Creates a new ProfilePage
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserEntity? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getCurrentUserInteractor =
          Provider.of<GetCurrentUserInteractor>(context, listen: false);
      final user = await getCurrentUserInteractor.execute();

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erreur lors du chargement des données: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildProfileSkeleton();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return const Center(
        child: Text('Aucun utilisateur connecté'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header with photo
            _buildProfileHeader(),

            const SizedBox(height: 24),

            // User information section
            _buildUserInfoSection(),

            const SizedBox(height: 24),

            // Role-specific sections
            if (_user!.isClient) _buildClientSection(),
            if (_user!.isDriver) _buildDriverSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Profile photo
          FilePickerProfilePhoto(
            userId: _user!.id,
            currentPhotoUrl: _user!.profilePictureUrl,
            onPhotoUpdated: (photoUrl) {
              setState(() {
                _user = _user!.copyWith(profilePictureUrl: photoUrl);
              });
            },
          ),

          const SizedBox(height: 16),

          // User name
          Text(
            _user!.fullName,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          // User roles
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: _user!.roles.map((role) {
              return Chip(
                label: Text(
                  role == 'client' ? 'Client' : 'Chauffeur',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations personnelles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Email', _user!.email),
            const Divider(),
            _buildInfoRow(Icons.phone, 'Téléphone', _user!.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSection() {
    final clientDetails = _user!.clientDetails;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil Client',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (clientDetails?.rating != null)
              _buildInfoRow(Icons.star, 'Note',
                  '${clientDetails!.rating!.toStringAsFixed(1)}/5.0'),
            if (clientDetails?.rating == null)
              const Text('Aucune note pour le moment'),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSection() {
    final driverDetails = _user!.driverDetails;

    if (driverDetails == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driver details card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profil Chauffeur',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                    Icons.star,
                    'Note',
                    driverDetails.rating != null
                        ? '${driverDetails.rating!.toStringAsFixed(1)}/5.0'
                        : 'Aucune note'),
                const Divider(),
                _buildInfoRow(
                  Icons.circle,
                  'Statut',
                  driverDetails.isAvailable ? 'Disponible' : 'Non disponible',
                  valueColor:
                      driverDetails.isAvailable ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Vehicles section
        if (driverDetails.vehicles.isNotEmpty)
          _buildVehiclesSection(driverDetails.vehicles),
      ],
    );
  }

  Widget _buildVehiclesSection(List<VehicleEntity> vehicles) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Véhicules',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...vehicles.map((vehicle) => _buildVehicleItem(vehicle)),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleItem(VehicleEntity vehicle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle photo or placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
              image: vehicle.photoUrl != null && !kIsWeb
                  ? DecorationImage(
                      image: NetworkImage(vehicle.photoUrl!),
                      fit: BoxFit.cover,
                      onError: (_, __) {
                        // Handle image loading error
                        return;
                      },
                    )
                  : null,
            ),
            child: vehicle.photoUrl == null
                ? const Icon(
                    Icons.directions_car,
                    size: 40,
                    color: Colors.grey,
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // Vehicle details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (vehicle.isPrimary)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Principal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Type: ${_getVehicleTypeLabel(vehicle.type)}'),
                const SizedBox(height: 4),
                Text('Plaque: ${vehicle.licensePlate}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get a user-friendly label for a vehicle type
  String _getVehicleTypeLabel(String type) {
    switch (type) {
      case 'motorcycle':
        return 'Moto';
      case 'car':
        return 'Voiture';
      case 'bicycle':
        return 'Vélo';
      case 'other':
        return 'Autre';
      default:
        return type; // Return the original type if not recognized
    }
  }

  /// Build a skeleton UI for the profile page while data is loading
  Widget _buildProfileSkeleton() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header skeleton
            _buildProfileHeaderSkeleton(),

            const SizedBox(height: 24),

            // User info section skeleton
            _buildUserInfoSectionSkeleton(),

            const SizedBox(height: 24),

            // Driver/client section skeleton
            _buildDriverSectionSkeleton(),

            const SizedBox(height: 24),

            // Vehicles section skeleton (for drivers)
            _buildVehiclesSectionSkeleton(),
          ],
        ),
      ),
    );
  }

  /// Build a skeleton for the profile header
  Widget _buildProfileHeaderSkeleton() {
    return Center(
      child: Column(
        children: [
          // Profile photo skeleton
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(height: 16),

          // Name skeleton
          Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 8),

          // Roles skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a skeleton for the user info section
  Widget _buildUserInfoSectionSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title skeleton
          Container(
            width: 180,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 16),

          // Email row
          _buildInfoRowSkeleton(),

          const Divider(color: Colors.grey),

          // Phone row
          _buildInfoRowSkeleton(),
        ],
      ),
    );
  }

  /// Build a skeleton for the driver section
  Widget _buildDriverSectionSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title skeleton
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 16),

          // Rating row
          _buildInfoRowSkeleton(),

          const Divider(color: Colors.grey),

          // Status row
          _buildInfoRowSkeleton(),
        ],
      ),
    );
  }

  /// Build a skeleton for an info row
  Widget _buildInfoRowSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Icon placeholder
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 16),

          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a skeleton for the vehicles section
  Widget _buildVehiclesSectionSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title skeleton
          Container(
            width: 100,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 16),

          // Vehicle items
          _buildVehicleItemSkeleton(),
          const SizedBox(height: 16),
          _buildVehicleItemSkeleton(),
        ],
      ),
    );
  }

  /// Build a skeleton for a vehicle item
  Widget _buildVehicleItemSkeleton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vehicle photo skeleton
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(width: 16),

        // Vehicle details skeleton
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand and model
              Row(
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Type
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 8),

              // License plate
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
