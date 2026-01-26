import 'package:flutter/material.dart';
import '../core/theme.dart';

class HealingModePage extends StatelessWidget {
  const HealingModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Healing Space")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppColors.auroraTeal.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: AppColors.auroraTeal.withOpacity(0.05), blurRadius: 30)],
              ),
              child: Column(
                children: [
                  const Text("Reframe", style: TextStyle(color: AppColors.auroraTeal, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 20),
                  const Text(
                    "What is one small lesson this pain taught you?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Type your reflection...",
                      filled: true,
                      fillColor: AppColors.softLavender.withOpacity(0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _actionBtn("Next Step"),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String text) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(color: AppColors.spaceDark, borderRadius: BorderRadius.circular(20)),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }
}