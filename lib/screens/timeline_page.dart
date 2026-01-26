import 'package:flutter/material.dart';
import '../core/theme.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Story")),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          _timelineNode("Childhood", "Small beginnings and big dreams.", "2005", true),
          _timelineNode("Teenage Years", "Finding your voice and passion.", "2018", true),
          _timelineNode("The Turning Point", "Graduation and new horizons.", "2023", true),
          _timelineNode("The Now", "Creating your Memoaura.", "2025", false),
        ],
      ),
    );
  }

  Widget _timelineNode(String title, String desc, String year, bool hasLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const CircleAvatar(radius: 8, backgroundColor: AppColors.deepPurple),
            if (hasLine) Container(width: 2, height: 100, color: AppColors.softLavender),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(year, style: const TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 5),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        )
      ],
    );
  }
}