import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'payment_success.dart';
import '../../../core/constants/api_constants.dart';


class PaymentScreen extends StatefulWidget {
  final int doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String doctorPhoto;
  final double doctorRating;
  final double consultationFee;
  final String appointmentTime;
  final DateTime appointmentDate;
  final TimeOfDay selectedTime;

  const PaymentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.doctorPhoto,
    required this.doctorRating,
    required this.consultationFee,
    required this.appointmentTime,
    required this.appointmentDate,
    required this.selectedTime,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPayment = 'visa';
  final TextEditingController notesController = TextEditingController();

  // ganti sesuai base url backend kamu
  final String baseUrl = ApiConstants.baseUrl;

  final Map<String, String> paymentMethods = {
    'visa':
        'https://tse1.mm.bing.net/th/id/OIP.5n0JmezFeOK4F7yptVeZawHaEK?pid=Api&P=0&h=180',
    'bca':
        'https://tse3.mm.bing.net/th/id/OIP.uo8UN5fQ9nxpcsWKUpzV0AHaHa?pid=Api&P=0&h=180',
    'mandiri':
        'https://tse4.mm.bing.net/th/id/OIP.L2HwHrcAI66hMbOuhvYH-wHaFj?pid=Api&P=0&h=180',
  };

  Future<void> handlePayment() async {
    final appointmentDateTime = DateTime(
      widget.appointmentDate.year,
      widget.appointmentDate.month,
      widget.appointmentDate.day,
      widget.selectedTime.hour,
      widget.selectedTime.minute,
    );

    final endTime = appointmentDateTime.add(const Duration(minutes: 30));

    final Map<String, dynamic> body = {
      "userId": 9, // TODO: ganti dengan user login
      "doctorId": widget.doctorId,
      "appointmentDate": appointmentDateTime.toIso8601String(),
      "appointmentTime":
          "${widget.selectedTime.hour.toString().padLeft(2, '0')}:${widget.selectedTime.minute.toString().padLeft(2, '0')}:00",
      "endTime":
          "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00",
      "status": "Scheduled",
      "patientNotes":
          notesController.text.isEmpty ? "No notes" : notesController.text,
      "doctorNotes": null,
      "consultationFee": widget.consultationFee.toInt(),
      "queueNumber":
          "D${widget.doctorId}-${appointmentDateTime.month.toString().padLeft(2, '0')}${appointmentDateTime.day.toString().padLeft(2, '0')}-1",
      "symptoms": "Ear, Nose & Throat",
      "isActive": true,
      "createdAt": DateTime.now().toIso8601String(),
      "updatedAt": DateTime.now().toIso8601String(),
    };

    try {
      final String url = "${ApiConstants.baseUrl}/Appointments";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // In the handlePayment method, replace the navigation with:
if (!mounted) return;
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymentSuccessScreen(
      doctorId: widget.doctorId,
      doctorName: widget.doctorName,
      doctorSpecialization: widget.doctorSpecialization,
      doctorPhoto: widget.doctorPhoto,
      doctorRating: widget.doctorRating,
      appointmentDate: widget.appointmentDate,
      selectedTime: widget.selectedTime,
      paymentMethod: selectedPayment,
    ),
  ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed: ${response.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentDateTime = DateTime(
      widget.appointmentDate.year,
      widget.appointmentDate.month,
      widget.appointmentDate.day,
      widget.selectedTime.hour,
      widget.selectedTime.minute,
    );

    String formattedDate =
        DateFormat('EEEE, MMM d').format(appointmentDateTime);
    String formattedTime = DateFormat('hh:mm a').format(appointmentDateTime);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: const Text(
          "Payment",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // doctor info
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "${ApiConstants.baseUrl.replaceAll('/api', '')}/images/doctors/${widget.doctorPhoto}",
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
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(BootstrapIcons.star_fill,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(widget.doctorRating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(widget.doctorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(widget.doctorSpecialization),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // Schedule section
                const Text(
                  'Schedule Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(BootstrapIcons.calendar,
                            size: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appointment',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$formattedDate • $formattedTime',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Doctor ID: ${widget.doctorId}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Payment methods
                const Text(
                  'Select Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...paymentMethods.entries.map((entry) {
                  final key = entry.key;
                  final value = entry.value;
                  final isSelected = selectedPayment == key;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedPayment = key;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Image.network(
                                value,
                                width: 40,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 40,
                                    height: 24,
                                    color: Colors.grey.shade300,
                                    child: Icon(
                                      Icons.credit_card,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              Text(
                                key.toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Radio<String>(
                                value: key,
                                groupValue: selectedPayment,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      selectedPayment = val;
                                    });
                                  }
                                },
                                activeColor: Colors.blue,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Patient Notes
                const Text(
                  "Patient Notes",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter your symptoms or notes...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Payment summary
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Consultation Fee'),
                    Text('IDR ${widget.consultationFee.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Admin Fee'),
                    Text('Free'),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'IDR ${widget.consultationFee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
