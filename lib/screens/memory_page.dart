import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

  Color _getMoodColor(String? mood) {
    switch (mood) {
      case 'Happy': return Colors.amber;
      case 'Calm': return AppColors.auroraTeal;
      case 'Energetic': return Colors.orangeAccent;
      case 'Sad': return Colors.blueGrey;
      case 'Angry': return Colors.redAccent;
      default: return AppColors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      appBar: AppBar(
        title: const Text(
          "Aura History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // FIXED: Removed .orderBy here to stop the 'Query Error'
        stream: FirebaseFirestore.instance
            .collection('memories')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.auroraTeal));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No memories logged yet.", style: TextStyle(color: Colors.white54)),
            );
          }

          // LOCAL SORTING: This sorts the data by time without needing a Firebase Index
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          docs.sort((a, b) {
            var aTime = (a.data() as Map)['timestamp'] as Timestamp?;
            var bTime = (b.data() as Map)['timestamp'] as Timestamp?;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime); // Latest first
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();
              final moodColor = _getMoodColor(data['auraType']);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          DateFormat('MMM').format(date).toUpperCase(),
                          style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('dd').format(date),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: moodColor,
                            boxShadow: [
                              BoxShadow(color: moodColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['auraType'] ?? "Unknown",
                                style: TextStyle(color: moodColor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                DateFormat('jm').format(date),
                                style: const TextStyle(color: Colors.white24, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['note'] ?? "",
                            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

