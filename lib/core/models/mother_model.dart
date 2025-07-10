import 'package:cloud_firestore/cloud_firestore.dart';

class MotherModel {
  final String motherName;
  final String contact;
  final String gender;
  final String? doctorName;
  final String? doctorId;
  final DateTime dob;
  final DateTime? createdAt;
  final String? type;
  final String? id;
  final double? weight;
  final int? apgarScore;

  MotherModel({
    required this.motherName,
    required this.contact,
    required this.gender,
    required this.dob,
    this.doctorName,
    this.doctorId,
    this.createdAt,
    this.type,
    this.id,
    this.weight,
    this.apgarScore,
  });

  factory MotherModel.fromJson(Map<String, dynamic> json, {String? id}) {

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now(); // fallback
    }

    return MotherModel(
      motherName: json['motherName'] ?? '',
      contact: json['contact'] ?? '',
      gender: json['gender'] ?? '',
      doctorName: json['doctor'],
      dob: parseDate(json['dob']),
      createdAt: json['createdAt'] != null ? parseDate(json['createdAt']) : null,
      type: json['type'],
      id: id,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      doctorId: json['doctorId'] ?? '',
      apgarScore: json['apgarScore'] != null ? (json['apgarScore'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'motherName': motherName,
      'contact': contact,
      'gender': gender,
      'doctor': doctorName,
      'dob': dob,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'type': type,
      'weight': weight,
      'doctorId': doctorId,
      'apgarScore': apgarScore,
    };
  }
}
