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
  WidgetsBinding.instance.addPostFrameCallback((_) {
    LocationData? locationData = LocationService().currentLocation;
    if (locationData != null) {
      fetchWeatherData(locationData.latitude, locationData.longitude, context);
    }
  });
}

  Future<void> fetchWeatherData(double? latitude, double? longitude, BuildContext context) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch weather data. Please try again later.'),
          duration: Duration(seconds: 5), // Adjust duration as needed
        ),
      );
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
        backgroundColor: Colors.blueGrey, // Change as per your theme
        elevation: 0,
      ),
      body: dailyForecasts.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator when data is being fetched
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: dailyForecasts.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2, // Adds a subtle shadow to each list item
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      leading: Icon(_DailyWeatherForecastPageState().getWeatherIcon(dailyForecasts[index].condition), color: Theme.of(context).colorScheme.secondary),
                      title: Text(
                        dailyForecasts[index].day,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(dailyForecasts[index].weather),
                    ),
                  );
                },
              ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Use colors that represent the weather condition or temperature; adjust as needed
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
        ),
      ),
      child: ListTile(
        leading: Icon(_DailyWeatherForecastPageState().getWeatherIcon(condition), size: 36, color: Colors.white),
        title: Text(
          day,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          weather,
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
