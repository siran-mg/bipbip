/// Constants for vehicle types
class VehicleType {
  /// Motorcycle type
  static const String moto = 'motorcycle';

  /// Car type
  static const String car = 'car';

  /// Van type
  static const String van = 'van';

  /// Truck type
  static const String truck = 'truck';

  /// Bicycle type
  static const String bicycle = 'bicycle';

  /// Other type
  static const String other = 'other';

  /// Get a user-friendly display name for a vehicle type
  static String getDisplayName(String type) {
    switch (type) {
      case moto:
        return 'Moto';
      case car:
        return 'Voiture';
      case van:
        return 'Van';
      case truck:
        return 'Camion';
      case bicycle:
        return 'Vélo';
      case other:
        return 'Autre';
      default:
        return type;
    }
  }

  /// Get all vehicle types
  static List<Map<String, String>> getAllTypes() {
    return [
      {'value': moto, 'label': getDisplayName(moto)},
      {'value': car, 'label': getDisplayName(car)},
      {'value': van, 'label': getDisplayName(van)},
      {'value': truck, 'label': getDisplayName(truck)},
      {'value': bicycle, 'label': getDisplayName(bicycle)},
      {'value': other, 'label': getDisplayName(other)},
    ];
  }
}
