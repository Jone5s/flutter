import 'package:flutter/material.dart';
import 'weather_information.dart';
import 'hourly_weather_list.dart';

class WeatherHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sääsovellus'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: WeatherInformation(),
              flex: 2,
            ),
            Expanded(
              child: HourlyWeatherList(),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
