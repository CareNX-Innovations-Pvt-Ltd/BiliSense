import 'package:bili_sense/core/models/test_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TestCard extends StatelessWidget {
  final TestModel test;
  final void Function()? onTap;

  const TestCard({super.key, required this.test, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat(
      'dd-MM-yyyy – hh:mm a',
    ).format(test.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Test for ${test.motherName.trim().split(' ')[0]}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(
                      "${test.bilirubinReading.toStringAsFixed(2)} mg/dL",
                    ),
                    backgroundColor: _getSeverityColor(test.bilirubinReading),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /// Weight & DOB Info Row
              Row(
                children: [
                  const Icon(Icons.monitor_weight, size: 20),
                  const SizedBox(width: 6),
                  Text("Weight: ${test.weight} kg"),
                  const SizedBox(width: 20),
                  // const Icon(Icons.cake, color: Colors.grey, size: 20),
                  // const SizedBox(width: 6),
                  // Text("DOB: ${test.dob}"),
                ],
              ),
              const SizedBox(height: 12),

              /// Date
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 6),
                  Text("Admitted on: $formattedDate"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _getSeverityColor(double value) {
  if (value >= 15.0) {
    return Colors.red; // High
  } else if (value >= 10.0) {
    return Colors.orangeAccent; // Moderate
  } else {
    return Colors.green; // Normal
  }
}
