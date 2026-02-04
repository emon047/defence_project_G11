import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class MoodAnalyticsPage extends StatefulWidget {
  const MoodAnalyticsPage({super.key});

  @override
  State<MoodAnalyticsPage> createState() => _MoodAnalyticsPageState();
}

class _MoodAnalyticsPageState extends State<MoodAnalyticsPage> {
  static const Color spaceDark = Color.fromARGB(255, 26, 28, 46);
  static const Color auroraTeal = Color(0xFF00D2D3);
  
  String _selectedFilter = "Week";

  final Map<String, int> moodValues = {
    "Sad": 1,
    "Down": 2,
    "Neutral": 3,
    "Happy": 4,
    "Excited": 5,
  };

  String _getMoodFromValue(double value) {
    if (value <= 1.5) return "Sad";
    if (value <= 2.5) return "Down";
    if (value <= 3.5) return "Neutral";
    if (value <= 4.5) return "Happy";
    return "Excited";
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: spaceDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("MOOD ANALYSIS", 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('nightly_reflections')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: auroraTeal));
          }

          // Use data() and check for field existence to prevent "Bad State" error
          final docs = snapshot.data?.docs ?? [];
          
          double totalScore = 0;
          int count = 0;
          Map<String, int> distribution = {"Sad": 0, "Down": 0, "Neutral": 0, "Happy": 0, "Excited": 0};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            
            // --- FIX: Safely check if 'mood' exists ---
            if (data.containsKey('mood')) {
              String mood = data['mood'];
              if (distribution.containsKey(mood)) {
                distribution[mood] = distribution[mood]! + 1;
                totalScore += moodValues[mood] ?? 3;
                count++;
              }
            }
          }

          double averageValue = count > 0 ? totalScore / count : 3.0;
          String averageMood = _getMoodFromValue(averageValue);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ["Week", "Month", "Year"].map((filter) {
                    bool isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? auroraTeal : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(filter, 
                          style: TextStyle(color: isSelected ? spaceDark : Colors.white38, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      const Text("CURRENT AVERAGE AURA", 
                        style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 15),
                      Text(_getEmoji(averageMood), style: const TextStyle(fontSize: 50)),
                      const SizedBox(height: 10),
                      Text(averageMood.toUpperCase(), 
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 5),
                      Text("Based on $count logs this $_selectedFilter", 
                        style: const TextStyle(color: Colors.white24, fontSize: 12)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("STATISTICS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 15),
                _buildStatBars(distribution, count),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatBars(Map<String, int> data, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: data.entries.map((e) {
          double progress = total == 0 ? 0 : e.value / total;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 60, child: Text(e.key, style: const TextStyle(color: Colors.white54, fontSize: 12))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      color: auroraTeal,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Text("${(progress * 100).toInt()}%", 
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getEmoji(String mood) {
    switch (mood) {
      case "Sad": return "😔";
      case "Down": return "☁️";
      case "Happy": return "😊";
      case "Excited": return "🤩";
      default: return "😐";
    }
  }
}