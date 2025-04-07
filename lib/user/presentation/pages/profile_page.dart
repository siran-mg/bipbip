import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/presentation/components/profile/client_section.dart';
import 'package:ndao/user/presentation/components/profile/driver_section.dart';
import 'package:ndao/user/presentation/components/profile/profile_header.dart';
import 'package:ndao/user/presentation/components/profile/profile_skeleton.dart';
import 'package:ndao/user/presentation/components/profile/user_info_section.dart';
import 'package:provider/provider.dart';

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
      return const ProfileSkeleton();
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
            ProfileHeader(
              user: _user!,
              onPhotoUpdated: (photoUrl) {
                setState(() {
                  _user = _user!.copyWith(profilePictureUrl: photoUrl);
                });
              },
            ),

            const SizedBox(height: 24),

            // User information section
            UserInfoSection(user: _user!),

            const SizedBox(height: 24),

            // Role-specific sections
            if (_user!.isClient && _user!.clientDetails != null)
              ClientSection(clientDetails: _user!.clientDetails),
            if (_user!.isDriver && _user!.driverDetails != null)
              DriverSection(
                driverDetails: _user!.driverDetails!,
                userId: _user!.id,
                onDriverDetailsUpdated: (updatedDriverDetails) {
                  // Just update the UI state
                  setState(() {
                    _user = _user!.copyWith(
                      driverDetails: updatedDriverDetails,
                    );
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
