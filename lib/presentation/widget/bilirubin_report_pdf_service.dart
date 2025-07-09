import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bili_sense/presentation/widget/bilirubin_chart.dart';
import 'package:bili_sense/presentation/widget/pdf_base_page.dart';
import 'package:bili_sense/presentation/widget/severity_zone_painter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:share_plus/share_plus.dart';

class BilirubinPdfService {
  /// Generates a PDF document from the bilirubin test data
  static Future<Uint8List> generatePdf({
    required MotherModel mother,
    required List<TestModel> tests,
    Uint8List? chartImageBytes,
  }) async {
    Uint8List finalChartBytes;
    if (chartImageBytes != null) {
      finalChartBytes = chartImageBytes;
    } else {
      finalChartBytes = await ChartToImageService.convertChartToImage(
        tests: tests,
        width: 600,
        height: 400,
      );
    }
    final pdf = pw.Document();

    // Add the page to the PDF document
    pdf.addPage(
      PdfBasePage.generate(
        mother: mother,
        tests: tests,
        chartImageBytes: finalChartBytes,
        page: 1,
        total: 1,
      ),

    );

    // Return the PDF as bytes
    return await pdf.save();
  }

  /// Saves the PDF to device storage and returns the file path
  static Future<String> savePdfToDownloads(Uint8List pdfBytes, String fileName) async {
    Directory? downloadsDir;

    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();

      if (status != PermissionStatus.granted) {
        throw Exception("Storage permission denied. Cannot save file.");
      }

      downloadsDir = await getExternalStorageDirectory();
      print('Saving PDF to: ${downloadsDir?.path}');


    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory(); // iOS doesn't expose Downloads folder
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      downloadsDir = await getDownloadsDirectory(); // Desktop platforms
    } else {
      throw UnsupportedError("Unsupported platform.");
    }

    final file = File('${downloadsDir!.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);

    return file.path;
  }

  /// Shares the PDF using the device's share functionality
  static Future<void> sharePdf({
    required MotherModel mother,
    required List<TestModel> tests,
    required Uint8List chartImageBytes,
  }) async {
    try {
      final pdfBytes = await generatePdf(
        mother: mother,
        tests: tests,
        chartImageBytes: chartImageBytes,
      );

      final directory = await getTemporaryDirectory();
      final fileName =
          'bilirubin_report_${mother.motherName}_${DateTime.now().millisecondsSinceEpoch}';
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Bilirubin Report for ${mother.motherName}',
        subject: 'Bilirubin Test Report',
      );
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }

  /// Opens the print dialog for the PDF
  static Future<void> printPdf({
    required MotherModel mother,
    required List<TestModel> tests,
    required Uint8List chartImageBytes,
  }) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return await generatePdf(
            mother: mother,
            tests: tests,
            chartImageBytes: chartImageBytes,
          );
        },
      );
    } catch (e) {
      throw Exception('Failed to print PDF: $e');
    }
  }

  /// Saves PDF to device storage permanently
  static Future<String> savePdfPermanently({
    required MotherModel mother,
    required List<TestModel> tests,
    required Uint8List chartImageBytes,
  }) async {
    try {
      // Generate PDF
      final pdfBytes = await generatePdf(
        mother: mother,
        tests: tests,
        chartImageBytes: chartImageBytes,
      );

      final fileName =
          'bilirubin_report_${mother.motherName}_${DateTime.now().millisecondsSinceEpoch}';

      final filePath = await savePdfToDownloads(pdfBytes, fileName);

      return filePath;
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }

  /// Preview PDF before sharing or printing
  static Future<void> previewPdf({
    required MotherModel mother,
    required List<TestModel> tests,
    required Uint8List chartImageBytes,
  }) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return await generatePdf(
            mother: mother,
            tests: tests,
            chartImageBytes: chartImageBytes,
          );
        },
      );
    } catch (e) {
      throw Exception('Failed to preview PDF: $e');
    }
  }
}

class BilirubinReportHandler {
  final MotherModel mother;
  final List<TestModel> tests;
  final Uint8List chartImageBytes;

  BilirubinReportHandler({
    required this.mother,
    required this.tests,
    required this.chartImageBytes,
  });

  /// Share the report
  Future<void> shareReport() async {
    await BilirubinPdfService.sharePdf(
      mother: mother,
      tests: tests,
      chartImageBytes: chartImageBytes,
    );
  }

  /// Print the report
  Future<void> printReport() async {
    await BilirubinPdfService.printPdf(
      mother: mother,
      tests: tests,
      chartImageBytes: chartImageBytes,
    );
  }

  /// Save the report to device
  Future<String> saveReport() async {
    return await BilirubinPdfService.savePdfPermanently(
      mother: mother,
      tests: tests,
      chartImageBytes: chartImageBytes,
    );
  }

