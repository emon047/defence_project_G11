import 'package:flutter/material.dart';
import '../core/theme.dart';

class DailyReflectionPage extends StatelessWidget {
  const DailyReflectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Reflection")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(value: 0.5, backgroundColor: AppColors.softLavender, color: AppColors.auroraTeal),
            const SizedBox(height: 40),
            const Text("Step 2 of 4", style: TextStyle(color: Colors.grey)),
            const Text("What was the highlight of your day?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: const TextField(
                maxLines: 4,
                decoration: InputDecoration(hintText: "Write it down...", border: InputBorder.none),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navBtn(Icons.arrow_back_ios, "Prev", false),
                _navBtn(Icons.arrow_forward_ios, "Next", true),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.spaceDark : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          if (!isPrimary) Icon(icon, size: 16, color: Colors.grey),
          Text(label, style: TextStyle(color: isPrimary ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
          if (isPrimary) Icon(icon, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}