import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../model/food_model.dart';
import '../data/food_data.dart';

class LocationFilterService {
  // Calculate distance between two points using Haversine formula
  double _calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  // Get user's current location with permission handling
  Future<LatLng?> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // Location services disabled
    }

    // Check and request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // Permission denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Permission permanently denied
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  // Filter companions by distance
  Future<List<FoodModel>> filterByDistance(double maxDistanceKm) async {
    if (maxDistanceKm == 0) {
      return foodData; // No distance filter applied
    }

    final userLocation = await getUserLocation();
    if (userLocation == null) {
      return foodData; // Return all if location unavailable
    }

    return foodData.where((companion) {
      final companionLocation = LatLng(companion.latitude, companion.longitude);
      final distance = _calculateDistance(userLocation, companionLocation);
      return distance <= maxDistanceKm;
    }).toList();
  }
}
