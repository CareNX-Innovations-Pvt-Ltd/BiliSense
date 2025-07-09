import 'package:bili_sense/presentation/widget/bilirubin_report_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'dart:typed_data';

class BilirubinReportActionsV2 extends StatefulWidget {
  final MotherModel mother;
  final List<TestModel> tests;

  const BilirubinReportActionsV2({
    super.key,
    required this.mother,
    required this.tests,
  });

  @override
  State<BilirubinReportActionsV2> createState() => _BilirubinReportActionsV2State();
}

class _BilirubinReportActionsV2State extends State<BilirubinReportActionsV2> {
  bool _isProcessing = false;
  Uint8List? _chartImageCache;

  /// Generate chart image and cache it
  Future<Uint8List> _getChartImage() async {
    if (_chartImageCache != null) return _chartImageCache!;

    try {
      // Try the simple approach first
      _chartImageCache = await SimpleChartImageService.chartToImage(
        tests: widget.tests,
        width: 800,
        height: 600,
      );
    } catch (e) {
      // Fallback to custom painter approach
      print('Simple chart conversion failed: $e');
      _chartImageCache = await ChartImageFromPainter.generateChartImage(
        tests: widget.tests,
        width: 800,
        height: 600,
      );
    }

    return _chartImageCache!;
  }

  Future<void> _shareReport() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final chartImage = await _getChartImage();

      await BilirubinPdfService.sharePdf(
        mother: widget.mother,
        tests: widget.tests,
        chartImageBytes: chartImage,
      );

      _showSuccessMessage('Report shared successfully');
    } catch (e) {
      _showErrorMessage('Share failed: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _printReport() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final chartImage = await _getChartImage();

      await BilirubinPdfService.printPdf(
        mother: widget.mother,
        tests: widget.tests,
        chartImageBytes: chartImage,
      );

      _showSuccessMessage('Print dialog opened');
    } catch (e) {
      _showErrorMessage('Print failed: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveReport() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final chartImage = await _getChartImage();

      final filePath = await BilirubinPdfService.savePdfPermanently(
        mother: widget.mother,
        tests: widget.tests,
        chartImageBytes: chartImage,
      );

      _showSuccessMessage('Report saved to: $filePath');
    } catch (e) {
      _showErrorMessage('Save failed: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _previewReport() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final chartImage = await _getChartImage();

      await BilirubinPdfService.previewPdf(
        mother: widget.mother,
        tests: widget.tests,
        chartImageBytes: chartImage,
      );

      _showSuccessMessage('Preview opened');
    } catch (e) {
      _showErrorMessage('Preview failed: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'PDF Report Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isProcessing)
              Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Processing chart and generating PDF...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _previewReport,
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _shareReport,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _printReport,
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveReport,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              'Report for: ${widget.mother.motherName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Tests: ${widget.tests.length} | Latest: ${widget.tests.last.bilirubinReading.toStringAsFixed(2)} mg/dL',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
