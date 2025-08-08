import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final int doctorId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String paymentMethod;

  const PaymentSuccessScreen({
    super.key,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Success')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Doctor ID: $doctorId'),
              Text(
                  'Date: ${DateFormat('EEEE, MMM d, yyyy').format(appointmentDate)}'),
              Text('Time: $appointmentTime'),
              Text('Payment via: ${paymentMethod.toUpperCase()}'),
            ],
          ),
        ),
      ),
    );
  }
}
