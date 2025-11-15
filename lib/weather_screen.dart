// import 'dart:ffi';
import 'dart:convert';
import 'dart:ui';
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
  @override
  void initState() {
    super.initState();
    _weatherFuture = getCurrentWeather(); // initial load
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&appid=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occured';
      }
      return data;
      // temp = data['list'][0]['main']['temp'];
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Weather App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        // GestureDetector(
        //   onTap: () {
        //     // Add your onTap code here!
        //   },
        //   child: const Icon(Icons.refresh),
        // ),
        // IconButton(
        //   onPressed: () {
        //     setState(() {
        //       _weatherFuture = getCurrentWeather();
        //     });
        //   },
        //   icon: const Icon(Icons.refresh),
        // ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _weatherFuture = getCurrentWeather();
          });
          // await Future.delayed(const Duration(milliseconds: 800));
        },
        child: FutureBuilder(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final data = snapshot.data!;
            final currentWeatherData = data['list'][0];

            final currentTemp = currentWeatherData['main']['temp'];
            final currentSky = currentWeatherData['weather'][0]['main'];

            final humidity = currentWeatherData['main']['humidity'];
            final windSpeed = currentWeatherData['wind']['speed'];
            final pressure = currentWeatherData['main']['pressure'];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$currentTemp K',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 14),
                                    Icon(
                                      currentSky == 'Clouds' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 60,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      currentSky,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Hourly forecast section
                      const Text(
                        'Weather Forecast',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      //SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     child: Row(
                      //       children: [
                      //         for(int i=1;i<=5;i++)
                      //           HourlyForecastItem(
                      //             time: data['list'][i]['dt_txt'].substring(11, 16),

                      //             icon:
                      //               data['list'][i]['weather'][0]['main']=='Clouds' || data['list'][i]['weather'][0]['main']=='Rain'? Icons.cloud:Icons.sunny
                      //             ,
                      //             temp: data['list'][i]['main']['temp'].toString(),
                      //           ),

                      //       ],
                      //     ),
                      //   ),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final hourlyForecast = data['list'][index + 1];
                            final hourlySky = hourlyForecast['weather'][0]['main'];
                            final hourlyTemp = hourlyForecast['main']['temp']; 
                            final hourlyTime =DateTime.parse(hourlyForecast['dt_txt']);
                            return HourlyForecastItem(
                              time: DateFormat.j().format(hourlyTime),
                              icon:hourlySky=='Clouds' ||
                                      hourlySky==
                                          'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              temp: hourlyTemp.toString(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Additional Information
                      Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        // width: ,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InformationCard(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: "$humidity",
                            ),
                            InformationCard(
                              icon: Icons.air,
                              label: 'Wind Speed',
                              value: "$windSpeed",
                            ),
                            InformationCard(
                              icon: Icons.beach_access,
                              label: 'Pressure',
                              value: "$pressure",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
