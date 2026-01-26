import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this
import '../core/theme.dart';
import 'add_memory_page.dart';
import 'memory_page.dart'; 
import 'mood_analytics_page.dart';
import 'calm_mode_page.dart';
import 'calendar_page.dart';
import 'timeline_page.dart';
import 'weather_mood_page.dart';
import 'goodnight_reflection_page.dart';
import 'memory_map_page.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Grab the currently logged-in user from Firebase
    final user = FirebaseAuth.instance.currentUser;
    // Get the name from email (e.g., "alex@gmail.com" becomes "Alex")
    final displayName = user?.email?.split('@')[0] ?? "Explorer";

    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(displayName), // Pass the real name here
                const SizedBox(height: 30),
                _buildMainMoodCard(),
                const SizedBox(height: 25),
                const Text("Your Wellness Space", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _bentoTile(context, "Calm Mode", Icons.spa_outlined, AppColors.auroraTeal, const CalmModePage(), height: 180)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        children: [
                          _bentoTile(context, "Analytics", Icons.analytics_outlined, Colors.orangeAccent, const MoodAnalyticsPage(), height: 82),
                          const SizedBox(height: 15),
                          _bentoTile(context, "Map", Icons.map_outlined, AppColors.deepPurple, const MemoryMapPage(), height: 82),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _bentoTile(context, "Timeline", Icons.auto_stories_outlined, Colors.blueAccent, const TimelinePage(), height: 82)),
                    const SizedBox(width: 15),
                    Expanded(child: _bentoTile(context, "Weather", Icons.wb_cloudy_outlined, Colors.pinkAccent, const WeatherMoodPage(), height: 82)),
                  ],
                ),
                const SizedBox(height: 25),
                _buildRitualsRow(context),
                const SizedBox(height: 25),
                _buildSectionHeader(context, "Recent Memories", const MemoryPage()),
                const SizedBox(height: 15),
                _buildRecentMemoriesList(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMemoryPage())),
        backgroundColor: AppColors.spaceDark,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Capture Aura", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Updated Header to accept the user's name
  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Welcome home,", style: TextStyle(color: Colors.grey, fontSize: 14)),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
        ]),
        InkWell(
          onTap: () async {
            await FirebaseAuth.instance.signOut(); // Logout feature
          },
          child: const CircleAvatar(
            radius: 24, 
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=9")
          ),
        ),
      ],
    );
  }

  // ... (Keep your existing _buildMainMoodCard, _bentoTile, _buildRitualsRow, etc. exactly the same)
  // Just make sure to include them below!
  
  Widget _buildMainMoodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.auraGradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Current Aura", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Slider(value: 0.7, onChanged: (v) {}, activeColor: Colors.white, inactiveColor: Colors.white24),
        ],
      ),
    );
  }

  Widget _bentoTile(BuildContext context, String title, IconData icon, Color color, Widget page, {double height = 100}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 20),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.spaceDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildRitualsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _iconAction(context, Icons.nights_stay_outlined, "Night", const GoodnightReflectionPage()),
        _iconAction(context, Icons.calendar_month_outlined, "Calendar", const CalendarPage()),
      ],
    );
  }

  Widget _iconAction(BuildContext context, IconData icon, String label, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Column(children: [Icon(icon, color: Colors.grey), Text(label, style: const TextStyle(fontSize: 10))]),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Widget page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)), child: const Text("View All")),
      ],
    );
  }

  Widget _buildRecentMemoriesList() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _memoryCard("Morning Coffee", "https://images.unsplash.com/photo-1509042239860-f550ce710b93"),
          _memoryCard("Rainy Vibes", "https://images.unsplash.com/photo-1515694346937-94d85e41e6f0"),
        ],
      ),
    );
  }

  Widget _memoryCard(String title, String url) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24))),
        child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
    );
  }
}