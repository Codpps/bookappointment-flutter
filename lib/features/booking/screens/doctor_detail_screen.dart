import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/doctor_model.dart';
import '../../../core/constants/api_constants.dart';
import 'make_appointment_screen.dart';
import '../../../data/services/doctor_service.dart';


class DoctorDetailScreen extends StatefulWidget {
  final int doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late final MapController _mapController;
  late Future<Doctor> _doctorFuture;
  final DoctorService _doctorService = DoctorService();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _doctorFuture = _doctorService.fetchDoctorDetails(widget.doctorId);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _formatSchedule(List<Schedule> schedules) {
    if (schedules.isEmpty) return 'Not available';

    final timeGroups = <String, List<String>>{};
    for (var schedule in schedules) {
      if (!schedule.isActive) continue;
      final key = '${schedule.startTime} - ${schedule.endTime}';
      timeGroups.putIfAbsent(key, () => []).add(schedule.dayOfWeek);
    }

    return timeGroups.entries.map((entry) {
      final days = entry.value.join(', ');
      return '$days: ${entry.key}';
    }).join('\n');
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? BootstrapIcons.star_fill : BootstrapIcons.star,
          size: 14,
          color: index < rating ? Colors.amber : Colors.grey.shade400,
        );
      }),
    );
  }

  Widget _buildReviewsSection(
      List<Review> reviews, int reviewCount, double rating) {
    if (reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewHeader(reviewCount, rating),
          const SizedBox(height: 12),
          const Text(
            'No reviews yet',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewHeader(reviewCount, rating),
        const SizedBox(height: 12),
        ...reviews.take(3).map((review) {
          return _buildReviewCard(review);
        }),
        if (reviews.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View all reviews feature coming soon!'),
                  ),
                );
              },
              child: Text(
                'View all $reviewCount reviews',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewHeader(int reviewCount, double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Row(
          children: [
            const Icon(BootstrapIcons.star_fill, color: Colors.amber, size: 18),
            const SizedBox(width: 6),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              ' ($reviewCount review${reviewCount > 1 ? 's' : ''})',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  review.patientName.isNotEmpty
                      ? review.patientName[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        _buildStarRating(review.rating),
                        const SizedBox(width: 8),
                        Text(
                          _getTimeAgo(review.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Doctor>(
      future: _doctorFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')));
        } else if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: Text('No doctor data found')));
        }

        final doctor = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Doctor Detail",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Doctor Info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/doctors/${doctor.photo}",
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specializationName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(BootstrapIcons.star_fill,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              doctor.rating.toStringAsFixed(1),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              ' (${doctor.reviewCount})',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp${doctor.consultationFee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Hospital & Schedule
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(BootstrapIcons.hospital,
                              color: Colors.red, size: 26),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hospital',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.providerName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(BootstrapIcons.clock,
                              color: Colors.blue, size: 26),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _formatSchedule(doctor.schedules),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text('Biography',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                doctor.biography.isNotEmpty
                    ? doctor.biography
                    : 'No biography available.',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 20),

              const Text('Work Location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                doctor.providerAddress,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        doctor.latitude,
                        doctor.longitude,
                      ),
                      initialZoom: 16.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.doctorbooking',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              doctor.latitude,
                              doctor.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              BootstrapIcons.geo_alt_fill,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildReviewsSection(
                  doctor.reviews, doctor.reviewCount, doctor.rating),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MakeAppointmentScreen(
                            doctorId: doctor.doctorId,
                            doctorName: doctor.fullName,
                            doctorSpecialization: doctor.specializationName,
                            doctorPhoto: doctor.photo,
                            doctorRating: doctor.rating,
                            consultationFee: doctor.consultationFee,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Make Appointment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chat feature coming soon!'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(
                      BootstrapIcons.chat_dots,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
