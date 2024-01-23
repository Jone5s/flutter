import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'daily_weather_forecast_page.dart';

class HourlyWeatherList extends StatefulWidget {
  @override
  _HourlyWeatherListState createState() => _HourlyWeatherListState();
}

class _HourlyWeatherListState extends State<HourlyWeatherList> {
  List<HourlyWeatherData> hourlyData = [];

  @override
  void initState() {
    super.initState();
    fetchHourlyWeatherData();
  }

  Future<void> fetchHourlyWeatherData() async {
    var url = 'https://api.openweathermap.org/data/2.5/forecast?q=Tampere&appid=ae684053bd359fc697d2d89c798ccce2&units=metric';
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
            time: hourlyData[index].time,
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
  final String time;
  final int condition;
  final double temperature;

  HourlyWeatherData({required this.time, required this.condition, required this.temperature});

  factory HourlyWeatherData.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['dt_txt']);
    String formattedTime = DateFormat('H').format(dateTime); // Vain tunnin näyttäminen

    return HourlyWeatherData(
      time: formattedTime,
      condition: json['weather'][0]['id'],
      temperature: json['main']['temp'].toDouble(),
    );
  }
}

class HourlyWeatherItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temperature;

  HourlyWeatherItem({required this.time, required this.icon, required this.temperature});

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
          Text(time, style: TextStyle(fontWeight: FontWeight.bold)),
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          Text(temperature),
        ],
      ),
    );
  }
}