  /// Preview the report
  Future<void> previewReport() async {
    await BilirubinPdfService.previewPdf(
      mother: mother,
      tests: tests,
      chartImageBytes: chartImageBytes,
    );
  }
}

class SimpleChartImageService {
  /// Converts BilirubinChart to image bytes using a simple approach
  static Future<Uint8List> chartToImage({
    required List<TestModel> tests,
    double width = 600,
    double height = 400,
  }) async {
    // Create a widget that can be rendered independently
    final chartWidget = _ChartRenderer(
      tests: tests,
      width: width,
      height: height,
    );

    // Convert to image
    return await _widgetToImage(chartWidget, width, height);
  }

  static Future<Uint8List> _widgetToImage(
    Widget widget,
    double width,
    double height,
  ) async {
    final repaintBoundary = RepaintBoundary(
      child: SizedBox(width: width, height: height, child: widget),
    );

    final renderRepaintBoundary = RenderRepaintBoundary();
    final renderView = RenderView(
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tightFor(
          width: width,
          height: height,
        ),
        physicalConstraints: BoxConstraints.tightFor(
          width: width * 1.0, // Use devicePixelRatio of 1.0 for simplicity
          height: height * 1.0,
        ),
        devicePixelRatio: 1.0,
      ),
      view: WidgetsBinding.instance.platformDispatcher.views.first,
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    renderView.child = renderRepaintBoundary;

    final adapter = RenderObjectToWidgetAdapter<RenderBox>(
      container: renderRepaintBoundary,
      debugShortDescription: '[root]',
      child: repaintBoundary,
    );

    final element = adapter.attachToRenderTree(buildOwner);

    try {
      buildOwner.buildScope(element);
      buildOwner.finalizeTree();

      renderView.prepareInitialFrame();
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      final image = await renderRepaintBoundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData!.buffer.asUint8List();
    } finally {
      element.unmount();
    }
  }
}

/// A wrapper widget that provides MediaQuery context for the chart
class _ChartRenderer extends StatelessWidget {
  final List<TestModel> tests;
  final double width;
  final double height;

  const _ChartRenderer({
    required this.tests,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        devicePixelRatio: 2.0,
        textScaleFactor: 1.0,
        padding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        alwaysUse24HourFormat: false,
        accessibleNavigation: false,
        invertColors: false,
        highContrast: false,
        disableAnimations: false,
        boldText: false,
        navigationMode: NavigationMode.traditional,
        gestureSettings: const DeviceGestureSettings(touchSlop: 20),
        displayFeatures: const <ui.DisplayFeature>[],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.white,
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white),
            child: BilirubinChart(tests: tests),
          ),
        ),
      ),
    );
  }
}

