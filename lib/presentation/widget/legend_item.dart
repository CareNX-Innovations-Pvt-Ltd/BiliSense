import 'package:flutter/material.dart';

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}