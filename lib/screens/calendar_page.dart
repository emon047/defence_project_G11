import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // --- COLORS ---
  static const Color weekendColor = Color(0xFFFFD700); // Elegant Gold for Fri-Sat
  static const Color weekdayColor = Colors.white;    // Pure White for Sun-Thu

  final Map<String, String> _holidayData = {
    "1-1": "New Year's Day", "1-24": "International Day of Education",
    "2-4": "World Cancer Day", "2-14": "Valentine's Day",
    "3-8": "International Women's Day", "3-21": "World Poetry Day",
    "4-1": "April Fool's Day", "4-22": "Earth Day",
    "5-1": "International Labour Day", "5-31": "World No-Tobacco Day",
    "6-5": "World Environment Day", "6-21": "International Yoga Day",
    "7-17": "World Emoji Day", "7-30": "International Day of Friendship",
    "8-12": "International Youth Day", "8-19": "World Photography Day",
    "9-21": "International Day of Peace", "9-27": "World Tourism Day",
    "10-16": "World Food Day", "10-31": "Halloween",
    "11-13": "World Kindness Day", "11-19": "International Men's Day",
    "12-10": "Human Rights Day", "12-25": "Christmas Day",
    "12-31": "New Year's Eve",
  };

  String _getEventInfo(DateTime selected) {
    String key = "${selected.month}-${selected.day}";
    if (_holidayData.containsKey(key)) return "Today's Event: ${_holidayData[key]}";

    DateTime checkDate = selected;
    for (int i = 1; i <= 365; i++) {
      checkDate = checkDate.add(const Duration(days: 1));
      String nextKey = "${checkDate.month}-${checkDate.day}";
      if (_holidayData.containsKey(nextKey)) {
        String formattedNextDate = DateFormat('dd MMMM yyyy').format(checkDate);
        return "No special event today. \nUpcoming: ${_holidayData[nextKey]} on $formattedNextDate";
      }
    }
    return "No upcoming events found.";
  }

  @override
  Widget build(BuildContext context) {
    const Color deepSpaceBg = Color.fromARGB(255, 26, 28, 46);

    return Scaffold(
      backgroundColor: deepSpaceBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("EVENT TRACKER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
              ),
              child: Column(
                children: [
                  Text(
                    "Date: ${DateFormat('dd/MM/yyyy').format(_selectedDay)}",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _getEventInfo(_selectedDay),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (sel, foc) => setState(() { _selectedDay = sel; _focusedDay = foc; }),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false, 
          titleCentered: true, 
          titleTextStyle: TextStyle(color: Colors.white),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        
        // --- THE UNIQUE COLOR LOGIC ---
        calendarBuilders: CalendarBuilders(
          // Colors the Day Labels (Mon, Tue, Wed...)
          dowBuilder: (context, day) {
            bool isWeekend = day.weekday == DateTime.friday || day.weekday == DateTime.saturday;
            return Center(
              child: Text(
                DateFormat.E().format(day),
                style: TextStyle(color: isWeekend ? weekendColor : weekdayColor, fontWeight: FontWeight.bold),
              ),
            );
          },
          // Colors the Date Numbers (1, 2, 3...)
          defaultBuilder: (context, day, focusedDay) {
            bool isWeekend = day.weekday == DateTime.friday || day.weekday == DateTime.saturday;
            return Center(
              child: Text(
                '${day.day}',
                style: TextStyle(color: isWeekend ? weekendColor : weekdayColor),
              ),
            );
          },
        ),

        calendarStyle: CalendarStyle(
          // Today and Selected remain teal for clarity
          todayDecoration: BoxDecoration(color: Colors.teal.withOpacity(0.3), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
          outsideDaysVisible: false,
        ),
      ),
    );
  }
}

