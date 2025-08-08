import 'package:doctorbooking/data/models/doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'payment_screen.dart';

class MakeAppointmentScreen extends StatefulWidget {
  const MakeAppointmentScreen({super.key, required Doctor doctor});

  @override
  State<MakeAppointmentScreen> createState() => _MakeAppointmentScreenState();
}

class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
  int selectedDateIndex = 0;
  String? selectedTime;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: const Text(
          "Make Appointment",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(BootstrapIcons.calendar, color: Colors.black),
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select your visit date & Time',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "You can choose the date and time from the available doctor's schedule",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.66,
              letterSpacing: 0.2,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose Day, ${DateFormat('MMMM yyyy').format(DateTime.now())}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.75,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),

          // ⏳ Date Cards
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = selectedDateIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDateIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 90,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const Text('Morning', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // 🌅 Morning Time
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: morningTimes.map((time) {
                final isBooked = bookedTimes.contains(time);
                final isSelected = selectedTime == time;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(
                      time,
                      style: TextStyle(
                        color: isBooked
                            ? Colors.red
                            : isSelected
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: isBooked
                        ? null
                        : (_) {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                    backgroundColor:
                        isBooked ? Colors.grey.shade200 : Colors.white,
                    selectedColor: Colors.blue,
                    disabledColor: Colors.grey.shade200,
                    shape: isBooked
                        ? const StadiumBorder()
                        : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Afternoon',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // 🌇 Afternoon Time
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: afternoonTimes.map((time) {
                final isBooked = bookedTimes.contains(time);
                final isSelected = selectedTime == time;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(
                      time,
                      style: TextStyle(
                        color: isBooked
                            ? Colors.red
                            : isSelected
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: isBooked
                        ? null
                        : (_) {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                    backgroundColor:
                        isBooked ? Colors.grey.shade200 : Colors.white,
                    selectedColor: Colors.blue,
                    disabledColor: Colors.grey.shade200,
                    shape: isBooked
                        ? const StadiumBorder()
                        : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedTime == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentScreen(),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedTime == null ? Colors.grey : Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
