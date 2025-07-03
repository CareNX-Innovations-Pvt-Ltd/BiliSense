import 'package:cloud_firestore/cloud_firestore.dart';

class TestModel {
  final String motherName;
  final double weight;
  final DateTime dob;
  final double bilirubinReading;
  final DateTime createdAt;
  final String doctorName;
  final List<double> readings;

  TestModel({
    required this.motherName,
    required this.weight,
    required this.dob,
    required this.bilirubinReading,
    required this.createdAt,
    required this.doctorName,
    required this.readings,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }


    return TestModel(
      motherName: json['motherName'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      dob: parseDate(json['dob']),
      bilirubinReading: (json['bilirubinReading'] ?? 0).toDouble(),
      createdAt: parseDate(json['createdAt']),
      doctorName: json['doctorName'] ?? '',
      readings: (json['readings'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'motherName': motherName,
      'weight': weight,
      'dob': dob,
      'bilirubinReading': bilirubinReading,
      'doctorName': doctorName,
      'readings' : readings,
    };
  }
}
