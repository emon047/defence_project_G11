import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class GoodnightReflectionPage extends StatefulWidget {
  const GoodnightReflectionPage({super.key});

  @override
  State<GoodnightReflectionPage> createState() => _GoodnightReflectionPageState();
}

class _GoodnightReflectionPageState extends State<GoodnightReflectionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // List of controllers to capture text for each specific prompt
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());

  final List<Map<String, String>> _prompts = [
    {"q": "What was the highlight of your day?", "hint": "A small win or a quiet moment..."},
    {"q": "What is one thing you're letting go of?", "hint": "A stress or a busy thought..."},
    {"q": "Name three things you are grateful for.", "hint": "1. 2. 3..."},
    {"q": "How do you want to feel tomorrow?", "hint": "Peaceful, energized, focused..."},
  ];

  @override
  void dispose() {
    // Always dispose controllers to save memory
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  // Purposeful Logic: Save to Firebase
  Future<void> _saveReflection() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('nightly_reflections').add({
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'highlight': _controllers[0].text,
        'letting_go': _controllers[1].text,
        'gratitude': _controllers[2].text,
        'tomorrow_intent': _controllers[3].text,
      });
    } catch (e) {
      debugPrint("Error saving: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Stack(
        children: [
          _buildAmbientGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _prompts.length,
                    itemBuilder: (context, index) => _buildPromptCard(index),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            DateFormat('EEEE, MMM d').format(DateTime.now()),
            style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildPromptCard(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 32),
          const SizedBox(height: 24),
          Text(
            _prompts[index]['q']!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _controllers[index],
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: _prompts[index]['hint'],
              hintStyle: const TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(_prompts.length, (idx) => Container(
              margin: const EdgeInsets.only(right: 8),
              width: _currentPage == idx ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == idx ? AppColors.auroraTeal : Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
            )),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.auroraTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              if (_currentPage < _prompts.length - 1) {
                _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
              } else {
                await _saveReflection(); // Actual Purpose: Saving your data
                _showCompletionSheet();
              }
            },
            child: Text(
              _currentPage == _prompts.length - 1 ? "Finish" : "Next",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow() {
    return Positioned(
      top: -100,
      right: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.deepPurple.withOpacity(0.1),
        ),
      ),
    );
  }

  void _showCompletionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1C2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("✨", style: TextStyle(fontSize: 50)),
            const SizedBox(height: 20),
            const Text("Reflection Stored", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Your nightly aura has been saved to your timeline.", 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.white54)
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: () { 
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
              child: const Text("Sleep Well"),
            )
          ],
        ),
      ),
    );
  }
}