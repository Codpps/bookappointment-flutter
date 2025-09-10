import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';
import '../../home/screens/home_screen.dart';
import '../../../data/models/user_model.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final int doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String doctorPhoto;
  final double doctorRating;
  final DateTime appointmentDate;
  final TimeOfDay selectedTime;
  final String paymentMethod;
  

  const PaymentSuccessScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.doctorPhoto,
    required this.doctorRating,
    required this.appointmentDate,
    required this.selectedTime,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    String formattedDate =
        DateFormat('EEEE, d MMM y').format(appointmentDateTime);
    String formattedTime = DateFormat('HH:mm').format(appointmentDateTime);

    return WillPopScope(
      onWillPop: () async {
        // Prevent going back to the previous screen
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    BootstrapIcons.check,
                    size: 60,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 24),

                // Success title
                const Text(
                  'You have successfully made an appointment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Success message
                const Text(
                  'The appointment confirmation has been sent to your email.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Doctor info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Doctor avatar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/doctors/$doctorPhoto",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              BootstrapIcons.person,
                              size: 30,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Doctor details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctorSpecialization,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(BootstrapIcons.star_fill,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(doctorRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Appointment details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Calendar icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          BootstrapIcons.calendar,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Appointment details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appointment',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$formattedDate, $formattedTime',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Payment method
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Payment icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          BootstrapIcons.credit_card,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Payment details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            paymentMethod.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Back to home button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
