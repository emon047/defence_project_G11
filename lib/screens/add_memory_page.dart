import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart'; // Ensure this path is correct for your project

class AddMemoryPage extends StatefulWidget {
  const AddMemoryPage({super.key});

  @override
  State<AddMemoryPage> createState() => _AddMemoryPageState();
}

class _AddMemoryPageState extends State<AddMemoryPage> {
  final TextEditingController _noteController = TextEditingController();
  String _selectedMood = 'Happy';
  bool _isSaving = false;

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Happy', 'emoji': '😊'},
    {'name': 'Calm', 'emoji': '😌'},
    {'name': 'Energetic', 'emoji': '⚡'},
    {'name': 'Sad', 'emoji': '😢'},
    {'name': 'Angry', 'emoji': '😤'},
  ];

  @override
  void dispose() {
    _noteController.dispose(); // Good practice to prevent memory leaks
    super.dispose();
  }

  void _saveMemory() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a note before saving")),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('memories').add({
        'userId': user?.uid,
        'auraType': _selectedMood,
        'note': _noteController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      appBar: AppBar(
        title: const Text(
          "Log Your Aura", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How are you feeling?",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            // Mood Selector
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedMood == _moods[index]['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = _moods[index]['name']),
                    child: Container(
                      width: 85,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.auroraTeal : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.auroraTeal : Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_moods[index]['emoji'], style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 5),
                          Text(
                            _moods[index]['name'],
                            style: TextStyle(
                              color: isSelected ? AppColors.spaceDark : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 40),
            const Text(
              "Describe your aura",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _noteController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "What's happening...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.auroraTeal),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            _isSaving
                ? const Center(child: CircularProgressIndicator(color: AppColors.auroraTeal))
                : SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _saveMemory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.auroraTeal,
                        foregroundColor: AppColors.spaceDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "SAVE LOG",
                        // FIXED: Using FontWeight.w900 instead of .black to avoid member errors
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

