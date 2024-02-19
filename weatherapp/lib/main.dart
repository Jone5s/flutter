import 'package:flutter/material.dart';
import 'weather_home_page.dart';
import 'location_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure plugin services are initialized
  LocationService(); // Initialize the LocationService
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: WeatherHomePage(),
    );
  }
}
