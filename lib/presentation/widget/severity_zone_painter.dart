import 'package:flutter/material.dart';

class SeverityZonePainterUtil {
  static const List<double> xValues = [0, 24, 48, 72, 96, 120,];

  /// Zones: lower -> upper boundaries
  static const List<double> lowRisk = [5, 6, 7.5, 8, 8.5, 8.5, 8.5];
  static const List<double> lowIntermediate = [6, 8, 10.5, 12, 13, 13.5, 14];
  static const List<double> highIntermediate = [8, 11, 13.5, 15.5, 16, 16.5, 17];
  static const List<double> highRisk = [20, 20, 20, 20, 20, 20, 20];

  static void drawSeverityZones(Canvas canvas, Size size,
      {double chartLeftPadding = 52,
        double chartRightPadding = 12,
        double chartTopPadding = 12,
        double chartBottomPadding = 52,
        double minX = 0,
        double maxX = 120,
        double minY = 0,
        double maxY = 20}) {
    final chartWidth = size.width - chartLeftPadding - chartRightPadding;
    final chartHeight = size.height - chartTopPadding - chartBottomPadding;

    double getX(double age) =>
        chartLeftPadding + chartWidth * (age - minX) / (maxX - minX);
    double getY(double bilirubin) =>
        chartTopPadding + chartHeight * (1 - bilirubin / maxY);

    final paintLow = Paint()..color = Colors.white38;
    final paintLowInt = Paint()..color = Colors.greenAccent.withOpacity(0.5);
    final paintHighInt = Paint()..color = Colors.orange.withOpacity(0.5);
    final paintHigh = Paint()..color = Colors.red.withOpacity(0.5);

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

    // Clip the chart area
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        chartLeftPadding, chartTopPadding, chartWidth, chartHeight));

    // Draw in correct stacking order
    drawZone(lowRisk, lowIntermediate, paintLowInt);
    drawZone(lowIntermediate, highIntermediate, paintHighInt);
    drawZone(highIntermediate, highRisk, paintHigh);

    // Fill below low risk
    final lowPath = Path()..moveTo(getX(xValues[0]), getY(minY));
    for (int i = 0; i < xValues.length; i++) {
      lowPath.lineTo(getX(xValues[i]), getY(lowRisk[i]));
    }
    lowPath.lineTo(getX(xValues.last), getY(minY));
    lowPath.close();
    canvas.drawPath(lowPath, paintLow);

    canvas.restore();
  }
}
