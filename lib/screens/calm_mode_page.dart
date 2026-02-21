import 'dart:async'; // Import Timer for the 60-second countdown
import 'package:flutter/material.dart'; // Core Flutter UI framework
import '../core/theme.dart'; // Import custom app theme and colors

class CalmModePage extends StatefulWidget { // Define a widget that changes its appearance over time
  const CalmModePage({super.key}); // Standard constructor with key

  @override
  State<CalmModePage> createState() => _CalmModePageState(); // Link to the logic state class
}

// with SingleTickerProviderStateMixin allows the class to handle a single animation clock
class _CalmModePageState extends State<CalmModePage> with SingleTickerProviderStateMixin {
  
  // ==========================================
  // 1. VARIABLES & INITIALIZATION
  // ==========================================
  late AnimationController _controller; // The "engine" that drives the breathing animation
  late Animation<double> _scaleAnimation; // The "output" that changes the circle size
  String _statusText = "Prepare"; // Text inside the circle (Inhale/Hold/Exhale)
  
  Timer? _sessionTimer; // The background timer for the 1-minute session
  int _secondsRemaining = 30; // Countdown starting point (1 minute)
  bool _isFinished = false; // Flag to check if the user completed the session

  @override
  void initState() { // Function runs the moment the page is created
    super.initState(); // Call parent initialization

    // Define the animation engine to last 10 seconds per breath cycle
    _controller = AnimationController(
      vsync: this, // Bind to this widget's lifecycle
      duration: const Duration(seconds: 10), // Total time for Inhale + Hold + Exhale
    );

    // Create a sequence of movements: Grow (40%), Stay (20%), Shrink (40%)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem( // Inhale Phase
        tween: Tween<double>(begin: 1.0, end: 1.8).chain(CurveTween(curve: Curves.easeInOut)), // Smooth growth
        weight: 40, // 4 seconds (40% of 10s)
      ),
      TweenSequenceItem( // Hold Phase
        tween: ConstantTween<double>(1.8), // Keep size steady
        weight: 20, // 2 seconds (20% of 10s)
      ),
      TweenSequenceItem( // Exhale Phase
        tween: Tween<double>(begin: 1.8, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), // Smooth shrink
        weight: 40, // 4 seconds (40% of 10s)
      ),
    ]).animate(_controller); // Apply this sequence to our main controller

    // Listen to the animation progress to update the text label
    _controller.addListener(() {
      if (!mounted) return; // Safety check: stop if user left the page
      setState(() { // Rebuild UI with new text
        if (_controller.value < 0.4) { // First 40% of time
          _statusText = "Inhale";
        } else if (_controller.value < 0.6) { // Middle 20% of time
          _statusText = "Hold";
        } else { // Final 40% of time
          _statusText = "Exhale";
        }
      });
    });

    _startSession(); // Automatically start the timer and animation
  }

  // ==========================================
  // 2. SESSION LOGIC & TIMERS
  // ==========================================
  void _startSession() {
    _controller.repeat(); // Make the breathing animation loop forever
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) { // Run every 1 second
      if (!mounted) return; // Safety check
      setState(() {
        if (_secondsRemaining > 0) { // If time is left
          _secondsRemaining--; // Count down
        } else {
          _finishSession(); // End the session at 0
        }
      });
    });
  }

  void _finishSession() {
    _sessionTimer?.cancel(); // Stop the countdown timer
    _controller.stop(); // Freeze the breathing circle
    setState(() {
      _isFinished = true; // Show the "Complete" overlay
    });
  }

  @override
  void dispose() { // Runs when the user leaves the page
    _sessionTimer?.cancel(); // Kill the timer to save battery
    _controller.dispose(); // Kill the animation to save memory
    super.dispose(); // Call parent cleanup
  }

  // ==========================================
  // 3. UI CONSTRUCTION
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // Deep dark background color
      body: Container( // Full screen container
        decoration: BoxDecoration( // Subtle background glow
          gradient: RadialGradient(
            center: Alignment.center, // Glow starts from middle
            radius: 1.2, // Spread size
            colors: [
              AppColors.deepPurple.withOpacity(0.15), // Very faint purple
              const Color(0xFF0F111A), // Fade into dark
            ],
          ),
        ),
        child: Stack( // Layer elements on top of each other
          children: [
            // LAYER 1: Main Breathing UI
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Vertical center
                children: [
                  // Top Timer Display
                  Text(
                    "00:${_secondsRemaining.toString().padLeft(2, '0')}", // Format to "00:59"
                    style: const TextStyle(color: Colors.white38, fontSize: 18, letterSpacing: 2),
                  ),
                  const SizedBox(height: 40), // Spacing

                  // The Animated Breathing Core
                  AnimatedBuilder(
                    animation: _scaleAnimation, // Rebuild only this part as circle grows
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center, // Center circles on top of each other
                        children: [
                          _breathingCircle(opacity: 0.08, scaleMultiplier: 0.5), // Outer faint halo
                          _breathingCircle(opacity: 0.15, scaleMultiplier: 0.25), // Middle faint halo
                          Container( // The Main Colored Circle
                            width: 150 * _scaleAnimation.value, // Size based on animation value
                            height: 150 * _scaleAnimation.value, // Size based on animation value
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle, // Circular shape
                              gradient: AppColors.auraGradient, // Teal/Purple gradient
                            ),
                            child: Center(
                              child: Text(
                                _isFinished ? "✓" : _statusText, // Show checkmark if done, else text
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 100), // Spacing
                  const Text("Follow the circle", style: TextStyle(color: Colors.white54, letterSpacing: 2)),
                ],
              ),
            ),

            // LAYER 2: Close Button (Top Left)
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context), // Exit page
              ),
            ),

            // LAYER 3: Completion Overlay (Only shows when _isFinished is true)
            if (_isFinished) _buildCompletionOverlay(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. HELPER UI COMPONENTS
  // ==========================================

  // Creates the background "echo" circles that grow with the main circle
  Widget _breathingCircle({required double opacity, required double scaleMultiplier}) {
    return Container(
      width: 150 * (_scaleAnimation.value + scaleMultiplier), // Slightly larger than main
      height: 150 * (_scaleAnimation.value + scaleMultiplier),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.auroraTeal.withOpacity(opacity), // Very faint teal
      ),
    );
  }

  // Creates the full-screen dark overlay when session ends
  Widget _buildCompletionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8), // Darken the whole screen
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content height
          children: [
            const Icon(Icons.wb_sunny_rounded, color: AppColors.auroraTeal, size: 80), // Sun icon
            const SizedBox(height: 20),
            const Text(
              "Session Complete",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your aura feels much lighter now.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton( // Final Return Button
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.auroraTeal,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Return to Home", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}