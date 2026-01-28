import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for database
import 'package:firebase_auth/firebase_auth.dart';    // Added for user ID
import '../core/theme.dart';

class AddMemoryPage extends StatefulWidget {
  const AddMemoryPage({super.key});

  @override
  State<AddMemoryPage> createState() => _AddMemoryPageState();
}

class _AddMemoryPageState extends State<AddMemoryPage> {
  final TextEditingController _noteController = TextEditingController();
  String _selectedEmoji = "😊"; 
  bool _isSaving = false;

  final List<String> _emojis = ["😊", "😔", "🌿", "🔥", "🧘", "🌈"];

  // THE BRAIN: Saves the aura to the cloud
  void _saveAura() async {
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a small note about your aura")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      await FirebaseFirestore.instance.collection('memories').add({
        'userId': user?.uid,
        'emoji': _selectedEmoji,
        'note': _noteController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aura Captured Successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Your Aura")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Mood Tags", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _emojis.map((emoji) => GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _selectedEmoji == emoji ? AppColors.softLavender : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 50),
            _isSaving 
              ? const CircularProgressIndicator()
              : GestureDetector(
                  onTap: _saveAura,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(color: AppColors.spaceDark, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text("Save Memory", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}