import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text("Your Journey", 
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.spaceDark),
      ),
      body: userId == null 
        ? const Center(child: Text("Please log in to view your timeline."))
        : StreamBuilder<QuerySnapshot>(
            // We removed the .orderBy for a moment to test if it's an index issue
            stream: FirebaseFirestore.instance
                .collection('nightly_reflections')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              // 1. Check for Errors
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              // 2. Check for Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.deepPurple),
                      SizedBox(height: 20),
                      Text("Walking down memory lane...", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              // 3. Check for Empty Data
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return _buildEmptyTimeline();
              }

              // Sort manually in memory to avoid needing a Firebase Index immediately
              final sortedDocs = docs.toList()
                ..sort((a, b) {
                  Timestamp t1 = a['timestamp'] ?? Timestamp.now();
                  Timestamp t2 = b['timestamp'] ?? Timestamp.now();
                  return t2.compareTo(t1); // Newest first
                });

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  var data = sortedDocs[index].data() as Map<String, dynamic>;
                  return _buildTimelineCard(data);
                },
              );
            },
          ),
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> data) {
    String dateStr = "Recently";
    if (data['timestamp'] != null) {
      dateStr = DateFormat('EEEE, MMM d').format((data['timestamp'] as Timestamp).toDate());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const Icon(Icons.nightlight_round, size: 14, color: AppColors.deepPurple),
            ],
          ),
          const SizedBox(height: 15),
          _reflectionItem(Icons.wb_sunny_rounded, "The Spark", data['highlight'], Colors.orange),
          const Divider(height: 30, thickness: 0.5),
          _reflectionItem(Icons.cloud_done_rounded, "Released", data['letting_go'], AppColors.auroraTeal),
          const Divider(height: 30, thickness: 0.5),
          _reflectionItem(Icons.favorite_rounded, "Gratitude", data['gratitude'], Colors.pinkAccent),
        ],
      ),
    );
  }

  Widget _reflectionItem(IconData icon, String label, String? text, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.spaceDark)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          (text == null || text.isEmpty) ? "No reflection captured." : text,
          style: const TextStyle(color: Colors.black54, fontSize: 15, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildEmptyTimeline() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text("Your story starts tonight.", 
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const Text("Complete a Nightly Reflection to see it here.", 
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}