import 'package:flutter/material.dart';
import '../core/theme.dart';

class WeatherMoodPage extends StatelessWidget {
  const WeatherMoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Aura")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: AppColors.auraGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.deepPurple.withOpacity(0.2), blurRadius: 20)],
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_outlined, size: 64, color: Colors.white),
                  SizedBox(height: 10),
                  Text("Cloudy Skies", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Dhaka • 24°C", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _bentoTip("Low Energy?", "Lack of sun can affect your mood. Try 5 mins of light stretching.", Icons.wb_sunny_rounded),
            const SizedBox(height: 15),
            _bentoTip("Cozy Moment", "Perfect time to write a Future Letter with a warm tea.", Icons.coffee_rounded),
          ],
        ),
      ),
    );
  }

  Widget _bentoTip(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.softLavender, child: Icon(icon, color: AppColors.deepPurple, size: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}