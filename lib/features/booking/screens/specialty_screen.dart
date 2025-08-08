import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'doctor_screen.dart';
import '../widgets/search_bar.dart';
import '../../../data/models/specialization_model.dart';
import '../../../data/services/specialization_service.dart';
import '../../../core/constants/api_constants.dart';

class SpecialtyListScreen extends StatefulWidget {
  const SpecialtyListScreen({super.key});

  @override
  State<SpecialtyListScreen> createState() => _SpecialtyListScreenState();
}

class _SpecialtyListScreenState extends State<SpecialtyListScreen> {
  List<Specialization> _allSpecializations = [];
  List<Specialization> _filteredSpecializations = [];
  bool _isLoading = true;
  String _query = "";
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final data = await SpecializationService().fetchSpecializations();
      setState(() {
        _allSpecializations = data;
        _filteredSpecializations = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error: $e");
      // Optionally show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load specializations: $e")),
      );
    }
  }

  void _filterSpecializations(String query) {
    final filtered = _allSpecializations
        .where((spec) => spec.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredSpecializations = filtered;
      _query = query;
      showAll = true; // Show all results when searching
    });
  }

  // Get image URL for specialization
  String _getSpecialtyImageUrl(String iconName) {
    return "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/specializations/$iconName";
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = showAll
        ? _filteredSpecializations
        : _filteredSpecializations.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book an Appointment',
          style: TextStyle(
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
            // Title Section
            const Text(
              'Medical Specialties',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.75,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Wide selection of doctor's specialties",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.66,
                letterSpacing: 0.2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            SearchBarWidget(
              placeholder: "Symptoms, diseases...",
              onChanged: _filterSpecializations,
            ),

            const SizedBox(height: 16),

            // Loading Indicator or Content
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredSpecializations.isEmpty)
              Center(
                child: Text(
                  _query.isEmpty
                      ? "No specializations available"
                      : "No results found for '$_query'",
                  style: const TextStyle(color: Colors.black54),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    ...visibleItems.map((specialty) {
                      return buildListTile(
                        imageUrl: _getSpecialtyImageUrl(specialty.icon),
                        title: specialty.name,
                        subtitle: specialty.description,
                        // In your buildListTile method in SpecialtyListScreen
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DoctorScreen(
        specialty: specialty.name,
        specializationId: specialty.id,
      ),
    ),
  );
},
                      );
                    }).toList(),
                    if (!showAll && _filteredSpecializations.length > 4)
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

  Widget buildListTile({
    required String imageUrl,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                BootstrapIcons.person_plus,
                color: Colors.blue,
                size: 20,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        BootstrapIcons.chevron_right,
        size: 16,
        color: Colors.blue,
      ),
      onTap: onTap,
    );
  }
}
