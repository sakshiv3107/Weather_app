import 'package:flutter/material.dart';

class InformationCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InformationCard({super.key, required this.icon, required this.label,required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28),
        SizedBox(height: 5),
        Text(label),
        SizedBox(height: 5),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
