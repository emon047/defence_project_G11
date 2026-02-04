import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class MoodAnalyticsPage extends StatefulWidget {
  const MoodAnalyticsPage({super.key});

  @override
  State<MoodAnalyticsPage> createState() => _MoodAnalyticsPageState();
}

class _MoodAnalyticsPageState extends State<MoodAnalyticsPage> {
  bool _isLoading = true;
  double _harmonyIndex = 0;
  
  int _happyCount = 0;
  int _growthCount = 0;
  int _depthCount = 0; 
  int _fogCount = 0;   

  @override
  void initState() {
    super.initState();
    _calculateHarmony();
  }

  // Logic to determine the sentence based on your counts
  String _getDynamicInsight() {
    if (_happyCount == 0 && _growthCount == 0 && _depthCount == 0) {
      return "Your journey is just beginning. Keep reflecting to reveal your aura.";
    }

    // 1. Check for high "Fog" (Avoided thoughts)
    if (_fogCount > _happyCount && _fogCount > _growthCount) {
      return "There's a bit of fog lately. Try to face one small truth today to clear the air.";
    }

    // 2. Check for high "Growth" (Productivity)
    if (_growthCount >= _happyCount && _growthCount >= _depthCount) {
      return "You're in a season of building. Your focus is creating a stronger version of you.";
    }

    // 3. Check for high "Happy" (Joy)
    if (_happyCount > _growthCount && _happyCount > _depthCount) {
      return "Your aura is radiant! This light within you is your most natural state.";
    }

    // 4. Check for high "Depth" (Honesty/Reflection)
    if (_depthCount > _happyCount) {
      return "Your depth is your superpower. Honesty with yourself is the highest form of growth.";
    }

    // Default sentence
    return "Your aura thrives on honesty. Keep capturing your true self.";
  }

  Future<void> _calculateHarmony() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('nightly_reflections')
          .where('userId', isEqualTo: user.uid)
          .get();

      final happyWords = {'happy', 'joy', 'smile', 'great', 'love', 'amazing', 'fun', 'blessed', 'excited'};
      final depthWords = {'sad', 'cry', 'tired', 'hurt', 'lonely', 'hard', 'pain', 'miss', 'heavy'};
      final growthWords = {'good', 'done', 'work', 'learn', 'better', 'proud', 'growth', 'focus', 'active'};
      final fogWords = {'ignore', 'skip', 'nothing', 'forgot', 'whatever', 'maybe', 'idk'};

      int h = 0, d = 0, g = 0, f = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String text = "${data['highlight']} ${data['gratitude']} ${data['letting_go']}".toLowerCase();

        for (var word in happyWords) { if (text.contains(word)) h++; }
        for (var word in depthWords) { if (text.contains(word)) d++; }
        for (var word in growthWords) { if (text.contains(word)) g++; }
        for (var word in fogWords) { if (text.contains(word)) f++; }
      }

      double rawScore = ((h + g) * 10.0) + (d * 5.0) - (f * 15.0);
      
      setState(() {
        _happyCount = h;
        _depthCount = d;
        _growthCount = g;
        _fogCount = f;
        _harmonyIndex = rawScore.clamp(0, 100);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text("Aura Analytics", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.spaceDark),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.deepPurple))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              children: [
                _buildHarmonyCircle(),
                const SizedBox(height: 24),
                _buildVibeGrid(), 
                const SizedBox(height: 24),
                _buildVibeGuide(),
                const SizedBox(height: 24),
                _buildInsightCard(), // Now uses the dynamic logic
                const SizedBox(height: 30),
              ],
            ),
          ),
    );
  }

  Widget _buildHarmonyCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(
            value: _harmonyIndex / 100,
            strokeWidth: 8,
            color: AppColors.auroraTeal,
            backgroundColor: Colors.white,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${_harmonyIndex.toInt()}%", 
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: AppColors.spaceDark)),
            const Text("Harmony", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildVibeGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8, 
      children: [
        _vibeCard("Happy", _happyCount, Colors.orangeAccent, Icons.wb_sunny_rounded),
        _vibeCard("Growth", _growthCount, AppColors.auroraTeal, Icons.auto_graph_rounded),
        _vibeCard("Depth", _depthCount, AppColors.deepPurple, Icons.opacity_rounded),
        _vibeCard("Fog", _fogCount, Colors.blueGrey, Icons.cloud_off_rounded),
      ],
    );
  }

  Widget _vibeCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$count", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVibeGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("NOTE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: AppColors.spaceDark)),
          const SizedBox(height: 8),
          _guideItem(Colors.orangeAccent, "Happy: Joyful moments."),
          _guideItem(AppColors.auroraTeal, "Growth: Productive focus."),
          _guideItem(AppColors.deepPurple, "Depth: Honest reflections."),
          _guideItem(Colors.blueGrey, "Fog: Avoided thoughts."),
        ],
      ),
    );
  }

  Widget _guideItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.auraGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPurple.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        _getDynamicInsight(), // CALLING THE LOGIC HERE
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 14, 
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}