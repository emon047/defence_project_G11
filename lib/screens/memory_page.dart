import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("All Memories", style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('memories')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Sort manually in Dart code
          List<QueryDocumentSnapshot> memories = snapshot.data!.docs;
          memories.sort((a, b) {
            var aTime = (a.data() as Map)['timestamp'] as Timestamp?;
            var bTime = (b.data() as Map)['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              var data = memories[index].data() as Map<String, dynamic>;
              DateTime date = data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : DateTime.now();

              return ListTile(
                leading: Icon(Icons.circle, color: _getMoodColor(data['auraType'])),
                title: Text(data['auraType'] ?? "Aura", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['note'] ?? ""),
                trailing: Text(DateFormat('h:mm a\nMMM d').format(date), style: const TextStyle(fontSize: 10)),
              );
            },
          );
        },
      ),
    );
  }

  Color _getMoodColor(String? mood) {
    switch (mood) {
      case 'Happy': return Colors.amber;
      case 'Calm': return Colors.cyan;
      case 'Peaceful': return Colors.green;
      case 'Energetic': return Colors.orange;
      case 'Sad': return Colors.blueGrey;
      case 'Angry': return Colors.redAccent;
      default: return Colors.purpleAccent;
    }
  }
}

