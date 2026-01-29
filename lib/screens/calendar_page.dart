import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, bool> _completedDays = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchCompletionData();
  }

  // Purpose: Fetch days where the user actually completed a reflection
  Future<void> _fetchCompletionData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('nightly_reflections')
        .where('userId', isEqualTo: user.uid)
        .get();

    Map<DateTime, bool> data = {};
    for (var doc in querySnapshot.docs) {
      Timestamp ts = doc['timestamp'];
      DateTime date = ts.toDate();
      // Normalize to midnight to match calendar comparison
      DateTime normalized = DateTime(date.year, date.month, date.day);
      data[normalized] = true;
    }

    setState(() {
      _completedDays = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text("Aura History", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.spaceDark),
      ),
      body: Column(
        children: [
          _buildCalendarCard(),
          const SizedBox(height: 30),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: AppColors.deepPurple.withOpacity(0.2), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(color: AppColors.deepPurple, shape: BoxShape.circle),
          markerDecoration: const BoxDecoration(color: AppColors.auroraTeal, shape: BoxShape.circle),
        ),
        // UNIQUE FEATURE: The Heatmap Logic
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            DateTime normalized = DateTime(day.year, day.month, day.day);
            if (_completedDays.containsKey(normalized)) {
              return Container(
                margin: const EdgeInsets.all(6),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: AppColors.auraGradient, // Using your theme's gradient
                  shape: BoxShape.circle,
                ),
                child: Text("${day.day}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              );
            }
            return null;
          },
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Text("Your Consistency", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.spaceDark)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(AppColors.auroraTeal, "Reflection Saved"),
              const SizedBox(width: 20),
              _legendItem(Colors.grey.shade300, "Pending"),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            "You have captured ${_completedDays.length} auras this month!",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}