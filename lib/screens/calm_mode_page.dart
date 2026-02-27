import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class CalmModePage extends StatefulWidget {
  const CalmModePage({super.key}); 

  @override
  State<CalmModePage> createState() =>
      _CalmModePageState(); 
}

// with SingleTickerProviderStateMixin allows the class to handle a single animation clock
class _CalmModePageState extends State<CalmModePage>
    with SingleTickerProviderStateMixin {
      
  // 1. VARIABLES & INITIALIZATION
  late AnimationController
      _controller; 
  late Animation<double>
      _scaleAnimation; 
  String _statusText = "Prepare";

  Timer? _sessionTimer; 
  int _secondsRemaining = 60; 
  bool _isFinished = false; 

  @override
  void initState() {
    super.initState(); 

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 10), 
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        // Inhale Phase
        tween: Tween<double>(begin: 1.0, end: 1.8)
            .chain(CurveTween(curve: Curves.easeInOut)), 
        weight: 40, 
      ),
      TweenSequenceItem(
        // Hold Phase
        tween: ConstantTween<double>(1.8), 
        weight: 20,
      ),
      TweenSequenceItem(
        // Exhale Phase
        tween: Tween<double>(begin: 1.8, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)), 
        weight: 40, 
      ),
    ]).animate(_controller);

    // Listen to the animation progress to update the text label
    _controller.addListener(() {
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
    _startSession(); 
  }

  // 2. SESSION LOGIC & TIMERS

  void _startSession() {
    _controller.repeat();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; 
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--; 
        } else {
          _finishSession(); 
        }
      });
    });
  }

  void _finishSession() {
    _sessionTimer?.cancel(); 
    _controller.stop(); 
    setState(() {
      _isFinished = true; 
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _controller.dispose(); 
    super.dispose(); 
  }

  // 3. UI CONSTRUCTION
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), 
      body: Container(
        // Full screen container
        decoration: BoxDecoration(
          // Subtle background glow
          gradient: RadialGradient(
            center: Alignment.center, 
            radius: 1.2, 
            colors: [
              AppColors.deepPurple.withOpacity(0.15), 
              const Color(0xFF0F111A), 
            ],
          ),
        ),
        child: Stack(
          // Layer elements on top of each other
          children: [
            // LAYER 1: Main Breathing UI
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  // Top Timer Display
                  Text(
                    "00:${_secondsRemaining.toString().padLeft(2, '0')}", 
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 18, letterSpacing: 2),
                  ),
                  const SizedBox(height: 40), 

                  // The Animated Breathing Core
                  AnimatedBuilder(
                    animation:
                        _scaleAnimation, 
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment
                            .center, 
                        children: [
                          _breathingCircle(
                              opacity: 0.08,
                              scaleMultiplier: 0.5), 
                          _breathingCircle(
                              opacity: 0.15,
                              scaleMultiplier: 0.25), 
                          Container(
                            // The Main Colored Circle
                            width: 150 *
                                _scaleAnimation
                                    .value, 
                            height: 150 *
                                _scaleAnimation
                                    .value, 
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle, 
                              gradient: AppColors
                                  .auraGradient, 
                            ),
                            child: Center(
                              child: Text(
                                _isFinished
                                    ? "✓"
                                    : _statusText, 
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 100), 
                  const Text("Follow the circle",
                      style:
                          TextStyle(color: Colors.white54, letterSpacing: 2)),
                ],
              ),
            ),

            // LAYER 2: Close Button (Top Left)
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // LAYER 3: Completion Overlay (Only shows when _isFinished is true)
            if (_isFinished) _buildCompletionOverlay(),
          ],
        ),
      ),
    );
  }

  // 4. HELPER UI COMPONENTS
  // Creates the background echo circles that grow with the main circle
  Widget _breathingCircle(
      {required double opacity, required double scaleMultiplier}) {
    return Container(
      width: 150 *
          (_scaleAnimation.value +
              scaleMultiplier), 
      height: 150 * (_scaleAnimation.value + scaleMultiplier),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.auroraTeal.withOpacity(opacity), 
      ),
    );
  }

  // Creates the full-screen dark overlay when session ends
  Widget _buildCompletionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8), 
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wb_sunny_rounded,
                color: AppColors.auroraTeal, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Session Complete",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your aura feels much lighter now.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              // Final Return Button
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.auroraTeal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Return to Home",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
