import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class AddMemoryPage extends StatefulWidget {
  const AddMemoryPage({super.key});

  @override
  State<AddMemoryPage> createState() => _AddMemoryPageState();
}

class _AddMemoryPageState extends State<AddMemoryPage> {
  final TextEditingController _noteController = TextEditingController();
  String selectedMood = "Happy";
  bool _isSaving = false;
  
  final List<Map<String, dynamic>> moods = [
    {'label': 'Happy', 'icon': Icons.sentiment_very_satisfied_rounded, 'color': Colors.amber},
    {'label': 'Calm', 'icon': Icons.spa_rounded, 'color': Colors.cyan},
    {'label': 'Peaceful', 'icon': Icons.wb_twilight_rounded, 'color': Colors.green},
    {'label': 'Energetic', 'icon': Icons.bolt_rounded, 'color': Colors.orange},
    {'label': 'Sad', 'icon': Icons.cloud_rounded, 'color': Colors.blueGrey},
    {'label': 'Angry', 'icon': Icons.local_fire_department_rounded, 'color': Colors.redAccent},
  ];

  Future<void> _saveMemory() async {
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a small note")),
      );
      return;
    }

    // 1. Check if already saving to prevent double-taps
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // 2. Perform the async operation
      await FirebaseFirestore.instance.collection('memories').add({
        'userId': user?.uid,
        'auraType': selectedMood,
        'note': _noteController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. IMPORTANT: Check if the widget is still in the tree before navigating
      // This prevents the "disposed EngineFlutterView" error
      if (!mounted) return;
      
      Navigator.of(context).pop();

    } catch (e) {
      // 4. If error occurs, reset saving state but only if still mounted
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Log Aura", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.spaceDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView( // Added scroll view to prevent overflow errors
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("How are you feeling?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 15, crossAxisSpacing: 15,
                ),
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedMood == moods[index]['label'];
                  return GestureDetector(
                    onTap: () => setState(() => selectedMood = moods[index]['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? moods[index]['color'] : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isSelected ? moods[index]['color'] : Colors.grey.shade200, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(moods[index]['icon'], color: isSelected ? Colors.white : Colors.grey.shade400, size: 30),
                          const SizedBox(height: 4),
                          Text(moods[index]['label'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text("Note", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMemory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spaceDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Aura", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}