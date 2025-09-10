import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../data/services/doctor_schedule_service.dart';
import 'payment_screen.dart';


class MakeAppointmentScreen extends StatefulWidget {
  final int doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String doctorPhoto;
  final double doctorRating;
  final double consultationFee;

  const MakeAppointmentScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.doctorPhoto,
    required this.doctorRating,
    required this.consultationFee,
  }) : super(key: key);

  @override
  State<MakeAppointmentScreen> createState() => _MakeAppointmentScreenState();
}

class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
  int selectedDateIndex = 0;
  String? selectedTime;
  List<DateTime> allDates = [];
  Map<String, List<String>> timeSlots =
      {}; // key: yyyy-MM-dd -> list of "HH:mm"
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

      final activeSchedules = schedules.where((s) => s.isActive).toList();

      final Map<String, List<String>> groupedSlots = {};
      final Set<DateTime> availableDateSet = {};

      // Generate next 28 days (today .. +27)
      final now = DateTime.now();
      final List<DateTime> allDatesList = List.generate(
        28,
        (i) => DateTime(now.year, now.month, now.day).add(Duration(days: i)),
      );

      // Build slots per date based on schedules
      for (var schedule in activeSchedules) {
        final weekday = _dayToWeekday(schedule.dayOfWeek);
        final slots = _generateTimeSlots(
            schedule.startTime, schedule.endTime, schedule.slotDuration);

        for (final date in allDatesList) {
          if (date.weekday == weekday) {
            availableDateSet.add(date);
            final dateKey = DateFormat('yyyy-MM-dd').format(date);
            groupedSlots.putIfAbsent(dateKey, () => []);
            groupedSlots[dateKey]!.addAll(slots);
          }
        }
      }

      // Remove duplicates and sort slot lists
      groupedSlots.forEach((date, times) {
        final uniqueSorted = times.toSet().toList()..sort();
        groupedSlots[date] = uniqueSorted;
      });

      // pick initial selectedDateIndex: first date in allDatesList that exists in groupedSlots
      int initialIndex = 0;
      for (int i = 0; i < allDatesList.length; i++) {
        final key = DateFormat('yyyy-MM-dd').format(allDatesList[i]);
        if (groupedSlots.containsKey(key)) {
          initialIndex = i;
          break;
        }
      }

      setState(() {
        allDates = allDatesList;
        timeSlots = groupedSlots;
        selectedDateIndex = initialIndex;
        isLoading = false;
      });

      // populate morning/afternoon after state updated
      _splitTimes();
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading schedules: $e')),
        );
      }
    }
  }

  /// Generate time slots from start to end using a stable reference date (year 2000)
  List<String> _generateTimeSlots(
      String startTime, String endTime, int slotDuration) {
    final List<String> slots = [];

    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    // Use a reference year (2000) to avoid real year issues
    final start = DateTime(
        2000, 1, 1, int.parse(startParts[0]), int.parse(startParts[1]));
    final end =
        DateTime(2000, 1, 1, int.parse(endParts[0]), int.parse(endParts[1]));

    DateTime current = start;
    while (current.isBefore(end)) {
      slots.add(DateFormat('HH:mm').format(current));
      current = current.add(Duration(minutes: slotDuration));
    }

    return slots;
  }

  void _splitTimes() {
    // This reads timeSlots using selectedDateIndex and updates morningTimes & afternoonTimes
    if (!mounted) return;

    final newMorning = <String>[];
    final newAfternoon = <String>[];

    if (allDates.isEmpty ||
        selectedDateIndex < 0 ||
        selectedDateIndex >= allDates.length) {
      setState(() {
        morningTimes = newMorning;
        afternoonTimes = newAfternoon;
      });
      return;
    }

    final selectedDate = allDates[selectedDateIndex];
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    final times = timeSlots[dateKey] ?? [];

    for (final t in times) {
      final hour = int.tryParse(t.split(':')[0]) ?? 0;
      if (hour < 12) {
        newMorning.add(t);
      } else {
        newAfternoon.add(t);
      }
    }

    newMorning.sort();
    newAfternoon.sort();

    setState(() {
      morningTimes = newMorning;
      afternoonTimes = newAfternoon;
      // reset selectedTime if it's not in new list
      if (selectedTime != null &&
          !(morningTimes.contains(selectedTime) ||
              afternoonTimes.contains(selectedTime))) {
        selectedTime = null;
      }
    });
  }

  int _dayToWeekday(String day) {
    final lower = day.toLowerCase();
    if (lower.contains('monday') || lower.contains('senin'))
      return DateTime.monday;
    if (lower.contains('tuesday') || lower.contains('selasa'))
      return DateTime.tuesday;
    if (lower.contains('wednesday') || lower.contains('rabu'))
      return DateTime.wednesday;
    if (lower.contains('thursday') || lower.contains('kamis'))
      return DateTime.thursday;
    if (lower.contains('friday') ||
        lower.contains('jumat') ||
        lower.contains('selasa')) return DateTime.friday;
    if (lower.contains('saturday') || lower.contains('sabtu'))
      return DateTime.saturday;
    if (lower.contains('sunday') || lower.contains('minggu'))
      return DateTime.sunday;
    return DateTime.monday;
  }

  void _confirmAppointment() {
    if (selectedTime == null ||
        selectedDateIndex < 0 ||
        selectedDateIndex >= allDates.length) return;

    final selectedDate = allDates[selectedDateIndex];
    final appointmentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(selectedTime!.split(':')[0]),
      int.parse(selectedTime!.split(':')[1]),
    );

    final timeOfDay = TimeOfDay(
      hour: int.parse(selectedTime!.split(':')[0]),
      minute: int.parse(selectedTime!.split(':')[1]),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          doctorSpecialization: widget.doctorSpecialization,
          doctorPhoto: widget.doctorPhoto,
          doctorRating: widget.doctorRating,
          consultationFee: widget.consultationFee,
          appointmentDate: appointmentDateTime,
          appointmentTime: selectedTime!,
          selectedTime: timeOfDay,
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
                  child: Text(
                    'No available appointments',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
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

                                  return GestureDetector(
                                    onTap: isAvailable
                                        ? () {
                                            setState(() {
                                              selectedDateIndex = index;
                                              selectedTime = null;
                                            });
                                            _splitTimes();
                                          }
                                        : null,
                                    child: Container(
                                      width: 90,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey.shade300),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              DateFormat('E').format(date),
                                              style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              DateFormat('d').format(date),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat('MMM').format(date),
                                              style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
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
                                                : Colors.grey.shade300),
                                      ),
                                      child: Text(time,
                                          style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w500)),
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
                                                : Colors.grey.shade300),
                                      ),
                                      child: Text(time,
                                          style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w500)),
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
                                      'No available time slots for the selected date',
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
                      child: ElevatedButton(
                        onPressed:
                            selectedTime == null ? null : _confirmAppointment,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor:
                              selectedTime == null ? Colors.grey : Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(selectedTime == null
                            ? "Select a time slot"
                            : "Confirm Appointment"),
                      ),
                    ),
                  ],
                ),
    );
  }
}
