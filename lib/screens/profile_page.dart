import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user's info
    final user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "User Email";
    final String userName = userEmail.split('@')[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Avatar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.auraGradient,
                ),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=9"),
                ),
              ),
              const SizedBox(height: 25),
              
              // Name and Email
              Text(
                userName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.spaceDark),
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              
              const SizedBox(height: 50),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // Go back to sign in and clear history
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}