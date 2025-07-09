import 'dart:typed_data';
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/presentation/widget/bilirubin_report_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(
    bodyFontString,
    baseTextTheme,
  );
  TextTheme displayTextTheme = GoogleFonts.getTextTheme(
    displayFontString,
    baseTextTheme,
  );
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}

class Utilities {
  static String formatDateTime(DateTime dateTime) {
    final formatted = DateFormat('dd-MM-yyyy \'at\' hh:mm a').format(dateTime);
    return formatted;
  }

  static double getAgeInHours(DateTime dob, DateTime createdAt) {
    if (dob.isAfter(createdAt)) return 0;
    return createdAt.difference(dob).inHours.toDouble();
  }

  static String formatDate(DateTime dateTime) {
    final formatted = DateFormat('dd-MM-yyyy').format(dateTime);
    return formatted;
  }

  static Future<Uint8List> getChartImage(List<TestModel> tests) async {
    try {
      return await SimpleChartImageService.chartToImage(
        tests: tests,
        width: 800,
        height: 600,
      );
    } catch (e) {
      print('Simple chart conversion failed: $e');
      return await ChartImageFromPainter.generateChartImage(
        tests: tests,
        width: 800,
        height: 600,
      );
    }
  }

  static Future<void> shareReport({
    required MotherModel mother,
    required List<TestModel> tests,
    required BuildContext context,
  }) async {
    try {
      final chartImage = await getChartImage(tests);
      await BilirubinPdfService.sharePdf(
        mother: mother,
        tests: tests,
        chartImageBytes: chartImage,
      );
    } catch (e) {
      _showError(context, 'Share failed: $e');
    }
  }

  static Future<void> printReport({
    required MotherModel mother,
    required List<TestModel> tests,
    required BuildContext context,
  }) async {
    try {
      final chartImage = await getChartImage(tests);
      await BilirubinPdfService.printPdf(
        mother: mother,
        tests: tests,
        chartImageBytes: chartImage,
      );
    } catch (e) {
      _showError(context, 'Print failed: $e');
    }
  }

  static Future<void> saveReport({
    required MotherModel mother,
    required List<TestModel> tests,
    required BuildContext context,
  }) async {
    try {
      final chartImage = await getChartImage(tests);
      final filePath = await BilirubinPdfService.savePdfPermanently(
        mother: mother,
        tests: tests,
        chartImageBytes: chartImage,
      );
      _showSuccess(context, 'Report saved to: $filePath');
    } catch (e) {
      _showError(context, 'Save failed: $e');
    }
  }

  static Future<void> previewReport({
    required MotherModel mother,
    required List<TestModel> tests,
    required BuildContext context,
  }) async {
    try {
      final chartImage = await getChartImage(tests);
      await BilirubinPdfService.previewPdf(
        mother: mother,
        tests: tests,
        chartImageBytes: chartImage,
      );
      _showSuccess(context, 'Preview opened');
    } catch (e) {
      _showError(context, 'Preview failed: $e');
    }
  }

  static void _showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
