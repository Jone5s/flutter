import 'package:flutter/material.dart';
import 'weather_home_page.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: WeatherHomePage(),
    );
  }
}

/*
void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ThemeData().colorScheme.copyWith(secondary: Colors.blueAccent),
      ),
      home: WeatherHomePage(),
    );
  }
}

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


class WeatherInformation extends StatefulWidget {
  @override
  _WeatherInformationState createState() => _WeatherInformationState();
}

class _WeatherInformationState extends State<WeatherInformation> {
  String city = 'Tampere';
  String temperature = '';
  String description = '';
  IconData weatherIcon = Icons.wb_sunny;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    var url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=ae684053bd359fc697d2d89c798ccce2&units=metric';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        temperature = '${data['main']['temp']}°C';
        description = data['weather'][0]['description'];
        weatherIcon = getWeatherIcon(data['weather'][0]['id']);
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
          // Lisää muita päiviä tarvittaessa
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
*/