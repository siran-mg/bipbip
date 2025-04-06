import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/user/domain/interactors/vehicle_interactor.dart';
import 'package:ndao/user/domain/repositories/vehicle_repository.dart';
import 'package:ndao/user/infrastructure/repositories/appwrite_vehicle_repository.dart';

/// Provides vehicle-related dependencies
class VehicleProviders {
  /// Get all vehicle providers
  static List<SingleChildWidget> getProviders() {
    return [
      // Vehicle repository
      Provider<VehicleRepository>(
        create: (context) => AppwriteVehicleRepository(
          AppwriteClientInitializer.instance.databases,
          AppwriteClientInitializer.instance.storage,
          databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? 'ndao',
          vehiclesCollectionId:
              dotenv.env['APPWRITE_VEHICLES_COLLECTION_ID'] ?? 'vehicles',
          driverVehiclesCollectionId:
              dotenv.env['APPWRITE_DRIVER_VEHICLES_COLLECTION_ID'] ??
                  'driver_vehicles',
          vehiclePhotosBucketId:
              dotenv.env['APPWRITE_VEHICLE_PHOTOS_BUCKET_ID'] ??
                  'vehicle_photos',
        ),
      ),

      // Vehicle interactor
      ProxyProvider<VehicleRepository, VehicleInteractor>(
        update: (_, vehicleRepository, __) =>
            VehicleInteractor(vehicleRepository),
      ),
    ];
  }
}
