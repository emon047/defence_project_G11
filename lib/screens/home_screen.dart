import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import 'add_memory_page.dart';
import 'memory_page.dart'; 
import 'mood_analytics_page.dart';
import 'calm_mode_page.dart';
import 'calendar_page.dart';
import 'timeline_page.dart';
import 'weather_mood_page.dart';
import 'goodnight_reflection_page.dart';
import 'profile_page.dart'; 
import 'streak_history_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Color _getMoodColor(String? mood) {
    switch (mood) {
      case 'Happy': return Colors.amber;
      case 'Calm': return AppColors.auroraTeal; // Updated to match theme
      case 'Peaceful': return Colors.greenAccent;
      case 'Energetic': return Colors.orangeAccent;
      case 'Sad': return Colors.blueGrey;
      case 'Angry': return Colors.redAccent;
      default: return AppColors.deepPurple;
    }
  }

  Map<String, int> calculateStreaks(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return {'current': 0, 'highest': 0};
    List<DateTime> dates = docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final ts = data['timestamp'] as Timestamp?;
          return ts != null ? ts.toDate() : DateTime.now();
        })
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet().toList();
    dates.sort((a, b) => b.compareTo(a));

    int currentStreak = 0;
    int maxStreak = 0;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (dates.isNotEmpty) {
      if (dates.first.isAtSameMomentAs(today) || 
          dates.first.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
        currentStreak = 1;
        for (int i = 0; i < dates.length - 1; i++) {
          if (dates[i].difference(dates[i + 1]).inDays == 1) {
            currentStreak++;
          } else { break; }
        }
      }
    }
    int tempStreak = 1;
    maxStreak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      if (dates[i].difference(dates[i + 1]).inDays == 1) {
        tempStreak++;
      } else {
        if (tempStreak > maxStreak) maxStreak = tempStreak;
        tempStreak = 1;
      }
    }
    if (tempStreak > maxStreak) maxStreak = tempStreak;
    return {'current': currentStreak, 'highest': maxStreak};
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? "";
    final displayName = user?.email?.split('@')[0] ?? "Explorer";

    return Scaffold(
      backgroundColor: AppColors.spaceDark, // Updated to Space Dark
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('memories')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          List<QueryDocumentSnapshot> allMemories = snapshot.data?.docs ?? [];
          allMemories.sort((a, b) {
            var aTime = (a.data() as Map)['timestamp'] as Timestamp?;
            var bTime = (b.data() as Map)['timestamp'] as Timestamp?;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          final streakData = calculateStreaks(allMemories);
          final recentThree = allMemories.take(3).toList();

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: AppColors.spaceDark, // Solid Space Dark or very subtle gradient
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    _buildHeader(displayName, context),
                    const SizedBox(height: 20),
                    _buildHeroStreakCard(context, streakData['current']!, streakData['highest']!),
                    const SizedBox(height: 25),
                    
                    Expanded(
                      flex: 6,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.35, 
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _bentoTile(context, "Calm Mode", "Find Peace", Icons.spa_rounded, Colors.white.withOpacity(0.05), AppColors.auroraTeal, const CalmModePage()),
                          _bentoTile(context, "Analytics", "View Stats", Icons.insert_chart_rounded, Colors.white.withOpacity(0.05), Colors.orangeAccent, const MoodAnalyticsPage()),
                          _bentoTile(context, "Timeline", "Aura Logs", Icons.auto_stories_rounded, Colors.white.withOpacity(0.05), Colors.blueAccent, const TimelinePage()),
                          _bentoTile(context, "Sky Aura", "Weather", Icons.filter_drama_rounded, Colors.white.withOpacity(0.05), Colors.pinkAccent, const WeatherMoodPage()),
                          _bentoTile(context, "Night Fall", "Reflect", Icons.nights_stay_rounded, Colors.white.withOpacity(0.05), Colors.indigoAccent, const GoodnightReflectionPage()),
                          _bentoTile(context, "Calendar", "History", Icons.calendar_month_rounded, Colors.white.withOpacity(0.05), AppColors.auroraTeal, const CalendarPage()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    _buildSectionHeader(context, "Recent Aura", const MemoryPage()),
                    const SizedBox(height: 12),
                    _buildRecentMemoriesList(recentThree), 
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMemoryPage())),
        backgroundColor: AppColors.auroraTeal, // Changed to Accent Teal
        child: const Icon(Icons.add_rounded, color: AppColors.spaceDark, size: 35),
      ),
    );
  }

  Widget _buildHeader(String name, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Welcome back,", style: TextStyle(color: Colors.white54, fontSize: 14)),
          Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
        ]),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
          child: CircleAvatar(
            radius: 22, 
            backgroundColor: Colors.white.withOpacity(0.1), 
            child: const Icon(Icons.person_rounded, color: AppColors.auroraTeal)
          ),
        ),
      ],
    );
  }

  Widget _buildHeroStreakCard(BuildContext context, int current, int highest) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StreakHistoryPage())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 25),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.deepPurple, Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.deepPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            const Text("🔥", style: TextStyle(fontSize: 40)),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$current Day Streak", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                Text("Highest Score: $highest", style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _bentoTile(BuildContext context, String title, String sub, IconData icon, Color bgColor, Color iconColor, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor, // Glass effect
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5), 
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Icon(icon, color: iconColor, size: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
                Text(sub, style: const TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Widget page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
          child: const Text("See All", style: TextStyle(color: AppColors.auroraTeal, fontSize: 14, fontWeight: FontWeight.bold))
        ),
      ],
    );
  }

  Widget _buildRecentMemoriesList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return const Text("No recent logs.", style: TextStyle(color: Colors.white38));
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        itemBuilder: (context, index) {
          var data = docs[index].data() as Map<String, dynamic>;
          DateTime date = data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : DateTime.now();
          Color orbColor = _getMoodColor(data['auraType']);

          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
            ),
            child: Row(
              children: [
                Text(DateFormat('MMM d').format(date), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white38)),
                const SizedBox(width: 8),
                Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: orbColor)),
                const SizedBox(width: 10),
                Expanded(child: Text(data['note'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70))),
              ],
            ),
          );
        },
      ),
    );
  }
}

