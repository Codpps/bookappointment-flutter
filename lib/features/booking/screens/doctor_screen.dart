import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/services/doctor_service.dart';
import '../../../core/constants/api_constants.dart';
import 'doctor_detail_screen.dart';
import '../widgets/search_bar.dart';

class DoctorScreen extends StatefulWidget {
  final String specialty;
  final int specializationId;

  const DoctorScreen({
    super.key,
    required this.specialty,
    required this.specializationId,
  });

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  bool showAll = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final doctors = await DoctorService()
          .fetchDoctorsBySpecialization(widget.specializationId);
      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load doctors. Please try again.';
      });
      debugPrint("Error fetching doctors: $e");
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _filteredDoctors = _doctors
          .where((doctor) =>
              doctor.fullName.toLowerCase().contains(query.toLowerCase()) ||
              doctor.specializationName
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleDoctors =
        showAll ? _filteredDoctors : _filteredDoctors.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.specialty,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar (using your custom widget)
            SearchBarWidget(
              placeholder: 'Search for a doctor...',
              onChanged: _handleSearch,
              onFilterTap: () {
                // Filter button functionality
                debugPrint('Filter button pressed');
              },
            ),
            const SizedBox(height: 16),

            // Filter Buttons (horizontal scrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterButton("Available Today"),
                  const SizedBox(width: 8),
                  filterButton("Gender"),
                  const SizedBox(width: 8),
                  filterButton("Price"),
                  const SizedBox(width: 8),
                  filterButton("Rating"),
                  const SizedBox(width: 8),
                  filterButton("Experience"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Doctors List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : _filteredDoctors.isEmpty
                          ? const Center(child: Text('No doctors found'))
                          : ListView(
                              children: [
                                ...visibleDoctors
                                    .map((doctor) => doctorCard(doctor)),
                                if (!showAll && _filteredDoctors.length > 3)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showAll = true;
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'Show more',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(
                                            BootstrapIcons.arrow_right,
                                            color: Colors.blue,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // Your original filterButton widget
  Widget filterButton(String label) {
    return TextButton(
      onPressed: () {
        debugPrint('Button $label pressed!');
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Your original doctorCard widget with API data integration
  Widget doctorCard(Doctor doctor) {
    return InkWell(
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DoctorDetailScreen(doctorId: doctor.doctorId),
      settings: RouteSettings(
        name: '/doctor_detail/${doctor.doctorId}',
      ),
    ),
  );
},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Doctor Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/doctors/${doctor.photo}",
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specializationName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rp${doctor.consultationFee.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Rating
            Row(
              children: [
                const Icon(
                  BootstrapIcons.star_fill,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
