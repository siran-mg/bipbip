import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loading UI for the profile page
class ProfileSkeleton extends StatelessWidget {
  /// Creates a new ProfileSkeleton
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
            const ProfileHeaderSkeleton(),
            
            const SizedBox(height: 24),
            
            // User info section skeleton
            const UserInfoSectionSkeleton(),
            
            const SizedBox(height: 24),
            
            // Driver/client section skeleton
            const DriverSectionSkeleton(),
            
            const SizedBox(height: 24),
            
            // Vehicles section skeleton (for drivers)
            const VehiclesSectionSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for the profile header
class ProfileHeaderSkeleton extends StatelessWidget {
  /// Creates a new ProfileHeaderSkeleton
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Profile photo skeleton
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
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
}

/// Skeleton for the user info section
class UserInfoSectionSkeleton extends StatelessWidget {
  /// Creates a new UserInfoSectionSkeleton
  const UserInfoSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
          const InfoRowSkeleton(),
          
          const Divider(color: Colors.grey),
          
          // Phone row
          const InfoRowSkeleton(),
        ],
      ),
    );
  }
}

/// Skeleton for the driver section
class DriverSectionSkeleton extends StatelessWidget {
  /// Creates a new DriverSectionSkeleton
  const DriverSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
          const InfoRowSkeleton(),
          
          const Divider(color: Colors.grey),
          
          // Status row
          const InfoRowSkeleton(),
        ],
      ),
    );
  }
}

/// Skeleton for an info row
class InfoRowSkeleton extends StatelessWidget {
  /// Creates a new InfoRowSkeleton
  const InfoRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
}

/// Skeleton for the vehicles section
class VehiclesSectionSkeleton extends StatelessWidget {
  /// Creates a new VehiclesSectionSkeleton
  const VehiclesSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
          const VehicleItemSkeleton(),
          const SizedBox(height: 16),
          const VehicleItemSkeleton(),
        ],
      ),
    );
  }
}

/// Skeleton for a vehicle item
class VehicleItemSkeleton extends StatelessWidget {
  /// Creates a new VehicleItemSkeleton
  const VehicleItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
