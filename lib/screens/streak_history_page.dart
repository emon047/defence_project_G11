import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class StreakHistoryPage extends StatelessWidget {
  const StreakHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text("Streak Journey", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.spaceDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildStatCard(),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Activity History", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
              ),
              const SizedBox(height: 15),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Column(
        children: [
          Text("🔥", style: TextStyle(fontSize: 50)),
          SizedBox(height: 12),
          Text("Streak Status", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          Text("Tracking your consistency...", style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return const Center(child: Text("User not logged in"));

    return StreamBuilder<QuerySnapshot>(
      // TEMPORARY FIX: Removed .orderBy to check if it works without an index
      stream: FirebaseFirestore.instance
          .collection('memories')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Text("No memories recorded yet.", style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            
            // Format Timestamp safely
            String displayDate = "Unknown Date";
            if (data['timestamp'] != null) {
              DateTime date = (data['timestamp'] as Timestamp).toDate();
              displayDate = "${date.day}/${date.month}/${date.year}";
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: AppColors.auroraTeal, size: 12),
                  const SizedBox(width: 15),
                  Text(displayDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(data['emoji'] ?? "✨", style: const TextStyle(fontSize: 18)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}