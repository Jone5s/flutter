import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'location_service.dart';

class DailyWeatherForecastPage extends StatefulWidget {
  @override
  _DailyWeatherForecastPageState createState() => _DailyWeatherForecastPageState();
}

class _DailyWeatherForecastPageState extends State<DailyWeatherForecastPage> {
  List<dynamic> dailyForecasts = [];
  Location location = new Location();

  @override
void initState() {
  super.initState();
  // Use the LocationService to get the location
  LocationData? locationData = LocationService().currentLocation;
  if (locationData != null) {
    fetchWeatherData(locationData.latitude, locationData.longitude);
  }
}

  Future<void> fetchWeatherData(double? latitude, double? longitude) async {
    var url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=17af1c99046fbad53238fe59ce1993e6&units=metric';
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
