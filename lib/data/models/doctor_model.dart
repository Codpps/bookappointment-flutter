class Doctor {
  final int doctorId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String photo;
  final String specializationName;
  final String providerName;
  final String providerAddress;
  final String licenseNumber;
  final double consultationFee;
  final String biography;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final List<Review> reviews;
  final List<Schedule> schedules;

  Doctor({
    required this.doctorId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.photo,
    required this.specializationName,
    required this.providerName,
    required this.providerAddress,
    required this.licenseNumber,
    required this.consultationFee,
    required this.biography,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
    required this.schedules,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: json['doctorId'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? 'Unknown Doctor',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      photo: json['photo'] as String? ?? 'default_doctor.jpg',
      specializationName: json['specializationName'] as String? ?? 'General Practitioner',
      providerName: json['providerName'] as String? ?? '',
      providerAddress: json['providerAddress'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0.0,
      biography: json['biography'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      reviews: (json['reviews']?['\$values'] as List?)
              ?.map((review) => Review.fromJson(review))
              .toList() ??
          [],
      schedules: (json['schedules']?['\$values'] as List?)
              ?.map((schedule) => Schedule.fromJson(schedule))
              .toList() ??
          [],
    );
  }

  get id => null;
}

class Review {
  final int reviewId;
  final String patientName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.reviewId,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] as int? ?? 0,
      patientName: json['patientName'] as String? ?? 'Anonymous',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toString()),
    );
  }
}

class Schedule {
  final int schedulesID;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotDuration;
  final bool isActive;

  Schedule({
    required this.schedulesID,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
    required this.isActive,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      schedulesID: json['schedulesID'] as int? ?? 0,
      dayOfWeek: json['dayOfWeek'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      slotDuration: json['slotDuration'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}