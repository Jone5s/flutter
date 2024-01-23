import 'package:flutter/material.dart';

class DailyWeatherForecastPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viikon Sääennuste'),
      ),
      body: ListView(
        children: <Widget>[
          WeatherListTile(day: 'Maanantai', weather: 'Aurinkoista', iconData: Icons.wb_sunny),
          WeatherListTile(day: 'Tiistai', weather: 'Pilvistä', iconData: Icons.wb_cloudy),
          WeatherListTile(day: 'Keskiviikko', weather: 'Sateista', iconData: Icons.beach_access),
          WeatherListTile(day: 'Torstai', weather: 'Sumuista', iconData: Icons.filter_drama),
          WeatherListTile(day: 'Perjantai', weather: 'Lumisadetta', iconData: Icons.ac_unit),
        ],
      ),
    );
  }
}

class WeatherListTile extends StatelessWidget {
  final String day;
  final String weather;
  final IconData iconData;

  WeatherListTile({required this.day, required this.weather, required this.iconData});

  @override
  Widget build(BuildContext context) {
    var accentColor2 = Theme.of(context).colorScheme.secondary;
    return ListTile(
      leading: Icon(iconData, color: accentColor2),
      title: Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(weather),
    );
  }
}