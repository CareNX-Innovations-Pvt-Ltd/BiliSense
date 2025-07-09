import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:bili_sense/core/models/test_model.dart';

class BilirubinChart extends StatelessWidget {
  final List<TestModel> tests;

  const BilirubinChart({super.key, required this.tests});

  double _getAgeInHours(DateTime dob, DateTime createdAt) {
    if (dob.isAfter(createdAt)) return 0;
    return createdAt.difference(dob).inHours.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots =
        tests.map((test) {
            final age = _getAgeInHours(test.dob, test.createdAt);
            return FlSpot(age, test.bilirubinReading);
          }).toList()
          ..sort((a, b) => a.x.compareTo(b.x));

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          CustomPaint(painter: SeverityZonePainter(), size: Size.infinite),
          LineChart(
            LineChartData(
              minX: 0,
              maxX: 120,
              minY: 0,
              maxY: 25,

              // Line plot
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.black,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  curveSmoothness: 0.2,
                ),
              ],

              // Axes Titles
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20, // Increased from 20
                    interval: 5,
                    getTitlesWidget:
                        (value, meta) => Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            "${value.toInt()}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                  ),
                  axisNameWidget: Text(
                    "Bilirubin (mg/dL)",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  axisNameSize: 30,
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 24,
                    getTitlesWidget:
                        (value, meta) => Text(
                          "${value.toInt()}h",
                          style: const TextStyle(fontSize: 12),
                        ),
                  ),
                  axisNameWidget: Text(
                    "Age (hours)",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  axisNameSize: 30,
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ],
      ),
    );
  }
}

class SeverityZonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const chartLeftPadding = 50.0;
    const chartRightPadding = 2.0;
    const chartTopPadding = 0.0;
    const chartBottomPadding = 52.0;

    final chartWidth = size.width - chartLeftPadding - chartRightPadding;
    final chartHeight = size.height - chartTopPadding - chartBottomPadding;

    const minX = 12.0;
    const maxX = 144.0;
    const minY = 0.0;
    const maxY = 20.0;

    double getX(double age) =>
        chartLeftPadding + chartWidth * (age - minX) / (maxX - minX);
    double getY(double bilirubin) =>
        chartTopPadding + chartHeight * (1 - bilirubin / maxY);

    final paintLow = Paint()..color = Colors.white;
    final paintLowInt = Paint()..color = Colors.greenAccent.withOpacity(0.5);
    final paintHighInt = Paint()..color = Colors.yellow.withOpacity(0.5);
    final paintHigh = Paint()..color = Colors.red.withOpacity(0.5);

    final List<double> xValues = [12, 24, 48, 72, 96, 120, 144];

    // Approximate zone boundaries from chart
    final List<double> lowRisk = [5, 6, 7.5, 8, 8.5, 8.5, 8.5];
    final List<double> lowIntermediate = [6, 8, 10.5, 12, 13, 13.5, 14];
    final List<double> highIntermediate = [8, 11, 13.5, 15.5, 16, 16.5, 17];
    final List<double> highRisk = [20, 20, 20, 20, 20, 20, 20];

    // Function to draw a polygon zone
    void drawZone(List<double> lower, List<double> upper, Paint paint) {
      final path = Path()..moveTo(getX(xValues[0]), getY(lower[0]));
      for (int i = 1; i < xValues.length; i++) {
        path.lineTo(getX(xValues[i]), getY(lower[i]));
      }
      for (int i = xValues.length - 1; i >= 0; i--) {
        path.lineTo(getX(xValues[i]), getY(upper[i]));
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(chartLeftPadding, chartTopPadding, chartWidth, chartHeight),
    );

    drawZone(lowRisk, lowIntermediate, paintLowInt); // Green zone
    drawZone(lowIntermediate, highIntermediate, paintHighInt); // Orange zone
    drawZone(highIntermediate, highRisk, paintHigh); // Red zone

    // Fill under lowRisk as white
    final lowPath = Path()..moveTo(getX(xValues[0]), getY(minY));
    for (int i = 0; i < xValues.length; i++) {
      lowPath.lineTo(getX(xValues[i]), getY(lowRisk[i]));
    }
    lowPath.lineTo(getX(xValues.last), getY(minY));
    lowPath.close();
    canvas.drawPath(lowPath, paintLow);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
