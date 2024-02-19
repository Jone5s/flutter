import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class DailyWeatherForecastPage extends StatefulWidget {
  @override
  _DailyWeatherForecastPageState createState() => _DailyWeatherForecastPageState();
}

class _DailyWeatherForecastPageState extends State<DailyWeatherForecastPage> {
  List<dynamic> dailyForecasts = [];
  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  @override
  void initState() {
    super.initState();
    fetchLocationAndWeather();
  }

  Future<void> fetchLocationAndWeather() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    fetchWeatherData(_locationData.latitude, _locationData.longitude);
  }

  Future<void> fetchWeatherData(double? latitude, double? longitude) async {
    var url = 'https://api.openweathermap.org/data/2.5/forecast?q=Tampere&appid=ae684053bd359fc697d2d89c798ccce2&units=metric';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var list = data['list'] as List;
      
      // Aggregoi päivittäiset ennusteet
      Map<String, Map<String, dynamic>> aggregatedData = {};
      for (var item in list) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        String day = DateFormat('EEEE').format(date);

        if (!aggregatedData.containsKey(day)) {
          aggregatedData[day] = {
            'temps': [],
            'condition': item['weather'][0]['id'],
          };
        }
        aggregatedData[day]?['temps'].add(item['main']['temp']);
      }

      setState(() {
        dailyForecasts = aggregatedData.entries.map((entry) {
          var day = entry.key;
          var condition = entry.value['condition'];
          var avgTemp = entry.value['temps'].reduce((a, b) => a + b) / entry.value['temps'].length;

          return WeatherListTile(
            day: day,
            weather: 'Keskim. lämpötila: ${avgTemp.toStringAsFixed(1)}°C',
            condition: condition,
          );
        }).toList();
      });
    } else {
      print('Failed to fetch weather data');
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
    return Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viikon Sääennuste'),
      ),
      body: ListView.builder(
        itemCount: dailyForecasts.length,
        itemBuilder: (context, index) {
          return dailyForecasts[index];
        },
      ),
    );
  }
}

class WeatherListTile extends StatelessWidget {
  final String day;
  final String weather;
  final int condition;

  WeatherListTile({required this.day, required this.weather, required this.condition});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_DailyWeatherForecastPageState().getWeatherIcon(condition), color: Theme.of(context).colorScheme.secondary),
      title: Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(weather),
    );
  }
}
