import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Safe Logout Function
  void _handleLogout(BuildContext context) async {
    try {
      // 1. Sign out from Firebase first
      await FirebaseAuth.instance.signOut();
      
      // 2. Clear the entire navigation stack and go to the very first screen (Login/Auth wrapper)
      // This prevents the ProfilePage from trying to rebuild without a user.
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    // Fallback if user is null during the transition
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final String email = user.email ?? "Explorer";
    final String name = email.split('@')[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text("Your Identity", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.spaceDark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // --- AURA IDENTITY CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: AppColors.auraGradient,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person_rounded, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 20),
                    
                    // Stats inside the card
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('memories')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        // If user logs out, the stream might return an error; we handle it gracefully.
                        if (snapshot.hasError || !snapshot.hasData) {
                          return _buildStatRow("0", "Active");
                        }
                        int count = snapshot.data!.docs.length;
                        return _buildStatRow(count.toString(), "Active");
                      }
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              _buildProfileOption(Icons.notifications_none_rounded, "Reminders", "Daily Aura Check-in"),
              _buildProfileOption(Icons.security_rounded, "Privacy", "Manage your data"),
              _buildProfileOption(Icons.help_outline_rounded, "Support", "Get help with your aura"),

              const SizedBox(height: 40),

              // --- FIXED LOGOUT BUTTON ---
              GestureDetector(
                onTap: () => _handleLogout(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.red.withOpacity(0.1)),
                  ),
                  child: const Center(
                    child: Text(
                      "Sign Out",
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("App Version 1.0.2", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String count, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMiniStat("Reflections", count),
        Container(width: 1, height: 20, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
        _buildMiniStat("Status", status),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgGradientStart,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.deepPurple, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.spaceDark)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}