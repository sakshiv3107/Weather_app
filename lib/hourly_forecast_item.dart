import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  const HourlyForecastItem({super.key, required this.time , required this.icon, required this.temp});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Icon(icon),
              SizedBox(height: 5),
              Text(temp),
            ],
          ),
        ),
      ),
    );
  }
}
