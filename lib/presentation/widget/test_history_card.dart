import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bili_sense/core/models/test_model.dart';

class TestHistoryCard extends StatelessWidget {
  final TestModel test;
  final void Function()? onTap;

  const TestHistoryCard({super.key, required this.test, this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd-MM-yyyy – hh:mm a').format(test.createdAt);
    int getAgeInHours(DateTime dob) {
      final now = DateTime.now();
      if (dob.isAfter(now)) return 0;
      return now.difference(dob).inHours;
    }



    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Name & Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    test.motherName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(
                      "${test.bilirubinReading.toStringAsFixed(2)} mg/dL",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getSeverityColor(test.bilirubinReading),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Sub Row
              Row(
                children: [
                  const Icon(Icons.cake, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text("Age: ${getAgeInHours(test.dob)} hours"),
                  const SizedBox(width: 16),
                  const Icon(Icons.monitor_heart, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text("Weight: ${test.weight} kg"),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text("Tested on: $date"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Return color based on severity of bilirubin
Color _getSeverityColor(double value) {
  if (value >= 15.0) {
    return Colors.red;
  } else if (value >= 10.0) {
    return Colors.orangeAccent;
  } else {
    return Colors.green;
  }
}
