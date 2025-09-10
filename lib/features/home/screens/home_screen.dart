import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/user_model.dart';
import '../widgets/search_bar.dart';
import '../widgets/carousel.dart';
import '../widgets/cards.dart';
import '../../../core/constants/api_constants.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? todayAppointment;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTodayAppointment();
  }

  Future<void> fetchTodayAppointment() async {
    final url = Uri.parse(
        "${ApiConstants.baseUrl}/Appointments/user/${widget.user.userId}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List appointments = data["\$values"] ?? [];

        DateTime now = DateTime.now();
        List today = appointments.where((a) {
          DateTime apptDate = DateTime.parse(a['appointmentDate']);
          return apptDate.year == now.year &&
              apptDate.month == now.month &&
              apptDate.day == now.day;
        }).toList();

        if (today.isNotEmpty) {
          // Urutkan berdasarkan jam terbaru
          today.sort((a, b) {
            TimeOfDay timeA = TimeOfDay(
                hour: int.parse(a['appointmentTime'].split(":")[0]),
                minute: int.parse(a['appointmentTime'].split(":")[1]));
            TimeOfDay timeB = TimeOfDay(
                hour: int.parse(b['appointmentTime'].split(":")[0]),
                minute: int.parse(b['appointmentTime'].split(":")[1]));
            return timeB.hour * 60 +
                timeB.minute -
                (timeA.hour * 60 + timeA.minute);
          });

          setState(() {
            todayAppointment = today.first;
          });
        }
      }
    } catch (e) {
      print("Error fetching appointment: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : HomeContent(
                userName: widget.user.name,
                appointment: todayAppointment,
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(BootstrapIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(BootstrapIcons.calendar),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(BootstrapIcons.clock_history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(BootstrapIcons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(BootstrapIcons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final String userName;
  final Map<String, dynamic>? appointment;

  const HomeContent({super.key, required this.userName, this.appointment});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 Header Greeting
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi $userName!",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "May you always in a good condition",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.666,
                        letterSpacing: 0.2,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    BootstrapIcons.bell_fill,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔍 Search Bar
            const SearchBarWidget(
              placeholder: "Symptoms, diseases",
            ),

            const SizedBox(height: 20),

            // 📅 My Appointment Card
            if (appointment != null) ...[
              AppointmentCard(appointment: appointment!),
              const SizedBox(height: 20),
            ],

            // 🧩 Feature Cards
            const Cards(),

            const SizedBox(height: 20),

            // 📢 Carousel
            const CarouselSection(),
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    DateTime apptDate = DateTime.parse(appointment['appointmentDate']);
    String formattedDate =
        "${apptDate.day.toString().padLeft(2, '0')}/${apptDate.month.toString().padLeft(2, '0')}";
    String formattedTime = appointment['appointmentTime'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Foto Dokter
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(
                "${ApiConstants.baseUrl.replaceAll('/api', '')}/photo/${appointment['photo']}"),
          ),
          const SizedBox(width: 16),
          // Info Dokter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['doctorName'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  appointment['specialization'],
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      formattedTime,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
