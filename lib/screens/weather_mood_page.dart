import 'package:flutter/material.dart';

class WeatherMoodPage extends StatefulWidget {
  const WeatherMoodPage({super.key});

  @override
  State<WeatherMoodPage> createState() => _WeatherMoodPageState();
}

class _WeatherMoodPageState extends State<WeatherMoodPage> {
  final Color spaceDark = const Color(0xFF1A1C2E);
  final Color auroraTeal = const Color(0xFF00D2D3);

  String temperature = "--";
  // Updated initial message to be simple and "good"
  String message = "Waiting to discover your current sky atmosphere.";
  String auraTitle = "AWAITING DATA";
  String weatherIcon = "✨";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _showTempDialog());
  }

  void _updateWeatherLogic(int temp) {
    setState(() {
      temperature = "$temp°C";
      if (temp <= 0) {
        weatherIcon = "❄️";
        auraTitle = "GLACIAL";
        message = "It's freezing! Keep your inner fire burning. Perfect for cozy introspection.";
      } else if (temp > 0 && temp <= 15) {
        weatherIcon = "☁️";
        auraTitle = "CRISP";
        message = "A bit chilly. A fresh breeze for a fresh start. Great for clearing your head.";
      } else if (temp > 15 && temp <= 25) {
        weatherIcon = "🍃";
        auraTitle = "BALANCED";
        message = "Ideal conditions. Your mind is in its natural state. Perfect for flow.";
      } else if (temp > 25 && temp <= 35) {
        weatherIcon = "☀️";
        auraTitle = "RADIANT";
        message = "The sun is high! Your energy is peaking. Share your warmth with others.";
      } else {
        weatherIcon = "🔥";
        auraTitle = "SCORCHING";
        message = "It's intense out there. Stay hydrated and calm.";
      }
    });
  }

  // Helper to handle "No Entry" state
  void _handleNoEntry() {
    setState(() {
      message = "No temperature entered. Enjoy your peaceful journey through the stars!";
      auraTitle = "STAY CALM";
      weatherIcon = "✨";
      temperature = "--";
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Current Temperature",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.white38),
              onPressed: () {
                _handleNoEntry(); // Updates message
                Navigator.pop(context);
              },
            )
          ],
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
              _handleNoEntry(); // Updates message
              Navigator.pop(context);
            },
            child: const Text("CANCEL", style: TextStyle(color: Colors.white38)),
          ),
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
            // REMOVED: The Gemini-style background glow container is gone
            
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
                          message, // This now updates on Cancel/Home
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  
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