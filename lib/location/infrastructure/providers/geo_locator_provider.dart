import 'package:dio/dio.dart';
import 'package:ndao/location/domain/entities/position_entity.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocatorProvider implements LocatorProvider {
  @override
  Future<PositionEntity> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return Geolocator.getCurrentPosition().then((position) {
      return PositionEntity(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }

  @override
  Future<String?> getAddressFromPosition(PositionEntity position) async {
    String apiKey = "AIzaSyCJCvIC_A4mfdgn2v1FmHeX_64Tnq2PnF4";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";

    final response = await Dio().get(url);
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['status'] == 'OK') {
        final address = data['results'][0]['formatted_address'];
        return address;
      }
    }
    return null;
  }
}
