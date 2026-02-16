import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Local state for the unique "Appearance" work
  bool _glassEffect = true;
  double _uiOpacity = 0.05;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? "Explorer";
    final String name = email.split('@')[0].toUpperCase();
    const Color deepBackground = Color.fromARGB(255, 26, 28, 46);

    return Scaffold(
      backgroundColor: deepBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "PROFILE",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // --- AVATAR ---
            Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.auraGradient,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: deepBackground,
                  child: Text(
                    name.isNotEmpty ? name[0] : "M",
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
            Text(email, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),

            const SizedBox(height: 50),

            // --- MENU BUTTONS ---
            _buildProfileButton(
              icon: Icons.history_rounded, 
              label: "Aura History", 
              onTap: () => _showHistory(context)
            ),
            _buildProfileButton(
              icon: Icons.auto_awesome_motion_rounded, 
              label: "Appearance Settings", 
              onTap: () => _showVisualSettings(context)
            ),
            _buildProfileButton(
              icon: Icons.info_outline_rounded, 
              label: "About MemoAura", 
              onTap: () => _showAbout(context)
            ),

            const SizedBox(height: 40),
            _buildSignOutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 1. AURA HISTORY ---
  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1C2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("RECENT AURAS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _historyItem("☀️", "Radiant"),
                  _historyItem("🍃", "Calm"),
                  _historyItem("🌊", "Flow"),
                  _historyItem("✨", "Glow"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. UNIQUE VISUAL SETTINGS (EASY & UNIQUE) ---
  void _showVisualSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1C2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("INTERFACE CUSTOMIZER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 25),
                SwitchListTile(
                  title: const Text("Glassmorphism Effect", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  value: _glassEffect,
                  activeColor: AppColors.auroraTeal,
                  onChanged: (val) {
                    setModalState(() => _glassEffect = val);
                    setState(() => _glassEffect = val);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("UI Intensity", style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),
                Slider(
                  value: _uiOpacity,
                  min: 0.02,
                  max: 0.2,
                  activeColor: AppColors.auroraTeal,
                  onChanged: (val) {
                    setModalState(() => _uiOpacity = val);
                    setState(() => _uiOpacity = val);
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("SAVE ATMOSPHERE", style: TextStyle(color: AppColors.auroraTeal, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  // --- 3. ABOUT ---
  void _showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.auroraTeal,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(35),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("MEMOAURA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 3)),
            SizedBox(height: 15),
            Text(
              "Your digital sanctuary. Designed to help you track your internal atmosphere and find calm among the stars.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),
            Text("FINAL PROJECT // GROUP G11", style: TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _historyItem(String emoji, String label) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.white10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildProfileButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_uiOpacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _glassEffect ? Colors.white.withOpacity(0.1) : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.auroraTeal, size: 24),
              const SizedBox(width: 15),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(border: Border.all(color: Colors.redAccent.withOpacity(0.5)), borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text("SIGN OUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
      ),
    );
  }
}