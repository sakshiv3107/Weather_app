// import 'dart:ffi';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/additional_information.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> _weatherFuture;
  String _cityName = 'London';

  @override
  void initState() {
    super.initState();
    _weatherFuture = getCurrentWeather();
  }

  IconData getWeatherIconWithTime(String condition, DateTime time) {
    int hour = time.hour;
    bool isNight = hour < 6 || hour >= 18;

    if (condition == 'Clear') {
      return isNight ? Icons.nightlight_round : Icons.wb_sunny;
    }
    if (condition == 'Clouds') {
      return isNight ? Icons.cloud : Icons.cloud_queue;
    }
    if (condition == 'Rain') return Icons.water_drop;
    if (condition == 'Thunderstorm') return Icons.thunderstorm;
    if (condition == 'Snow') return Icons.ac_unit;
    if (condition == 'Drizzle') return Icons.grain;

    return Icons.help_outline;
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    return getCurrentWeatherByCity(_cityName);
  }

  Future<Map<String, dynamic>> getCurrentWeatherByCity(String city) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') throw 'City not found';

      _cityName = city;
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Weather App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final city = await showDialog<String>(
                context: context,
                builder: (context) {
                  String inputCity = '';
                  return AlertDialog(
                    title: const Text("Enter City"),
                    content: TextField(
                      onChanged: (value) => inputCity = value,
                      decoration: const InputDecoration(hintText: "City name"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, inputCity),
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );

              if (city != null && city.trim().isNotEmpty) {
                setState(() {
                  _weatherFuture = getCurrentWeatherByCity(city.trim());
                });
              }
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _weatherFuture = getCurrentWeather());
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 50, color: Colors.red),
                    const SizedBox(height: 12),
                    const Text(
                      "Something went wrong",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _weatherFuture = getCurrentWeather();
                        });
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("No Data Found"));
            }

            // Extract data
            final data = snapshot.data!;
            final currentWeatherData = data['list'][0];

            final currentTemp = currentWeatherData['main']['temp'];
            final currentSky = currentWeatherData['weather'][0]['main'];
            final humidity = currentWeatherData['main']['humidity'];
            final windSpeed = currentWeatherData['wind']['speed'];
            final pressure = currentWeatherData['main']['pressure'];

            final currentTime = DateTime.parse(currentWeatherData['dt_txt']);
            final isNight = currentTime.hour < 6 || currentTime.hour >= 18;

            final gradientColors = isNight
                ? const [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364)
                  ]
                : const [
                    Color.fromARGB(255, 139, 213, 231),
                    Color(0xFF6dd5ed),
                  ];

            final currentTempC = currentTemp - 273.15;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),

              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // CURRENT WEATHER CARD
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '${currentTempC.toStringAsFixed(1)} °C',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _cityName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Icon(
                                  getWeatherIconWithTime(currentSky, currentTime),
                                  size: 70,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  currentSky,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // -------------------------------
                        // HOURLY FORECAST
                        // -------------------------------
                        const Text(
                          "Weather Forecast",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              final hourly = data['list'][index + 1];
                              final hourlySky = hourly['weather'][0]['main'];
                              final hourlyTemp = hourly['main']['temp'];
                              final hourlyTime =
                                  DateTime.parse(hourly['dt_txt']);

                              return HourlyForecastItem(
                                time: DateFormat.j().format(hourlyTime),
                                icon: getWeatherIconWithTime(
                                    hourlySky, hourlyTime),
                                temp:
                                    '${(hourlyTemp - 273.15).toStringAsFixed(1)} °C',
                                gradientColors: (hourlyTime.hour < 6 ||
                                        hourlyTime.hour >= 18)
                                    ? const [
                                        Color(0xFF0F2027),
                                        Color(0xFF203A43),
                                        Color(0xFF2C5364),
                                      ]
                                    : const [
                                        Color.fromARGB(255, 30, 122, 145),
                                        Color.fromARGB(255, 143, 207, 222),
                                      ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        
                        // ADDITIONAL INFORMATION

                        const Text(
                          "Additional Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // HUMIDITY
                            _buildInfoBox(
                              gradientColors,
                              InformationCard(
                                icon: Icons.water_drop,
                                label: "Humidity",
                                value: "$humidity%",
                              ),
                            ),

                            // WIND
                            _buildInfoBox(
                              gradientColors,
                              InformationCard(
                                icon: Icons.air,
                                label: "Wind",
                                value: "$windSpeed m/s",
                              ),
                            ),

                            // PRESSURE
                            _buildInfoBox(
                              gradientColors,
                              InformationCard(
                                icon: Icons.compress,
                                label: "Pressure",
                                value: "$pressure hPa",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoBox(List<Color> gradient, Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
