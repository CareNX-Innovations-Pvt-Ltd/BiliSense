import 'dart:typed_data';
import 'package:bili_sense/core/constants/svg_strings.dart';
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/core/util.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfBasePage {
  static pw.MultiPage generate({
    required MotherModel mother,
    required List<TestModel> tests,
    required Uint8List chartImageBytes,
    required int page,
    required int total,
  }) {
    final chart = pw.MemoryImage(chartImageBytes);
    final initialTest = tests.last;
    final average = tests.map((e) => e.bilirubinReading).reduce((a, b) => a + b) / tests.length;

    return pw.MultiPage(
      orientation: pw.PageOrientation.portrait,
      footer: (pw.Context context) {
        return _buildFooter(page, total);
      },
      margin: const pw.EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      build: (context) => [
        // Header, chart, legend, info
        _buildHeader(initialTest, average, mother),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Image(chart, width: 450, height: 350, fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            _legendBox(PdfColors.white, "Low Risk"),
            _legendBox(PdfColors.greenAccent, "Low Intermediate Risk"),
            _legendBox(PdfColors.orange, "High Intermediate Risk"),
            _legendBox(PdfColors.red, "High Risk"),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(),
        pw.SizedBox(height: 12),
        _buildDoctorSection(mother, tests, average, initialTest),
      ],
    );
  }

  static _buildHeader(TestModel initialTest, double average, MotherModel mother) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey, width: 0.8),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 65,
            height: 65,
            child: pw.SvgImage(svg: SvgStrings.fetosense_icon),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 8 * PdfPageFormat.cm,
                margin: const pw.EdgeInsets.only(left: PdfPageFormat.mm),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: PdfPageFormat.mm * 5,
                ),
                alignment: pw.Alignment.topLeft,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _label("Mother Name ", mother.motherName),
                            _label("Gender of newborn", mother.gender),
                            _label(
                              "Date of birth ",
                              Utilities.formatDateTime(mother.dob),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 30),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _label(
                              "Birth Weight",
                              "${mother.weight ?? 0.0} kg",
                            ),
                            _label(
                              "Age (Days)",
                              Utilities.getAgeInHours(
                                mother.dob,
                                mother.createdAt ?? DateTime.now(),
                              ).toStringAsFixed(1),
                            ),
                            _label("Contact No.", mother.contact),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDoctorSection(MotherModel mother, List<TestModel> tests, double average, TestModel initialTest) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Doctor's Information", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _label("Doctor Name", mother.doctorName ?? "--"),
                    _label("Tests Taken", tests.length.toString()),
                    _label("Last Reading", "${tests.last.bilirubinReading.toStringAsFixed(2)} mg/dL"),
                  ]
              ),
              pw.SizedBox(width: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _label("Avg Bilirubin", "${average.toStringAsFixed(2)} mg/dL"),
                    _label("Date of initial test", Utilities.formatDate(initialTest.createdAt)),
                    _label("Last Test Date", Utilities.formatDate(tests.first.createdAt)),
                  ]
              ),
              pw.SizedBox(width: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _label("Avg Bilirubin", "${average.toStringAsFixed(2)} mg/dL"),
                  ]
              ),
            ]
          ),
          pw.SizedBox(height: 16),
          pw.Text("Doctor's Notes", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _notesBox(height: 180,),
        ],
      ),
    );
  }

  static pw.Widget _label(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Text("$title: ", style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
          pw.Text(value, style: pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  static pw.Widget _notesBox({double height = 50, String? notes}) {
    return pw.Container(
      width: double.infinity,
      height: height,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
      ),
      child: (notes?.trim().isNotEmpty ?? false)
          ? pw.Text(notes!, style: const pw.TextStyle(fontSize: 11))
          : pw.Container(),
    );
  }

  static pw.Widget _buildFooter(int page, int total) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              "Disclaimer: This bilirubin report is for informational purposes only. Please consult a medical professional before acting on the findings.",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ),
          pw.Text("$page of $total", style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _legendBox(PdfColor color, String label) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
              color: color,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Text(label, style: pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}

