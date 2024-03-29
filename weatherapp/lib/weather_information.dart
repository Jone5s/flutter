import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'location_service.dart';
class WeatherInformation extends StatefulWidget {
  @override
  _WeatherInformationState createState() => _WeatherInformationState();
}

class _WeatherInformationState extends State<WeatherInformation> {
  String city = '';
  String temperature = '';
  String description = '';
  IconData weatherIcon = Icons.wb_sunny;


  @override
  void initState() {
    super.initState();
    LocationService().addListener((locationData) {
    fetchWeatherData(locationData.latitude, locationData.longitude);
  });
  }

  Future<void> fetchWeatherData(double? lat, double? lon) async {
    if (lat == null || lon == null) {
    // Retry after a delay if the location is null
    Future.delayed(Duration(seconds: 3), () {
      LocationData? locationData = LocationService().currentLocation;
      if (locationData != null) {
        fetchWeatherData(locationData.latitude, locationData.longitude);
      }
    });
    return;
  }
    var url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=ae684053bd359fc697d2d89c798ccce2&units=metric';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        city = data['name'];
        temperature = '${data['main']['temp']}°C';
        description = data['weather'][0]['description'];
        weatherIcon = getWeatherIcon(data['weather'][0]['id']);
      });
    } else {
      city = 'Failed to fetch weather data';
    }
  }
  IconData getWeatherIcon(int condition) {
    if (condition < 300) {
      return Icons.flash_on; // Thunderstorm
    } else if (condition < 400) {
      return Icons.grain; // Drizzle
    } else if (condition < 600) {
      return Icons.beach_access; // Rain
    } else if (condition < 700) {
      return Icons.ac_unit; // Snow
    } else if (condition < 800) {
      return Icons.filter_drama; // Atmosphere
    } else if (condition == 800) {
      return Icons.wb_sunny; // Clear
    } else if (condition <= 804) {
      return Icons.cloud; // Clouds
    }
    return Icons.error; // Fallback for other conditions
  }

  @override
    Widget build(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            city,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            temperature,
            style: TextStyle(fontSize: 50),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(weatherIcon),
              SizedBox(width: 10),
              Text(
                description,
                style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }
}