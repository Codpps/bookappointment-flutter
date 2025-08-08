import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../booking/screens/specialty_screen.dart'; // Ganti sesuai lokasi file-mu

class Cards extends StatelessWidget {
  const Cards({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FeatureCard(
          bgColor: const Color(0xFFF9F5FF),
          icon: BootstrapIcons.calendar,
          iconBgColor: const Color(0xFFC6D4F1),
          title: "Book an Appointment",
          subtitle: "Find a Doctor or specialist",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpecialtyListScreen()),
            );
          },
        ),
        FeatureCard(
          bgColor: const Color(0xFFE5F9F5),
          icon: BootstrapIcons.qr_code_scan,
          iconBgColor: const Color(0xFFB4E4DA),
          title: "Appointment with QR",
          subtitle: "Queuing without the hustle",
          onTap: () {
            // TODO: Tambahkan navigasi halaman QR
          },
        ),
        FeatureCard(
          bgColor: const Color(0xFFFDF7E3),
          icon: BootstrapIcons.chat_dots,
          iconBgColor: const Color(0xFFFFD8A9),
          title: "Request Consultation",
          subtitle: "Talk to specialist",
          onTap: () {
            // TODO: Tambahkan navigasi halaman konsultasi
          },
        ),
        FeatureCard(
          bgColor: const Color(0xFFFFEEF0),
          icon: BootstrapIcons.hospital,
          iconBgColor: const Color(0xFFFFC1C8),
          title: "Locate a Pharmacy",
          subtitle: "Purchase Medicines",
          onTap: () {
            // TODO: Tambahkan navigasi halaman pharmacy
          },
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.bgColor,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double cardWidth = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: cardWidth,
        height: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.black87,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.75,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.66,
                letterSpacing: 0.2,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
