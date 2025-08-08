import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../data/models/doctor_schedule_model.dart';
import '../../../data/services/doctor_schedule_service.dart';
import 'payment_screen.dart';

class MakeAppointmentScreen extends StatefulWidget {
  final int doctorId;

  const MakeAppointmentScreen({super.key, required this.doctorId});

  @override
  State<MakeAppointmentScreen> createState() => _MakeAppointmentScreenState();
}

class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
  int selectedDateIndex = 0;
  String? selectedTime;
  List<DateTime> availableDates = [];
  List<DateTime> allDates = [];
  Set<int> availableWeekdays = {};
  Map<String, List<String>> timeSlots = {};
  List<String> morningTimes = [];
  List<String> afternoonTimes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      setState(() => isLoading = true);

      final service = DoctorScheduleService();
      final schedules = await service.fetchDoctorSchedules(widget.doctorId);

      // Debug print to check raw API data
      print('Raw API Response:');
      print(schedules
          .map((s) => '${s.dayOfWeek}: ${s.startTime}-${s.endTime}')
          .toList());

      final activeSchedules = schedules.where((s) => s.isActive).toList();

      // Debug print active schedules
      print('Active Schedules:');
      activeSchedules.forEach((s) {
        print(
            '${s.dayOfWeek} (${_dayToWeekday(s.dayOfWeek)}): ${s.startTime}-${s.endTime}');
      });

      final Map<String, List<String>> groupedSlots = {};
      final Set<DateTime> availableDateSet = {};
      final Set<int> weekdays = {};

      // Generate dates for next 4 weeks
      DateTime now = DateTime.now();
      List<DateTime> allDatesList = [];
      for (int i = 0; i < 28; i++) {
        allDatesList.add(now.add(Duration(days: i)));
      }

      // Process each schedule
      for (var schedule in activeSchedules) {
        final day = _dayToWeekday(schedule.dayOfWeek);
        weekdays.add(day);

        final slots = _generateTimeSlots(
            schedule.startTime, schedule.endTime, schedule.slotDuration);

        // Apply to all matching dates
        for (DateTime date in allDatesList) {
          if (date.weekday == day) {
            availableDateSet.add(date);
            String dateKey = DateFormat('yyyy-MM-dd').format(date);
            groupedSlots.putIfAbsent(dateKey, () => []);
            groupedSlots[dateKey]!.addAll(slots);
          }
        }
      }

      // Debug print generated slots
      print('Generated Time Slots:');
      groupedSlots.forEach((date, times) {
        print('$date: $times');
      });

      // Remove duplicates and sort time slots
      groupedSlots.forEach((date, times) {
        groupedSlots[date] = times.toSet().toList()..sort();
      });

      setState(() {
        allDates = allDatesList;
        availableDates = availableDateSet.toList()..sort();
        availableWeekdays = weekdays;
        timeSlots = groupedSlots;
        isLoading = false;

        // Set first available date as selected
        if (availableDates.isNotEmpty) {
          for (int i = 0; i < allDates.length; i++) {
            if (availableDateSet.any((availableDate) =>
                DateFormat('yyyy-MM-dd').format(allDates[i]) ==
                DateFormat('yyyy-MM-dd').format(availableDate))) {
              selectedDateIndex = i;
              break;
            }
          }
          _splitTimes();
        }
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading schedules: $e')),
        );
      }
    }
  }

  List<String> _generateTimeSlots(
      String startTime, String endTime, int slotDuration) {
    final List<String> slots = [];
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    DateTime start = DateTime(
        2024, 1, 1, int.parse(startParts[0]), int.parse(startParts[1]));
    DateTime end =
        DateTime(2024, 1, 1, int.parse(endParts[0]), int.parse(endParts[1]));

    DateTime current = start;
    while (current.isBefore(end)) {
      slots.add(DateFormat('HH:mm').format(current));
      current = current.add(Duration(minutes: slotDuration));
    }

    return slots;
  }

  void _splitTimes() {
    morningTimes = [];
    afternoonTimes = [];

    if (allDates.isEmpty || selectedDateIndex >= allDates.length) return;

    final selectedDate = allDates[selectedDateIndex];
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    if (!timeSlots.containsKey(dateKey)) return;

    final times = timeSlots[dateKey] ?? [];
    for (var time in times) {
      final hour = int.tryParse(time.split(":")[0]) ?? 0;
      if (hour < 12) {
        morningTimes.add(time);
      } else {
        afternoonTimes.add(time);
      }
    }
  }

  int _dayToWeekday(String day) {
    final lowerDay = day.toLowerCase();
    if (lowerDay == 'monday' || lowerDay == 'senin') return DateTime.monday;
    if (lowerDay == 'tuesday' || lowerDay == 'selasa') return DateTime.tuesday;
    if (lowerDay == 'wednesday' || lowerDay == 'rabu')
      return DateTime.wednesday;
    if (lowerDay == 'thursday' || lowerDay == 'kamis') return DateTime.thursday;
    if (lowerDay == 'friday' || lowerDay == 'jumat') return DateTime.friday;
    if (lowerDay == 'saturday' || lowerDay == 'sabtu') return DateTime.saturday;
    if (lowerDay == 'sunday' || lowerDay == 'minggu') return DateTime.sunday;
    return DateTime.monday; // Default fallback
  }

  void _confirmAppointment() {
    if (selectedTime == null || selectedDateIndex >= allDates.length) return;

    final selectedDate = allDates[selectedDateIndex];
    final appointmentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(selectedTime!.split(':')[0]),
      int.parse(selectedTime!.split(':')[1]),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          doctorId: widget.doctorId,
          appointmentDate: appointmentDateTime,
          selectedTime: selectedTime!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Make Appointment",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(BootstrapIcons.calendar, color: Colors.black),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allDates.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No available appointments',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select your visit date & Time',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "You can choose the date and time from the available doctor's schedule",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Choose Day, ${DateFormat('MMMM yyyy').format(allDates[selectedDateIndex])}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: allDates.length,
                                itemBuilder: (context, index) {
                                  final date = allDates[index];
                                  final isSelected = selectedDateIndex == index;
                                  final dateKey =
                                      DateFormat('yyyy-MM-dd').format(date);
                                  final isAvailable =
                                      timeSlots.containsKey(dateKey);
                                  final isToday = dateKey ==
                                      DateFormat('yyyy-MM-dd')
                                          .format(DateTime.now());

                                  return GestureDetector(
                                    onTap: isAvailable
                                        ? () {
                                            setState(() {
                                              selectedDateIndex = index;
                                              selectedTime = null;
                                              _splitTimes();
                                            });
                                          }
                                        : null,
                                    child: Container(
                                      width: 90,
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: !isAvailable
                                            ? Colors.grey.shade100
                                            : isSelected
                                                ? Colors.blue
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: !isAvailable
                                              ? Colors.grey.shade300
                                              : isSelected
                                                  ? Colors.blue
                                                  : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('E').format(date),
                                            style: TextStyle(
                                              color: !isAvailable
                                                  ? Colors.grey.shade400
                                                  : isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('d').format(date),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: !isAvailable
                                                  ? Colors.grey.shade400
                                                  : isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                          if (isToday) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Today',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: !isAvailable
                                                    ? Colors.grey.shade400
                                                    : isSelected
                                                        ? Colors.white
                                                        : Colors.blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                          if (!isAvailable) ...[
                                            const SizedBox(height: 4),
                                            const Text(
                                              'N/A',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (morningTimes.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.wb_sunny,
                                      color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Morning',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text('(${morningTimes.length} slots)',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: morningTimes.map((time) {
                                  final isSelected = selectedTime == time;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => selectedTime = time),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            if (afternoonTimes.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.wb_sunny_outlined,
                                      color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Afternoon',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text('(${afternoonTimes.length} slots)',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: afternoonTimes.map((time) {
                                  final isSelected = selectedTime == time;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => selectedTime = time),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            if (morningTimes.isEmpty && afternoonTimes.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 32),
                                child: Column(
                                  children: [
                                    const Icon(Icons.schedule,
                                        size: 48, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Text(
                                      selectedDateIndex < allDates.length &&
                                              !timeSlots.containsKey(
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(allDates[
                                                          selectedDateIndex]))
                                          ? 'Doctor not available on this day'
                                          : 'No available time slots',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedTime != null &&
                              selectedDateIndex < allDates.length)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event, color: Colors.blue),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE, MMM d, yyyy').format(
                                            allDates[selectedDateIndex]),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'at $selectedTime',
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: selectedTime == null
                                  ? null
                                  : _confirmAppointment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedTime == null
                                    ? Colors.grey
                                    : Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: selectedTime == null ? 0 : 2,
                              ),
                              child: Text(
                                selectedTime == null
                                    ? 'Select a time slot'
                                    : 'Confirm Appointment',
                                style: const TextStyle(
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
                  ],
                ),
    );
  }
}