/// Alternative approach using a custom painter
class ChartImageFromPainter {
  static Future<Uint8List> generateChartImage({
    required List<TestModel> tests,
    double width = 600,
    double height = 400,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw white background
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    // Use your custom painter
    final painter = BilirubinChartPainter(tests: tests);
    painter.paint(canvas, Size(width, height));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

class ChartToImageService {
  /// Converts the BilirubinChart widget to image bytes
  static Future<Uint8List> convertChartToImage({
    required List<TestModel> tests,
    double width = 600,
    double height = 400,
    double pixelRatio = 3.0,
  }) async {
    final GlobalKey repaintBoundaryKey = GlobalKey();

    final Widget chartWidget = MediaQuery(
      data: const MediaQueryData(
        size: Size(600, 400),
        devicePixelRatio: 2.0,
        textScaler: TextScaler.linear(1),
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          width: width,
          height: height,
          child: RepaintBoundary(
            key: repaintBoundaryKey,
            child: BilirubinChart(tests: tests),
          ),
        ),
      ),
    );

    final Widget appWidget = MaterialApp(
      home: Scaffold(backgroundColor: Colors.white, body: chartWidget),
      debugShowCheckedModeBanner: false,
    );

    return await _renderWidgetToImage(
      appWidget,
      repaintBoundaryKey,
      width: width,
      height: height,
      pixelRatio: pixelRatio,
    );
  }

  /// Alternative method using a more direct approach
  static Future<Uint8List> convertChartToImageDirect({
    required List<TestModel> tests,
    double width = 600,
    double height = 400,
    double pixelRatio = 2.0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final painter = BilirubinChartPainter(tests: tests);
    painter.paint(canvas, Size(width, height));

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (width * pixelRatio).toInt(),
      (height * pixelRatio).toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<Uint8List> _renderWidgetToImage(
    Widget widget,
    GlobalKey repaintBoundaryKey, {
    required double width,
    required double height,
    required double pixelRatio,
  }) async {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    WidgetsFlutterBinding.ensureInitialized();

    final renderView = RenderView(
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tightFor(
          width: width,
          height: height,
        ),
        physicalConstraints: BoxConstraints.tightFor(
          width: width * pixelRatio,
          height: height * pixelRatio,
        ),
        devicePixelRatio: pixelRatio,
      ),
      view: view,
    );

    final pipelineOwner = PipelineOwner();

    final buildOwner = BuildOwner(focusManager: FocusManager());

    final adapter = RenderObjectToWidgetAdapter<RenderBox>(
      container: renderView,
      debugShortDescription: '[root]',
      child: widget,
    );

    final element = adapter.attachToRenderTree(buildOwner);

    try {
      // Build and layout
      buildOwner.buildScope(element);
      buildOwner.finalizeTree();

      renderView.prepareInitialFrame();
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      // Get the render object
      final renderObject = element.renderObject as RenderRepaintBoundary?;

      if (renderObject != null) {
        final image = await renderObject.toImage(pixelRatio: pixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData!.buffer.asUint8List();
      }
    } finally {
      // Clean up
      element.unmount();
    }

    throw Exception('Failed to render widget to image');
  }
}

/// Custom painter version of your chart for direct rendering
class BilirubinChartPainter extends CustomPainter {
  final List<TestModel> tests;

  BilirubinChartPainter({required this.tests});

  double _getAgeInHours(DateTime dob, DateTime createdAt) {
    if (dob.isAfter(createdAt)) return 0;
    return createdAt.difference(dob).inHours.toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Layout constants
    const double topMargin = 40.0;
    const double leftMargin = 60.0;
    const double bottomMargin = 60.0;
    const double rightMargin = 40.0;

    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Fill background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw axes
    final axisPath = Path();
    axisPath.moveTo(leftMargin, topMargin);
    axisPath.lineTo(leftMargin, size.height - bottomMargin); // Y-axis
    axisPath.moveTo(leftMargin, size.height - bottomMargin);
    axisPath.lineTo(size.width - rightMargin, size.height - bottomMargin); // X-axis
    canvas.drawPath(axisPath, axisPaint);

    // Severity zones
    SeverityZonePainterUtil.drawSeverityZones(
      canvas,
      size,
      chartTopPadding: topMargin,
      chartBottomPadding: 100,
      chartLeftPadding: leftMargin,
      chartRightPadding: rightMargin,
      minX: 0,
      maxX: 120,
      minY: 0,
      maxY: 20,
    );

    // Grid, data, labels
    _drawGridLines(canvas, size, leftMargin, topMargin, rightMargin, bottomMargin);
    _drawDataPoints(canvas, size, leftMargin, topMargin, rightMargin, bottomMargin);
    _drawLabels(canvas, size, leftMargin, topMargin, rightMargin, bottomMargin);
  }

  void _drawGridLines(Canvas canvas, Size size, double left, double top, double right, double bottom) {
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    // X grid
    for (double x in [0, 24, 48, 72, 96, 120]) {
      final dx = left + (x / 120.0) * chartWidth;
      canvas.drawLine(Offset(dx, top), Offset(dx, size.height - bottom), gridPaint);
    }

    // Y grid
    for (double y in [0, 5, 10, 15, 20]) {
      final dy = top + (1 - y / 20.0) * chartHeight;
      canvas.drawLine(Offset(left, dy), Offset(size.width - right, dy), gridPaint);
    }
  }

  void _drawDataPoints(Canvas canvas, Size size, double left, double top, double right, double bottom) {
    if (tests.isEmpty) return;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final points = tests.map((test) {
      final age = _getAgeInHours(test.dob, test.createdAt);
      final x = left + (age / 120.0) * chartWidth;
      final y = size.height - bottom - (test.bilirubinReading / 20.0) * chartHeight;
      return Offset(x, y);
    }).toList()
      ..sort((a, b) => a.dx.compareTo(b.dx));

    // Draw lines
    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double left, double top, double right, double bottom) {
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final labelStyle = TextStyle(color: Colors.black, fontSize: 15);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // X-axis labels
    for (var tick in [0, 24, 48, 72, 96, 120]) {
      final x = left + ((tick) / 120.0) * chartWidth;
      final y = size.height - bottom;
      textPainter.text = TextSpan(text: tick.toString(), style: labelStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 6));
    }

    // Y-axis labels
    for (var tick in [0, 5, 10, 15, 20]) {
      final y = top + (1 - tick / 20.0) * chartHeight;
      final x = left;
      textPainter.text = TextSpan(text: tick.toString(), style: labelStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width - 8, y - textPainter.height / 2));
    }

    // X-axis title
    textPainter.text = const TextSpan(
      text: 'Age (hours)',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, size.height - 30));

    // Y-axis title (rotated)
    canvas.save();
    canvas.translate(20, size.height / 2);
    canvas.rotate(-3.14159 / 2);
    textPainter.text = const TextSpan(
      text: 'Bilirubin (mg/dL)',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
