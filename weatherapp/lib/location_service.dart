import 'package:location/location.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  Location location = Location();
  LocationData? currentLocation;
  List<Function(LocationData)> _listeners = [];

  factory LocationService() {
    return _instance;
  }

  LocationService._internal() {
    fetchLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      this.currentLocation = currentLocation;
      for (var listener in _listeners) {
        listener(currentLocation);
      }
    });
  }


  Future<void> fetchLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentLocation = await location.getLocation();
  }
  
  void addListener(Function(LocationData) listener) {
    _listeners.add(listener);
    if (currentLocation != null) {
      listener(currentLocation!); // Immediately call listener if location is already available
    }
  }
}
