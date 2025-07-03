import 'package:flutter/material.dart';

class BilirubinCircularCard extends StatelessWidget {
  final double bilirubinReading;
  final int completedTests; // 1 to 3
  final String severityLabel;
  final IconData icon;

  const BilirubinCircularCard({
    super.key,
    required this.bilirubinReading,
    required this.completedTests,
    required this.severityLabel,
    this.icon = Icons.water_drop_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (completedTests / 3).clamp(0.0, 1.0);
    final Color severityColor = _getSeverityColor(bilirubinReading);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 32),
          padding: const EdgeInsets.only(top: 35),
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: severityColor, width: 10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                bilirubinReading.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text("mg/dL", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                severityLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: severityColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$completedTests of 3 Tests",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 28,
              backgroundColor: severityColor,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(double value) {
    if (value >= 15) return Colors.red;
    if (value >= 10) return Colors.orange;
    return Colors.green;
  }
}