import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'profile_page.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
                _buildHeader(displayName, context),
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

  Widget _buildHeader(String name, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Welcome home,", style: TextStyle(color: Colors.grey, fontSize: 14)),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
        ]),
        GestureDetector(
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const ProfilePage())
          ),
          child: const CircleAvatar(
            radius: 24, 
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=9")
          ),
        ),
      ],
    );
  }

  Widget _buildMainMoodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.auraGradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Current Aura", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("How are you feeling today?", style: TextStyle(color: Colors.white70)),
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
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)), 
          child: const Text("View All")
        ),
      ],
    );
  }

  Widget _buildRecentMemoriesList() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return SizedBox(
      height: 140,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('memories')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No auras captured yet."));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _memoryCard(
                data['note'] ?? "No text",
                data['emoji'] ?? "✨",
              );
            },
          );
        },
      ),
    );
  }

  Widget _memoryCard(String title, String emoji) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.spaceDark,
            ),
          ),
        ],
      ),
    );
  }
}