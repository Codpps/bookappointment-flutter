import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

// Import SearchBarWidget milikmu
import '../../../widgets/search_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'Date';
  final List<String> filters = ['Date', 'Specialty', 'Status'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Your History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'All your previous appointments in one place.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // Search bar
              const SearchBarWidget(
                placeholder: "Symptoms, diseases",
              ),

              const SizedBox(height: 16),

              // Filter bar
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (context, index) {
                    String filter = filters[index];
                    bool isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Doctor history list
              Expanded(
                child: ListView(
                  children: const [
                    AppointmentCardWidget(
                      name: 'Dr. Stone Gaze',
                      specialist: 'ENT Specialist',
                      dateTime: 'Wed, 10 Jan 2024 – 11:00',
                      imageUrl:
                          'https://cdn-icons-png.flaticon.com/512/387/387561.png',
                    ),
                    AppointmentCardWidget(
                      name: 'Dr. Lily Hart',
                      specialist: 'Cardiologist',
                      dateTime: 'Mon, 5 Feb 2024 – 14:00',
                      imageUrl:
                          'https://cdn-icons-png.flaticon.com/512/921/921347.png',
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentCardWidget extends StatelessWidget {
  final String name;
  final String specialist;
  final String dateTime;
  final String imageUrl;

  const AppointmentCardWidget({
    super.key,
    required this.name,
    required this.specialist,
    required this.dateTime,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(specialist,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(dateTime,
                          style: const TextStyle(fontSize: 14)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
