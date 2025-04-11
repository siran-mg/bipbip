import 'package:flutter/material.dart';
import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/providers/ride_request_provider.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/presentation/pages/driver_details_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that displays a client's ride request
class ClientRideRequestItem extends StatefulWidget {
  /// The ride request to display
  final RideRequestEntity rideRequest;

  /// Creates a new ClientRideRequestItem
  const ClientRideRequestItem({
    super.key,
    required this.rideRequest,
  });

  @override
  State<ClientRideRequestItem> createState() => _ClientRideRequestItemState();
}

class _ClientRideRequestItemState extends State<ClientRideRequestItem> {
  bool _isLoadingDriver = false;
  bool _isCancelling = false;
  UserEntity? _driver;

  @override
  void initState() {
    super.initState();
    // Load driver info if the request has been accepted
    if (widget.rideRequest.driverId != null) {
      _loadDriverInfo();
    }
  }

  Future<void> _loadDriverInfo() async {
    if (!mounted || widget.rideRequest.driverId == null) return;

    setState(() {
      _isLoadingDriver = true;
    });

    try {
      final userRepository =
          Provider.of<UserRepository>(context, listen: false);
      final driver =
          await userRepository.getUserById(widget.rideRequest.driverId!);

      if (mounted && driver != null) {
        setState(() {
          _driver = driver;
          _isLoadingDriver = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading driver info: $e');
      if (mounted) {
        setState(() {
          _isLoadingDriver = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the date
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(widget.rideRequest.createdAt);

    // Determine status color
    Color statusColor;
    IconData statusIcon;

    switch (widget.rideRequest.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.done_all;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(widget.rideRequest.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            // Cancel button for pending requests
            if (widget.rideRequest.isPending)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isCancelling ? null : _cancelRideRequest,
                  icon: _isCancelling
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : const Icon(Icons.cancel, color: Colors.red, size: 16),
                  label: Text(
                    'Annuler',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            const Divider(),

            // Destination
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.rideRequest.destinationName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Budget
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '${widget.rideRequest.budget.toStringAsFixed(0)} Ar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            // Driver info (if accepted)
            if (widget.rideRequest.isAccepted || widget.rideRequest.isCompleted)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Chauffeur',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingDriver
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : _driver != null
                          ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      _driver!.profilePictureUrl != null
                                          ? NetworkImage(
                                              _driver!.profilePictureUrl!)
                                          : null,
                                  child: _driver!.profilePictureUrl == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _driver!.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _driver!.phoneNumber,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // Call button
                                IconButton(
                                  icon: const Icon(Icons.phone,
                                      color: Colors.green),
                                  tooltip: 'Appeler le chauffeur',
                                  onPressed: () =>
                                      _makePhoneCall(_driver!.phoneNumber),
                                ),
                              ],
                            )
                          : const Text(
                              'Information du chauffeur non disponible'),

                  // View driver details button (only if driver is available)
                  if (_driver != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.person),
                          label: const Text('Voir le profil du chauffeur'),
                          onPressed: _viewDriverDetails,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Acceptée';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }

  Future<void> _cancelRideRequest() async {
    if (_isCancelling) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      final rideRequestProvider =
          Provider.of<RideRequestProvider>(context, listen: false);

      await rideRequestProvider.cancelRideRequest(widget.rideRequest.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande annulée avec succès'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  /// Make a phone call to the driver
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  /// Navigate to the driver details page
  Future<void> _viewDriverDetails() async {
    if (_driver == null) return;

    try {
      // Get current user
      final getCurrentUserInteractor =
          Provider.of<GetCurrentUserInteractor>(context, listen: false);
      final currentUser = await getCurrentUserInteractor.execute();

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DriverDetailsPage(
            driver: _driver!,
            currentUser:
                currentUser, // Pass the current user for favorites functionality
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
