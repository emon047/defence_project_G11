import 'package:flutter/material.dart';
import '../core/theme.dart';

class CalmModePage extends StatelessWidget {
  const CalmModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Breathe with the aura", style: TextStyle(color: Colors.white54, letterSpacing: 2)),
            const SizedBox(height: 60),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.auroraTeal, AppColors.auroraTeal.withOpacity(0)]),
                boxShadow: [BoxShadow(color: AppColors.auroraTeal.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)],
              ),
              child: const Center(child: Text("Inhale", style: TextStyle(color: Colors.white, fontSize: 18))),
            ),
            const SizedBox(height: 100),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white24, size: 30),
            )
          ],
        ),
      ),
    );
  }
}