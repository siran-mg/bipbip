import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/providers/review_provider.dart';
import 'package:ndao/user/presentation/components/driver_reviews_section.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDetailsPage extends StatefulWidget {
  final UserEntity driver;
  final UserEntity? currentUser; // Optional current user for reviews

  const DriverDetailsPage({
    super.key,
    required this.driver,
    this.currentUser,
  });

  @override
  State<DriverDetailsPage> createState() => _DriverDetailsPageState();
}

class _DriverDetailsPageState extends State<DriverDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load driver reviews
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      reviewProvider.loadDriverReviews(widget.driver.id);
      
      if (widget.currentUser != null) {
        reviewProvider.loadUserReview(
          userId: widget.currentUser!.id,
          driverId: widget.driver.id,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final driver = widget.driver;
    final currentUser = widget.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du chauffeur'),
      ),
      body: Column(
        children: [
          // Driver header with photo and name - always visible
          Container(
            color: colorScheme.primaryContainer,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              children: [
                // Driver photo with enhanced Hero animation
                Hero(
                  tag: 'driver-${driver.id}',
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: driver.profilePictureUrl != null
                        ? NetworkImage(driver.profilePictureUrl!)
                        : null,
                    child: driver.profilePictureUrl == null
                        ? Text(
                            driver.givenName[0] + driver.familyName[0],
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Driver name
                Text(
                  driver.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Rating from reviews
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, child) {
                      final reviews = reviewProvider.driverReviews;
                      final reviewCount = reviews.length;
                      
                      // Calculate average rating from reviews
                      final averageRating = reviewProvider.averageRating ?? 0.0;
                      
                      return Column(
                        children: [
                          // Star rating display
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (index) {
                              return Icon(
                                index < averageRating
                                    ? Icons.star
                                    : index + 0.5 <= averageRating
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          // Numeric rating with review count
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (reviewCount > 0) ...[
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '($reviewCount avis)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'Aucun avis',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Contact buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ContactButton(
                  icon: Icons.phone,
                  label: 'Appeler',
                  onTap: () => _makePhoneCall(driver.phoneNumber),
                ),
                _ContactButton(
                  icon: Icons.message,
                  label: 'SMS',
                  onTap: () => _sendSms(driver.phoneNumber),
                ),
                if (driver.driverDetails?.currentLatitude != null &&
                    driver.driverDetails?.currentLongitude != null)
                  _ContactButton(
                    icon: Icons.directions,
                    label: 'Itinéraire',
                    onTap: () => _openMapsWithDirections(
                      driver.driverDetails!.currentLatitude!,
                      driver.driverDetails!.currentLongitude!,
                    ),
                  ),
              ],
            ),
          ),
          
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'Profil'),
              Tab(icon: Icon(Icons.directions_car), text: 'Véhicules'),
              Tab(icon: Icon(Icons.star), text: 'Avis'),
            ],
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Profile Tab
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Driver info section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),

                            // Phone number
                            _InfoItem(
                              icon: Icons.phone,
                              label: 'Téléphone',
                              value: driver.phoneNumber,
                            ),

                            // Email if available
                            if (driver.email.isNotEmpty)
                              _InfoItem(
                                icon: Icons.email,
                                label: 'Email',
                                value: driver.email,
                              ),

                            // Status
                            _InfoItem(
                              icon: Icons.circle,
                              iconColor: driver.driverDetails?.isAvailable == true
                                  ? Colors.green
                                  : Colors.red,
                              label: 'Statut',
                              value: driver.driverDetails?.isAvailable == true
                                  ? 'Disponible'
                                  : 'Indisponible',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Vehicles Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primary vehicle
                      if (driver.driverDetails?.primaryVehicle != null) ...[
                        Text(
                          'Véhicule principal',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildVehicleCard(
                            driver.driverDetails!.primaryVehicle!, theme),
                        const SizedBox(height: 24),
                      ],

                      // Other vehicles
                      if (driver.driverDetails?.vehicles != null &&
                          driver.driverDetails!.vehicles.length > 1) ...[
                        Text(
                          'Autres véhicules',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...driver.driverDetails!.vehicles
                            .where((v) =>
                                v.id !=
                                driver.driverDetails!.primaryVehicle?.id)
                            .map(
                                (vehicle) => _buildVehicleCard(vehicle, theme)),
                      ],
                    ],
                  ),
                ),

                // Reviews Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DriverReviewsSection(
                      driver: driver,
                      currentUser: currentUser,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleEntity vehicle, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle name
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Vehicle details
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.category,
                    label: 'Type',
                    value: _getVehicleTypeLabel(vehicle.type),
                  ),
                ),
                if (vehicle.licensePlate.isNotEmpty)
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.confirmation_number,
                      label: 'Immatriculation',
                      value: vehicle.licensePlate,
                    ),
                  ),
              ],
            ),

            // Vehicle photo if available
            if (vehicle.photoUrl != null && vehicle.photoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    vehicle.photoUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getVehicleTypeLabel(String type) {
    switch (type) {
      case 'motorcycle':
        return 'Moto';
      case 'car':
        return 'Voiture';
      case 'suv':
        return 'SUV';
      case 'van':
        return 'Van';
      case 'truck':
        return 'Camion';
      default:
        return type;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  Future<void> _sendSms(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  Future<void> _openMapsWithDirections(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $uri');
    }
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
