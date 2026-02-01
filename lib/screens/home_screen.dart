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
import 'profile_page.dart'; 
import 'streak_history_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Map<String, int> calculateStreaks(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return {'current': 0, 'highest': 0};
    List<DateTime> dates = docs
        .map((doc) => (doc['timestamp'] as Timestamp).toDate())
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
      backgroundColor: AppColors.bgGradientStart,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('memories')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          final List<QueryDocumentSnapshot> memories = snapshot.data?.docs ?? [];
          final streakData = calculateStreaks(memories);

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
              ),
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

                    // LARGER HERO STREAK
                    _buildHeroStreakCard(context, streakData['current']!, streakData['highest']!),
                    
                    const SizedBox(height: 25),
                    
                    // UNIQUE ENHANCED FEATURE GRID
                    Expanded(
                      flex: 6,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.35, 
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _bentoTile(context, "Calm Mode", "Find Peace", Icons.spa_rounded, const Color(0xFFE0F2F1), AppColors.auroraTeal, const CalmModePage()),
                          _bentoTile(context, "Analytics", "View Stats", Icons.insert_chart_rounded, const Color(0xFFFFF3E0), Colors.orangeAccent, const MoodAnalyticsPage()),
                          _bentoTile(context, "Timeline", "Aura Logs", Icons.auto_stories_rounded, const Color(0xFFE3F2FD), Colors.blueAccent, const TimelinePage()),
                          _bentoTile(context, "Sky Aura", "Weather", Icons.filter_drama_rounded, const Color(0xFFFCE4EC), Colors.pinkAccent, const WeatherMoodPage()),
                          _bentoTile(context, "Night Fall", "Reflect", Icons.nights_stay_rounded, const Color(0xFFE8EAF6), Colors.indigo, const GoodnightReflectionPage()),
                          _bentoTile(context, "Calendar", "History", Icons.calendar_month_rounded, const Color(0xFFF1F8E9), Colors.green, const CalendarPage()),
                        ],
                      ),
                    ),

                    // BOTTOM COMPACT SECTION
                    const SizedBox(height: 10),
                    _buildSectionHeader(context, "Recent Aura", const MemoryPage()),
                    const SizedBox(height: 10),
                    _buildRecentMemoriesList(memories), 
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
        backgroundColor: AppColors.spaceDark,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildHeroStreakCard(BuildContext context, int current, int highest) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StreakHistoryPage())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 25),
        decoration: BoxDecoration(
          gradient: AppColors.auraGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.deepPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            const Text("🔥", style: TextStyle(fontSize: 45)),
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

  // --- UPDATED UNIQUE BUTTON DESIGN ---
  Widget _bentoTile(BuildContext context, String title, String sub, IconData icon, Color bgColor, Color iconColor, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), 
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 2), 
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.1), 
              blurRadius: 15, 
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Container(
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration(
                color: bgColor, 
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: iconColor.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))
                ]
              ), 
              child: Icon(icon, color: iconColor, size: 26),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 15, 
                    color: AppColors.spaceDark,
                    letterSpacing: -0.5,
                  )
                ),
                Text(
                  sub, 
                  style: TextStyle(
                    fontSize: 11, 
                    color: Colors.grey.shade600, 
                    fontWeight: FontWeight.w600
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Welcome back,", style: TextStyle(color: Colors.grey, fontSize: 14)),
          Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
        ]),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.deepPurple.withOpacity(0.2), width: 2)),
            child: const CircleAvatar(radius: 22, backgroundColor: Color(0xFFE6E0FF), child: Icon(Icons.person_rounded, size: 24, color: AppColors.deepPurple)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Widget page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
          child: const Text("See All", style: TextStyle(color: AppColors.deepPurple, fontSize: 14, fontWeight: FontWeight.bold))
        ),
      ],
    );
  }

  Widget _buildRecentMemoriesList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return const Text("No recent logs.");
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          var data = docs[index].data() as Map<String, dynamic>;
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withOpacity(0.05))),
            child: Row(children: [
              Text(data['emoji'] ?? "✨", style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Text(data['note'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            ]),
          );
        },
      ),
    );
  }
}