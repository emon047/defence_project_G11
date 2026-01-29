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
            stream: FirebaseFirestore.instance
                .collection('nightly_reflections')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.deepPurple));
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(child: Text("Your story starts tonight.", style: TextStyle(color: Colors.grey)));
              }

              // Manual Sort: Newest first
              final sortedDocs = docs.toList()
                ..sort((a, b) {
                  Timestamp t1 = a['timestamp'] ?? Timestamp.now();
                  Timestamp t2 = b['timestamp'] ?? Timestamp.now();
                  return t2.compareTo(t1);
                });

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  var data = sortedDocs[index].data() as Map<String, dynamic>;
                  String docId = sortedDocs[index].id;
                  Timestamp? ts = data['timestamp'] as Timestamp?;
                  
                  // Check if reflection is less than 24 hours old
                  bool canEdit = false;
                  if (ts != null) {
                    final difference = DateTime.now().difference(ts.toDate());
                    canEdit = difference.inHours < 24;
                  }

                  return _buildTimelineCard(context, data, docId, canEdit);
                },
              );
            },
          ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, Map<String, dynamic> data, String docId, bool canEdit) {
    String dateStr = data['timestamp'] != null 
        ? DateFormat('EEEE, MMM d').format((data['timestamp'] as Timestamp).toDate())
        : "Recently";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              if (canEdit)
                InkWell(
                  onTap: () => _showEditDialog(context, data, docId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.auroraTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("Edit", style: TextStyle(color: AppColors.auroraTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          _reflectionItem(Icons.wb_sunny_outlined, "Best part", data['highlight'], Colors.orange),
          const Divider(height: 30),
          _reflectionItem(Icons.air_outlined, "Let it go", data['letting_go'], Colors.blueGrey),
          const Divider(height: 30),
          _reflectionItem(Icons.favorite_outline, "I'm grateful for", data['gratitude'], Colors.pinkAccent),
        ],
      ),
    );
  }

  Widget _reflectionItem(IconData icon, String label, String? text, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.spaceDark)),
        ]),
        const SizedBox(height: 6),
        Text(
          (text == null || text.isEmpty) ? "Nothing noted." : text, 
          style: const TextStyle(color: Colors.black54, fontSize: 15, height: 1.4)
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> data, String docId) {
    final hController = TextEditingController(text: data['highlight']);
    final lController = TextEditingController(text: data['letting_go']);
    final gController = TextEditingController(text: data['gratitude']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Update Reflection", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _editField("Best part", hController),
              _editField("Let it go", lController),
              _editField("I'm grateful for", gController),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.auroraTeal),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('nightly_reflections').doc(docId).update({
                'highlight': hController.text,
                'letting_go': lController.text,
                'gratitude': gController.text,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}