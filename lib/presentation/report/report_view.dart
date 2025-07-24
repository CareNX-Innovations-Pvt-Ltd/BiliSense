import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/core/util.dart';
import 'package:bili_sense/presentation/widget/bilirubin_chart.dart';
import 'package:bili_sense/presentation/widget/legend_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ReportView extends StatelessWidget {
  final List<TestModel> tests;
  final MotherModel motherModel;
  final TestModel? selectedTest;

  const ReportView({super.key, required this.tests, required this.motherModel, this.selectedTest});

  String _getRiskLevel(double age, double value) {
    if (age <= 24) {
      return value > 6 ? "High" : "Low";
    } else if (age <= 48) {
      return value > 10 ? "High" : "Low";
    } else if (age <= 72) {
      return value > 12 ? "High" : "Low";
    } else {
      if (value > 20) return "High";
      if (value > 15) return "Moderate";
      return "Low";
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case "High":
        return Colors.red;
      case "Moderate":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case "High":
        return Icons.warning;
      case "Moderate":
        return Icons.error_outline;
      default:
        return Icons.check_circle;
    }
  }

  String _formatLastTestDate(DateTime testDate) {
    final now = DateTime.now();
    final isToday =
        now.year == testDate.year &&
        now.month == testDate.month &&
        now.day == testDate.day;

    final timeFormat = DateFormat('hh:mm a');

    if (isToday) {
      return 'Today, ${timeFormat.format(testDate)}';
    } else {
      return DateFormat('d MMM yyyy, hh:mm a').format(testDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bilirubin Trend Report", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
          elevation: 5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                _buildPatientInfo(motherModel),
                SizedBox(height: 30),
                if (tests.isNotEmpty)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: BilirubinChart(tests: tests, highlightedTest: selectedTest,),
                      ),
                      SizedBox(height: 10),
                      _buildLegend(),
                    ],
                  ),
                _buildResultsSection(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Visibility(
          visible: tests.isNotEmpty,
          child: Container(
            color: Colors.teal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 30),
                  tooltip: "Share Report",
                  onPressed: () async {
                    Utilities.shareReport(
                      mother: motherModel,
                      tests: tests,
                      context: context,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.print, color: Colors.white, size: 30),
                  tooltip: "Print Report",
                  onPressed: () async {
                    Utilities.printReport(
                      mother: motherModel,
                      tests: tests,
                      context: context,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo(MotherModel motherModel) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Mother Name', motherModel.motherName),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Age',
                  '${Utilities.getAgeInHours(motherModel.dob, DateTime.now())} hours',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Birth Weight',
                  '${motherModel.weight ?? 0.0} kg',
                ),
              ),
              Expanded(
                child: _buildInfoItem('Gender of newborn', motherModel.gender),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoItem(
            'Last Test',
            tests.isNotEmpty
                ? _formatLastTestDate(tests.last.createdAt)
                : 'No test available',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    if (tests.isEmpty) {
      return const Center(child: Text('No test data available'));
    }

    final latestTest = tests.last;
    final latestLevel = latestTest.bilirubinReading;
    final peakLevel = tests
        .map((t) => t.bilirubinReading)
        .reduce((a, b) => a > b ? a : b);

    // Get trend: increasing or decreasing
    String trend = "Stable";
    if (tests.length >= 2) {
      final diff = latestLevel - tests[tests.length - 2].bilirubinReading;
      trend =
          diff > 0.5
              ? "Increasing"
              : diff < -0.5
              ? "Decreasing"
              : "Stable";
    }

    // Get risk level based on age
    final ageHours = Utilities.getAgeInHours(
      latestTest.dob,
      latestTest.createdAt,
    );
    final riskLevel = _getRiskLevel(ageHours, latestLevel);
    final riskColor = _getRiskColor(riskLevel);
    final riskIcon = _getRiskIcon(riskLevel);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  'Current Level',
                  '${latestLevel.toStringAsFixed(1)} mg/dL',
                  Colors.blue,
                  Icons.opacity,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultCard(
                  'Risk Level',
                  riskLevel,
                  riskColor,
                  riskIcon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  'Peak Level',
                  '${peakLevel.toStringAsFixed(1)} mg/dL',
                  Colors.orange,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultCard(
                  'Trend',
                  trend,
                  trend == "Increasing"
                      ? Colors.red
                      : trend == "Decreasing"
                      ? Colors.green
                      : Colors.grey,
                  trend == "Increasing"
                      ? Icons.arrow_upward
                      : trend == "Decreasing"
                      ? Icons.arrow_downward
                      : Icons.trending_flat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    String label,
    String value,
    Color? color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color!.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Align(
      alignment: Alignment.center,
      child: Wrap(
        spacing: 42,
        runSpacing: 10,
        children: const [
          LegendItem(color: Colors.redAccent, label: "High Risk"),
          LegendItem(
            color: Colors.orangeAccent,
            label: "High Intermediate Risk",
          ),
          LegendItem(color: Colors.greenAccent, label: "Low Intermediate Risk"),
          LegendItem(color: Colors.white, label: "Low Risk"),
        ],
      ),
    );
  }
}
