import 'package:flutter/material.dart';
import '../core/theme.dart';

class WeatherMoodPage extends StatelessWidget {
  const WeatherMoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We will simulate the weather for now
    String weatherType = "Sunny"; 
    String temperature = "28°C";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Weather Aura", style: TextStyle(color: AppColors.spaceDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.spaceDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big Weather Icon
            const Text("☀️", style: TextStyle(fontSize: 80)),
            const SizedBox(height: 10),
            Text(temperature, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
            const Text("Sunny Day", style: TextStyle(fontSize: 18, color: Colors.grey)),
            
            const SizedBox(height: 50),
            
            // The Simple "Unique" Part: Mood Recommendation
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text("Today's Recommended Aura:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Text("✨ Glow", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.deepPurple)),
                  SizedBox(height: 10),
                  Text(
                    "The sun is out! It's a great time to be productive and share your energy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Simple Action Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spaceDark,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Got it!", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}