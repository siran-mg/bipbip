import 'package:flutter/material.dart';
import 'package:ndao/location/domain/entities/position_entity.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/location/domain/utils/location_utils.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/presentation/components/favorite_button.dart';
import 'package:ndao/user/presentation/pages/driver_details_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverItem extends StatelessWidget {
  /// The driver to display
  final UserEntity driver;

  const DriverItem({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<PositionEntity>(
      future: _getUserPosition(context),
      builder: (context, snapshot) {
        // Default values while loading or if there's an error
        double distance = 0.0;
        int estimatedTime = 0;
        Color distanceColor = Colors.grey;

        // Calculate distance if we have the user's position and driver has location
        if (snapshot.hasData &&
            driver.driverDetails?.currentLatitude != null &&
            driver.driverDetails?.currentLongitude != null) {
          // Calculate distance between user and driver
          distance = LocationUtils.calculateDistance(
            snapshot.data!.latitude,
            snapshot.data!.longitude,
            driver.driverDetails!.currentLatitude!,
            driver.driverDetails!.currentLongitude!,
          );

          // Estimate travel time based on distance
          estimatedTime = LocationUtils.estimateTravelTime(distance);

          // Determine color based on distance
          distanceColor = distance <= 2.0
              ? Colors.green
              : distance <= 5.0
                  ? Colors.orange
                  : Colors.red;
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) {
                  // Get the current user for reviews
                  final getCurrentUserInteractor =
                      Provider.of<GetCurrentUserInteractor>(context,
                          listen: false);

                  return FutureBuilder<UserEntity?>(
                    future: getCurrentUserInteractor.execute(),
                    builder: (context, snapshot) {
                      return DriverDetailsPage(
                        driver: driver,
                        currentUser: snapshot.data,
                      );
                    },
                  );
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var curve = Curves.easeInOut;
                  var curveTween = CurveTween(curve: curve);
                  var fadeAnimation = animation.drive(curveTween);
                  return FadeTransition(opacity: fadeAnimation, child: child);
                },
              ),
            );
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Favorite button positioned on top of the driver photo
                      Stack(
                        children: [
                          // Driver photo with enhanced Hero animation
                          Hero(
                            tag: 'driver-${driver.id}',
                            flightShuttleBuilder: (flightContext,
                                animation,
                                flightDirection,
                                fromHeroContext,
                                toHeroContext) {
                              // This will be overridden by the destination Hero's flightShuttleBuilder
                              return toHeroContext.widget;
                            },
                            child: CircleAvatar(
                              radius: 28.0,
                              backgroundColor: colorScheme.primaryContainer,
                              backgroundImage: driver.profilePictureUrl != null
                                  ? NetworkImage(driver.profilePictureUrl!)
                                  : null,
                              child: driver.profilePictureUrl == null
                                  ? Text(
                                      driver.givenName[0] +
                                          driver.familyName[0],
                                      style: TextStyle(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  : null,
                            ),
                          ),

                          // Favorite button positioned at the top-right of the photo
                          Positioned(
                            top: -4,
                            right: -4,
                            child: FavoriteButton(
                              driver: driver,
                              size: 18.0,
                              circular: true,
                              filled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Driver info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.fullName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  driver.driverDetails?.rating?.toString() ??
                                      'N/A',
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.motorcycle,
                                  size: 16,
                                  color: colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    driver.driverDetails?.primaryVehicle != null
                                        ? '${driver.driverDetails!.primaryVehicle!.brand} ${driver.driverDetails!.primaryVehicle!.model}'
                                        : 'Véhicule inconnu',
                                    style: theme.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Distance indicator
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: distanceColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$distance km',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: distanceColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$estimatedTime min',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.phone,
                        label: 'Appeler',
                        onPressed: () => _makePhoneCall(driver.phoneNumber),
                      ),
                      _ActionButton(
                        icon: Icons.message,
                        label: 'SMS',
                        onPressed: () => _sendSms(driver.phoneNumber),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Get the user's current position
  Future<PositionEntity> _getUserPosition(BuildContext context) async {
    try {
      final locatorProvider =
          Provider.of<LocatorProvider>(context, listen: false);
      return await locatorProvider.getCurrentPosition();
    } catch (e) {
      // Return a default position if we can't get the user's location
      // This could be improved by using the last known position or a default for the city
      return PositionEntity(
          latitude: -18.8792, longitude: 47.5079); // Antananarivo
    }
  }

  /// Make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  /// Send an SMS
  Future<void> _sendSms(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $uri');
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
