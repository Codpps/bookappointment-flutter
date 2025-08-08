// lib/data/models/specialization_model.dart
import 'package:doctorbooking/data/models/doctor_model.dart';

class Specialization {
  final int id;
  final String name;
  final String description;
  final String icon;
  final List<Doctor>? doctors;

  Specialization({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.doctors,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['specializationId'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      doctors: json['doctors'] != null
          ? (json['doctors'] as List).map((d) => Doctor.fromJson(d)).toList()
          : null,
    );
  }
}