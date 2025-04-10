import 'dart:math';

import 'package:ndao/location/domain/entities/position_entity.dart';

/// Utility class for location-related calculations
class LocationUtils {
  /// Calculate the distance between two points in kilometers using the Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radius of the earth in km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c; // Distance in km

    return double.parse(
        distance.toStringAsFixed(1)); // Round to 1 decimal place
  }

  /// Calculate the distance between two PositionEntity objects in kilometers
  static double calculateDistanceBetweenPositions(
    PositionEntity position1,
    PositionEntity position2,
  ) {
    return calculateDistance(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
  }

  /// Estimate travel time in minutes based on distance and average speed
  static int estimateTravelTime(double distanceInKm,
      {double averageSpeedKmh = 20}) {
    // Calculate time in hours: distance / speed
    final double timeInHours = distanceInKm / averageSpeedKmh;

    // Convert to minutes and round to nearest integer
    return (timeInHours * 60).round();
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
