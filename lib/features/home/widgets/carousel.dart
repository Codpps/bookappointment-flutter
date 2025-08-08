import 'package:flutter/material.dart';

class CarouselSection extends StatelessWidget {
  const CarouselSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            CarouselCard(
              bgColor: Color(0xFFDCE8FF),
              title: "Prevent the spread\nof Bird Flu Virus",
              action: "Find out now →",
            ),
            CarouselCard(
              bgColor: Color(0xFFFFF3E6),
              title: "Stay hydrated and\nboost immunity",
              action: "See tips →",
            ),
            CarouselCard(
              bgColor: Color(0xFFE5FFF7),
              title: "Check COVID-19\nSymptoms",
              action: "Start check →",
            ),
            CarouselCard(
              bgColor: Color(0xFFFFE6EF),
              title: "Mental health is\njust as important",
              action: "Explore more →",
            ),
          ],
        ),
      ),
    );
  }
}

class CarouselCard extends StatelessWidget {
  final Color bgColor;
  final String title;
  final String action;

  const CarouselCard({
    super.key,
    required this.bgColor,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.7,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.66,
              letterSpacing: 0.2,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
