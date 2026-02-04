import 'package:flutter/material.dart';
import '../core/theme.dart';

class WeatherMoodPage extends StatelessWidget {
  const WeatherMoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    String temperature = "28°C";

    return Scaffold(
      // Extends body behind AppBar for a seamless gradient look
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text(
          "Weather Aura", 
          style: TextStyle(
            color: AppColors.spaceDark, 
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.spaceDark),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient, // Using your custom gradient
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Weather Icon with soft depth
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepPurple.withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Text("☀️", style: TextStyle(fontSize: 80)),
              ),
              
              const SizedBox(height: 25),
              
              Text(
                temperature, 
                style: const TextStyle(
                  fontSize: 56, 
                  fontWeight: FontWeight.w900, 
                  color: AppColors.spaceDark
                )
              ),
              const Text(
                "Sunny Day", 
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.black45, 
                  fontWeight: FontWeight.w500
                )
              ),
              
              const SizedBox(height: 50),
              
              // Unique Mood Card using your auraGradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: AppColors.auraGradient, // Using your brand gradient
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepPurple.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "TODAY'S RECOMMENDED AURA", 
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white70, 
                        letterSpacing: 1.1
                      )
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "✨ Glow", 
                      style: TextStyle(
                        fontSize: 36, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      )
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "The sun is out! It's a great time to be productive and share your energy.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        height: 1.5
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Final Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spaceDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Got it!", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}