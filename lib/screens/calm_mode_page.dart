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
      duration: const Duration(seconds: 10),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.8).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40, 
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.8),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.8, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _controller.addListener(() {
      // FIX: Check if the widget is still "mounted" before calling setState.
      // This stops the sea of red assertion errors.
      if (!mounted) return; 

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
    // ALWAYS dispose the controller to free up memory
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UPDATED: Using a trendy Dark Aura background instead of flat dark
      backgroundColor: const Color(0xFF0F111A), 
      appBar: AppBar(
        title: const Text("Calm Mode", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        centerTitle: true,
        // UPDATED: Transparent look
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              AppColors.deepPurple.withOpacity(0.15),
              const Color(0xFF0F111A),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow circles kept as per your logic
                      _breathingCircle(opacity: 0.08, scaleMultiplier: 0.5),
                      _breathingCircle(opacity: 0.15, scaleMultiplier: 0.25),
                      
                      // Main Circle
                      Container(
                        width: 150 * _scaleAnimation.value,
                        height: 150 * _scaleAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // UPDATED: Using your Aura Gradient
                          gradient: AppColors.auraGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.auroraTeal.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 120),
              const Text(
                "Follow the circle",
                style: TextStyle(
                  color: Colors.white54, 
                  fontSize: 14, 
                  letterSpacing: 2, 
                  fontWeight: FontWeight.w300
                ),
              ),
            ],
          ),
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
        // UPDATED: Aurora Teal for the glow
        color: AppColors.auroraTeal.withOpacity(opacity),
      ),
    );
  }
}