import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';

class StreakHistoryPage extends StatelessWidget {
  const StreakHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("STREAK JOURNEY", 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('memories')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          // Extract unique dates logged
          final List<DateTime> loggedDates = docs.map((doc) {
            final ts = (doc.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            final date = ts?.toDate() ?? DateTime.now();
            return DateTime(date.year, date.month, date.day);
          }).toSet().toList();

          loggedDates.sort((a, b) => b.compareTo(a));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsHeader(loggedDates),
                const SizedBox(height: 40),
                const Text("LOG HISTORY", 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 20),
                _buildHistoryList(loggedDates),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(List<DateTime> dates) {
    // Basic calculation for the header
    int totalDays = dates.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepPurple.withOpacity(0.8), const Color(0xFF4F46E5).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text("🔥", style: TextStyle(fontSize: 50)),
          const SizedBox(height: 10),
          Text("$totalDays", 
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
          const Text("TOTAL DAYS LOGGED", 
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<DateTime> dates) {
    if (dates.isEmpty) {
      return const Center(
        child: Text("No history yet. Start your first streak!", 
          style: TextStyle(color: Colors.white24))
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.auroraTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.auroraTeal, size: 20),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('EEEE').format(date), 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(DateFormat('MMMM dd, yyyy').format(date), 
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Text("ACTIVE", 
                style: TextStyle(color: AppColors.auroraTeal, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}

