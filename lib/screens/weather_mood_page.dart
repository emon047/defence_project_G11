import 'package:flutter/material.dart';

class WeatherMoodPage extends StatefulWidget {
  const WeatherMoodPage({super.key});

  @override
  State<WeatherMoodPage> createState() => _WeatherMoodPageState();
}

class _WeatherMoodPageState extends State<WeatherMoodPage> {
  // Local theme colors
  final Color spaceDark = const Color(0xFF1A1C2E);
  final Color auroraTeal = const Color(0xFF00D2D3);

  String temperature = "--";
  String message = "Enter the temperature to see your sky recommendation.";
  String auraTitle = "AWAITING DATA";
  String weatherIcon = "✨";

  @override
  void initState() {
    super.initState();
    // Auto-shows input dialog on load
    Future.delayed(Duration.zero, () => _showTempDialog());
  }

  void _updateWeatherLogic(int temp) {
    setState(() {
      temperature = "$temp°C";
      if (temp <= 0) {
        weatherIcon = "❄️";
        auraTitle = "GLACIAL";
        message = "It's freezing! Keep your inner fire burning. Perfect for cozy introspection and hot cocoa.";
      } else if (temp > 0 && temp <= 15) {
        weatherIcon = "☁️";
        auraTitle = "CRISP";
        message = "A bit chilly. A fresh breeze for a fresh start. Great for a brisk walk to clear your head.";
      } else if (temp > 15 && temp <= 25) {
        weatherIcon = "🍃";
        auraTitle = "BALANCED";
        message = "Ideal conditions. Your mind is in its natural state. Perfect for productivity and flow.";
      } else if (temp > 25 && temp <= 35) {
        weatherIcon = "☀️";
        auraTitle = "RADIANT";
        message = "The sun is high! Your energy is peaking. Share your warmth with others today.";
      } else {
        weatherIcon = "🔥";
        auraTitle = "SCORCHING";
        message = "It's intense out there. Stay hydrated and calm. Use this heat to fuel your passions quietly.";
      }
    });
  }

  void _showTempDialog() {
    final TextEditingController tempInputController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
        title: const Text(
          "Current Temperature",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: tempInputController,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: "Enter Celsius (-20 to 50)",
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            suffixText: "°C",
            suffixStyle: TextStyle(color: auroraTeal),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: auroraTeal)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final int? val = int.tryParse(tempInputController.text);
              if (val != null) {
                _updateWeatherLogic(val);
                Navigator.pop(context);
              }
            },
            child: Text("ANALYZE", style: TextStyle(color: auroraTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: spaceDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("SKY AURA", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background glow
            Positioned(
              top: 100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: auroraTeal.withOpacity(0.15), blurRadius: 100, spreadRadius: 50)
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(weatherIcon, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  Text(temperature, 
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2)),
                  Text(auraTitle, 
                    style: TextStyle(fontSize: 14, color: auroraTeal, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  const SizedBox(height: 40),
                  
                  // Recommendation Insight Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        const Text("AURA INSIGHT", 
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 2)),
                        const SizedBox(height: 15),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // RETURN TO HOME BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: auroraTeal,
                        foregroundColor: spaceDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "GO BACK HOME", 
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}