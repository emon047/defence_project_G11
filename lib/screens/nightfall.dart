import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:intl/intl.dart'; 
import '../core/theme.dart'; 

//NIGHTFALL PAGE 
class NightfallPage extends StatefulWidget {
  const NightfallPage({super.key});
  @override
  State<NightfallPage> createState() => _NightfallPageState();
}

class _NightfallPageState extends State<NightfallPage> {
  // 1. Initial State & Controllers
  final TextEditingController _highlightController = TextEditingController();
  String _selectedMood = "Neutral";
  bool _isSaving = false;

  // Data list to define available mood options
  final List<Map<String, String>> _moods = [
    {"label": "Sad", "emoji": "😔"},
    {"label": "Down", "emoji": "☁️"},
    {"label": "Neutral", "emoji": "😐"},
    {"label": "Happy", "emoji": "😊"},
    {"label": "Excited", "emoji": "🤩"},
  ];

  // 2. Core Logic: Saving Data to Firebase
  Future<void> _saveEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_highlightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please share a highlight first!")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('nightly_reflections').add({
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'highlight': _highlightController.text.trim(),
        'mood': _selectedMood,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Save error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // 3. UI Construction (Top-to-Bottom sequence)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 28, 46),
      appBar: AppBar(
        title: const Text("NIGHTFALL",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Allow to scroll if content is long
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STEP A: Input Box
            const Text("Highlight of the day", // Section label
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            TextField(
              controller: _highlightController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "What was the best part?",
                hintStyle: const TextStyle(color: Colors.white24),
                fillColor: Colors.white.withOpacity(0.05),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 40),

            // STEP B: Mood Selection
            const Text("Select your today's mood",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moods.map((m) {
                bool isSelected = _selectedMood == m['label'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = m['label']!),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.auroraTeal.withOpacity(0.2)
                              : Colors.white.withOpacity(0.03),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.auroraTeal
                                  : Colors.white10),
                        ),

                        child: Text(m['emoji']!,
                            style: const TextStyle(
                                fontSize: 24)),
                      ),
                      const SizedBox(height: 8),
                      Text(m['label']!,
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white38,
                              fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 50),

            // STEP C: Execution Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.auroraTeal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                onPressed: _isSaving ? null : _saveEntry,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SAVE & FINISH",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//TIMELINE PAGE 
class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});
  @override
  Widget build(BuildContext context) {
    // UI construction
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 28, 46),
      appBar: AppBar(
        title: const Text("TIMELINE",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          //Back button
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      //body of Timelinepage checks if user is logged in and fetch their data
      body: userId == null
          ? const Center(
              child:
                  Text("Please login", style: TextStyle(color: Colors.white)))
          : StreamBuilder<QuerySnapshot>(
              // 1. Fetching Stream
              stream: FirebaseFirestore.instance
                  .collection('nightly_reflections')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("Your journey starts tonight.",
                          style: TextStyle(color: Colors.white38)));
                }

                // 2. Sorting Data (Latest on Top)
                final docs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    Timestamp t1 = a['timestamp'] ?? Timestamp.now();
                    Timestamp t2 = b['timestamp'] ?? Timestamp.now();
                    return t2.compareTo(t1);
                  });

                // 3. Rendering List Items
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    //Logic for building each individual card
                    var data = docs[index].data() as Map<String, dynamic>;
                    DateTime date =
                        (data['timestamp'] as Timestamp?)?.toDate() ??
                            DateTime.now();
                    String mood = data['mood'] ?? "Neutral";
                    String emoji = "😐";
                    if (mood == "Sad") emoji = "😔";
                    if (mood == "Down") emoji = "☁️";
                    if (mood == "Happy") emoji = "😊";
                    if (mood == "Excited") {
                      emoji = "🤩";
                    }

                    return Container(
                      // Wrapper for each card
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // Card styling
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        // Arrange content inside card vertically
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card children
                          Row(
                            // Arrange date and mood chip horizontally
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Start Row children
                              Column(
                                // Date column
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Start Date children
                                  Text(
                                      DateFormat('EEEE')
                                          .format(date)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          color: AppColors.auroraTeal,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900)),
                                  Text(DateFormat('MMM dd, yyyy').format(date),
                                      style: const TextStyle(
                                          color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                              Container(
                                //The mood chip/badge
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  //Badge background
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text("$emoji $mood",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text("HIGHLIGHT",
                              style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1)),
                          const SizedBox(height: 6),
                          Text(data['highlight'] ?? "...",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.4)),
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
