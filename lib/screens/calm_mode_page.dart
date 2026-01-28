import 'package:flutter/material.dart';
import '../core/theme.dart';

class CalmModePage extends StatefulWidget {
  const CalmModePage({super.key});

  @override
  State<CalmModePage> createState() => _CalmModePageState();
}

class _CalmModePageState extends State<CalmModePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _statusText = "Prepare";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Total cycle: 4 Inhale + 2 Hold + 4 Exhale
    );

    // Custom breathing sequence
    _scaleAnimation = TweenSequence<double>([
      // Inhale (4s): Scale from 1.0 to 1.8
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.8).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40, 
      ),
      // Hold (2s): Stay at 1.8
      TweenSequenceItem(
        tween: ConstantTween<double>(1.8),
        weight: 20,
      ),
      // Exhale (4s): Scale from 1.8 back to 1.0
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.8, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _controller.addListener(() {
      setState(() {
        if (_controller.value < 0.4) {
          _statusText = "Inhale";
        } else if (_controller.value < 0.6) {
          _statusText = "Hold";
        } else {
          _statusText = "Exhale";
        }
      });
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text("Calm Mode", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Layered Breathing Animation
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Glow 1
                    _breathingCircle(opacity: 0.1, scaleMultiplier: 0.4),
                    // Outer Glow 2
                    _breathingCircle(opacity: 0.2, scaleMultiplier: 0.2),
                    // Main Circle
                    Container(
                      width: 150 * _scaleAnimation.value,
                      height: 150 * _scaleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.auraGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepPurple.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 100),
            const Text(
              "Follow the circle",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breathingCircle({required double opacity, required double scaleMultiplier}) {
    return Container(
      width: 150 * (_scaleAnimation.value + scaleMultiplier),
      height: 150 * (_scaleAnimation.value + scaleMultiplier),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.auroraTeal.withOpacity(opacity),
      ),
    );
  }
}