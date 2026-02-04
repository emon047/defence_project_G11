import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? "Explorer";
    final String name = email.split('@')[0].toUpperCase();

    // The specific dark background color
    const Color deepBackground = Color.fromARGB(255, 26, 28, 46);

    return Scaffold(
      backgroundColor: deepBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              
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

              // --- BUTTON MENU ---
              _buildProfileButton(
                icon: Icons.history_rounded, 
                label: "Aura History", 
                onTap: () { /* Navigate to History */ }
              ),
              _buildProfileButton(
                icon: Icons.settings_outlined, 
                label: "Settings", 
                onTap: () { /* Navigate to Settings */ }
              ),
              _buildProfileButton(
                icon: Icons.info_outline_rounded, 
                label: "About MemoAura", 
                onTap: () { /* Show About Dialog */ }
              ),

              const SizedBox(height: 40),

              // --- SIGN OUT BUTTON ---
              _buildSignOutButton(context),
              
              const SizedBox(height: 20),
              const Text("v1.0.2", style: TextStyle(color: Colors.white12, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // Styled button for Menu Items
  Widget _buildProfileButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), // Subtle button feel
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.auroraTeal, size: 24),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Special styled button for Sign Out
  Widget _buildSignOutButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "SIGN OUT",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}

 