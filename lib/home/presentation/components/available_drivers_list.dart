import 'package:flutter/material.dart';
import 'package:ndao/home/presentation/components/driver_item.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:provider/provider.dart';

/// A widget that displays a list of available drivers
class AvailableDriversList extends StatefulWidget {
  /// Creates a new AvailableDriversList
  const AvailableDriversList({super.key});

  @override
  State<AvailableDriversList> createState() => _AvailableDriversListState();
}

class _AvailableDriversListState extends State<AvailableDriversList> {
  late Future<List<UserEntity>> _driversFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    final userRepository = Provider.of<UserRepository>(context, listen: false);
    _driversFuture = userRepository.getAvailableDrivers();

    // Set refreshing to false after a delay to prevent rapid refreshes
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDrivers,
      child: CustomScrollView(
        // Use physics that works with RefreshIndicator
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Les chauffeurs à proximité',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<UserEntity>>(
              future: _driversFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                final drivers = snapshot.data ?? [];

                if (drivers.isEmpty) {
                  return _buildEmptyState();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      for (final driver in drivers) ...[
                        DriverItem(driver: driver),
                        const SizedBox(height: 8),
                      ],
                      // Add extra space at the bottom for better UX
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _DriverItemSkeleton(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur lors du chargement des chauffeurs',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadDrivers,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
            // Add space for scrolling
            const SizedBox(height: 300),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_transfer,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun chauffeur disponible pour le moment',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tirez vers le bas pour actualiser',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            // Add space for scrolling
            const SizedBox(height: 300),
          ],
        ),
      ),
    );
  }
}

class _DriverItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Driver photo skeleton
                const _SkeletonCircle(size: 56),
                const SizedBox(width: 12),

                // Driver info skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SkeletonLine(width: 120, height: 18),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          _SkeletonLine(width: 80, height: 12),
                          SizedBox(width: 16),
                          _SkeletonLine(width: 100, height: 12),
                        ],
                      ),
                    ],
                  ),
                ),

                // Distance indicator skeleton
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    _SkeletonLine(width: 50, height: 16),
                    SizedBox(height: 4),
                    _SkeletonLine(width: 40, height: 12),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action buttons skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _SkeletonActionButton(),
                _SkeletonActionButton(),
                _SkeletonActionButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;

  const _SkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _SkeletonActionButton extends StatelessWidget {
  const _SkeletonActionButton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SkeletonCircle(size: 24),
        SizedBox(height: 4),
        _SkeletonLine(width: 48, height: 10),
      ],
    );
  }
}
