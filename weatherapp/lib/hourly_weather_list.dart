import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'daily_weather_forecast_page.dart';
import 'package:location/location.dart';

class HourlyWeatherList extends StatefulWidget {
  @override
  _HourlyWeatherListState createState() => _HourlyWeatherListState();
}

class _HourlyWeatherListState extends State<HourlyWeatherList> {
  List<HourlyWeatherData> hourlyData = [];
  Location location = Location();

  @override
  void initState() {
    super.initState();
    fetchLocationAndWeather();
  }

  Future<void> fetchLocationAndWeather() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Tarkista, ovatko sijaintipalvelut käytössä
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Pyydä sijaintioikeuksia
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Hae käyttäjän sijainti
    LocationData locationData = await location.getLocation();
    fetchHourlyWeatherData(locationData.latitude, locationData.longitude);
  }

  Future<void> fetchHourlyWeatherData(double? lat, double? lon) async {
    var url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=ae684053bd359fc697d2d89c798ccce2&units=metric';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var list = data['list'] as List;
      setState(() {
        hourlyData = list.map((item) => HourlyWeatherData.fromJson(item)).toList();
      });
    } else {
      print('Failed to fetch hourly weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyData.length,
        itemBuilder: (context, index) {
            return GestureDetector(
            onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DailyWeatherForecastPage()),
          );
        },
        child: HourlyWeatherItem(
        dateTime: hourlyData[index].dateTime, // Päivitetty käyttämään dateTime-muuttujaa
        icon: getWeatherIcon(hourlyData[index].condition),
        temperature: '${hourlyData[index].temperature}°C',
      ),
    );
  },
);
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
    return Icons.error;
  }
}

class HourlyWeatherData {
  final String dateTime;
  final int condition;
  final double temperature;

  HourlyWeatherData({required this.dateTime, required this.condition, required this.temperature});

  factory HourlyWeatherData.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['dt_txt']);
    String formattedDateTime = DateFormat('MMM d, H:mm').format(dateTime);

    return HourlyWeatherData(
      dateTime: formattedDateTime,
      condition: json['weather'][0]['id'],
      temperature: json['main']['temp'].toDouble(),
    );
  }
}

class HourlyWeatherItem extends StatelessWidget {
  final String dateTime; // Päivitetty muuttujan nimi
  final IconData icon;
  final String temperature;

  HourlyWeatherItem({required this.dateTime, required this.icon, required this.temperature}); // Päivitetty muuttujan nimi

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(dateTime, style: TextStyle(fontWeight: FontWeight.bold)), // Päivitetty näyttämään päivämäärä ja aika
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          Text(temperature),
        ],
      ),
    );
  }
}
