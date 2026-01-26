import 'package:flutter/material.dart';
import '../core/theme.dart';

class AddMemoryPage extends StatelessWidget {
  const AddMemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Memory")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            TextField(
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            const Row(children: [Icon(Icons.mood), SizedBox(width: 10), Text("Mood Tags", style: TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _moodChip("😊"), _moodChip("😔"), _moodChip("🌿"), _moodChip("🔥"),
            ]),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _mediaBtn(Icons.camera_alt, "Photo"),
                _mediaBtn(Icons.mic, "Voice"),
                _mediaBtn(Icons.location_on, "Loc"),
              ],
            ),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: () => Navigator.pop(context),
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

  Widget _moodChip(String emoji) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black.withOpacity(0.05))),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _mediaBtn(IconData icon, String label) {
    return Column(children: [
      CircleAvatar(backgroundColor: AppColors.deepPurple.withOpacity(0.1), child: Icon(icon, color: AppColors.deepPurple)),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ]);
  }
}