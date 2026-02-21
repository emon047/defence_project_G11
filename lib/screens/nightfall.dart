import 'package:flutter/material.dart'; // Import core Flutter UI components
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase database (Firestore)
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:intl/intl.dart'; // Import library for date formatting
import '../core/theme.dart'; // Import your custom app theme colors

// =======================================================================
// SECTION 1: NIGHTFALL PAGE (Data Input Serial)
// =======================================================================
class NightfallPage extends StatefulWidget { // Define a widget that can change its state
  const NightfallPage({super.key}); // Standard constructor with key for widget tree tracking

  @override
  State<NightfallPage> createState() => _NightfallPageState(); // Create the mutable state for this page
}

class _NightfallPageState extends State<NightfallPage> { // The actual logic and UI state class
  // 1. Initial State & Controllers
  final TextEditingController _highlightController = TextEditingController(); // Controller to read text from TextField
  String _selectedMood = "Neutral"; // Variable to track the user's currently selected mood
  bool _isSaving = false; // Flag to show loading spinner and prevent double-clicks

  final List<Map<String, String>> _moods = [ // Data list to define available mood options
    {"label": "Sad", "emoji": "😔"}, // Map entry for Sad
    {"label": "Down", "emoji": "☁️"}, // Map entry for Down
    {"label": "Neutral", "emoji": "😐"}, // Map entry for Neutral
    {"label": "Happy", "emoji": "😊"}, // Map entry for Happy
    {"label": "Excited", "emoji": "🤩"}, // Map entry for Excited
  ]; // End of mood list

  // 2. Core Logic: Saving Data to Firebase
  Future<void> _saveEntry() async { // Asynchronous function to handle database communication
    final user = FirebaseAuth.instance.currentUser; // Get the currently logged-in user
    if (user == null) return; // Exit if no user is found (safety check)
    
    if (_highlightController.text.isEmpty) { // Check if the user left the text field blank
      ScaffoldMessenger.of(context).showSnackBar( // Show an alert at the bottom of the screen
        const SnackBar(content: Text("Please share a highlight first!")), // SnackBar message text
      ); // End of SnackBar
      return; // Stop the function from saving empty data
    } // End of validation

    setState(() => _isSaving = true); // Update UI to set 'saving' state to true (shows spinner)

    try { // Begin dangerous operation (network request)
      await FirebaseFirestore.instance.collection('nightly_reflections').add({ // Access Firestore and add new doc
        'userId': user.uid, // Store the specific user's ID for data ownership
        'timestamp': FieldValue.serverTimestamp(), // Tell Firebase to use its own clock for time
        'highlight': _highlightController.text.trim(), // Save the text while removing extra spaces
        'mood': _selectedMood, // Save the selected mood string
      }); // End of Firestore add
      if (mounted) Navigator.pop(context); // If page is still active, go back to previous screen
    } catch (e) { // Handle errors (like no internet)
      debugPrint("Save error: $e"); // Print the error to the console for developers
    } finally { // Run this no matter what happens (success or failure)
      if (mounted) setState(() => _isSaving = false); // Stop the loading spinner
    } // End of try-catch-finally
  } // End of _saveEntry

  // 3. UI Construction (Top-to-Bottom sequence)
  @override
  Widget build(BuildContext context) { // Function that describes how the UI looks
    return Scaffold( // Basic material design layout structure
      backgroundColor: const Color.fromARGB(255, 26, 28, 46), // Set the deep dark blue background
      appBar: AppBar( // The top bar of the application
        title: const Text("NIGHTFALL", // Set the screen title
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)), // Styling the title
        backgroundColor: Colors.transparent, // Make AppBar background see-through
        elevation: 0, // Remove the shadow under the AppBar
        centerTitle: true, // Align the title in the middle
        leading: IconButton( // Button on the left side of AppBar
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), // Use IOS style back icon
          onPressed: () => Navigator.pop(context), // Go back when pressed
        ), // End of IconButton
      ), // End of AppBar
      body: SingleChildScrollView( // Allow the user to scroll if content is too long (keyboard pop-up)
        padding: const EdgeInsets.all(30), // Add 30 pixels of space on all sides
        child: Column( // Arrange children vertically
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: [ // Start of column children
            // STEP A: Input Box
            const Text("Highlight of the day", // Section label
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), // Bold white style
            const SizedBox(height: 15), // Add vertical gap
            TextField( // Text input field
              controller: _highlightController, // Link input to our controller variable
              maxLines: 3, // Allow up to 3 lines of text
              style: const TextStyle(color: Colors.white), // Color of the text the user types
              decoration: InputDecoration( // Visual styling for the input
                hintText: "What was the best part?", // Placeholder text when empty
                hintStyle: const TextStyle(color: Colors.white24), // Faint color for placeholder
                fillColor: Colors.white.withOpacity(0.05), // Very subtle white background
                filled: true, // Enable the background color
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), // Rounded corners, no border line
              ), // End of Decoration
            ), // End of TextField
            
            const SizedBox(height: 40), // Add large vertical gap
            
            // STEP B: Mood Selection
            const Text("Rate today's mood", // Section label
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), // Bold white style
            const SizedBox(height: 20), // Add gap
            Row( // Arrange mood icons horizontally
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread icons evenly across the width
              children: _moods.map((m) { // Loop through the mood list to create widgets
                bool isSelected = _selectedMood == m['label']; // Check if this icon is the selected one
                return GestureDetector( // Make the emoji clickable
                  onTap: () => setState(() => _selectedMood = m['label']!), // Update selection on tap
                  child: Column( // Arrange emoji and label vertically
                    children: [ // Start of mood item children
                      AnimatedContainer( // Container that smooths out visual changes
                        duration: const Duration(milliseconds: 200), // Speed of the transition animation
                        padding: const EdgeInsets.all(12), // Space inside the circle
                        decoration: BoxDecoration( // Circle styling
                          color: isSelected ? AppColors.auroraTeal.withOpacity(0.2) : Colors.white.withOpacity(0.03), // Highlight background if selected
                          shape: BoxShape.circle, // Make it a circle
                          border: Border.all(color: isSelected ? AppColors.auroraTeal : Colors.white10), // Highlight border if selected
                        ), // End of BoxDecoration
                        child: Text(m['emoji']!, style: const TextStyle(fontSize: 24)), // Display the emoji
                      ), // End of AnimatedContainer
                      const SizedBox(height: 8), // Gap between emoji and text
                      Text(m['label']!, // Display mood name (e.g., Happy)
                        style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 10)), // Dim color if not selected
                    ], // End of column children
                  ), // End of Column
                ); // End of GestureDetector
              }).toList(), // Convert the mapped list back to a List of Widgets
            ), // End of Row
            
            const SizedBox(height: 50), // Add gap before button
            
            // STEP C: Execution Button
            SizedBox( // Container to control button size
              width: double.infinity, // Make button take full width
              height: 55, // Set fixed height
              child: ElevatedButton( // Primary action button
                style: ElevatedButton.styleFrom( // Button styling
                  backgroundColor: AppColors.auroraTeal, // Use the teal theme color
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)) // Rounded corners
                ), // End of style
                onPressed: _isSaving ? null : _saveEntry, // Disable button if already saving
                child: _isSaving // Ternary operator: if saving is true...
                  ? const CircularProgressIndicator(color: Colors.white) // Show spinner
                  : const Text("SAVE & FINISH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // Otherwise show text
              ), // End of ElevatedButton
            ), // End of SizedBox
          ], // End of children
        ), // End of Column
      ), // End of SingleChildScrollView
    ); // End of Scaffold
  } // End of Build
} // End of NightfallPage

// =======================================================================
// SECTION 2: TIMELINE PAGE (Data Retrieval Serial)
// =======================================================================
class TimelinePage extends StatelessWidget { // Page that doesn't manage its own internal state
  const TimelinePage({super.key}); // Standard constructor

  @override
  Widget build(BuildContext context) { // UI construction
    final String? userId = FirebaseAuth.instance.currentUser?.uid; // Get logged-in user ID for filtering

    return Scaffold( // Base layout
      backgroundColor: const Color.fromARGB(255, 26, 28, 46), // Deep blue background
      appBar: AppBar( // Top bar
        title: const Text("TIMELINE", // Screen title
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)), // Style title
        backgroundColor: Colors.transparent, // See-through background
        elevation: 0, // No shadow
        centerTitle: true, // Centered title
        leading: IconButton( // Back button
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), // Icon
          onPressed: () => Navigator.pop(context), // Go back logic
        ), // End of IconButton
      ), // End of AppBar
      body: userId == null // Ternary: if user isn't logged in...
          ? const Center(child: Text("Please login", style: TextStyle(color: Colors.white))) // Show message
          : StreamBuilder<QuerySnapshot>( // Listen to live data stream from Firestore
              // 1. Fetching Stream
              stream: FirebaseFirestore.instance // Start Firestore connection
                  .collection('nightly_reflections') // Look in this collection
                  .where('userId', isEqualTo: userId) // Only get data for this specific user
                  .snapshots(), // Get a live stream of updates
              builder: (context, snapshot) { // Build UI based on the latest data 'snapshot'
                if (snapshot.connectionState == ConnectionState.waiting) { // While data is loading...
                  return const Center(child: CircularProgressIndicator()); // Show loading spinner
                } // End of loading check
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // If no data exists...
                  return const Center( // Center the empty state message
                    child: Text("Your journey starts tonight.", style: TextStyle(color: Colors.white38)) // Placeholder text
                  ); // End of Center
                } // End of empty data check

                // 2. Sorting Data (Latest on Top)
                final docs = snapshot.data!.docs.toList() // Convert database documents to a List
                  ..sort((a, b) { // Sort the list in memory
                    Timestamp t1 = a['timestamp'] ?? Timestamp.now(); // Get time of entry A
                    Timestamp t2 = b['timestamp'] ?? Timestamp.now(); // Get time of entry B
                    return t2.compareTo(t1); // Compare them so newest comes first
                  }); // End of sort

                // 3. Rendering List Items
                return ListView.builder( // Build list efficiently (only what's on screen)
                  padding: const EdgeInsets.all(20), // Space around the list
                  itemCount: docs.length, // Total number of entries
                  itemBuilder: (context, index) { // Logic for building each individual card
                    var data = docs[index].data() as Map<String, dynamic>; // Get the document data as a Map
                    DateTime date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(); // Convert Firebase time to Dart time
                    String mood = data['mood'] ?? "Neutral"; // Get the saved mood or default to Neutral
                    
                    String emoji = "😐"; // Default emoji
                    if(mood == "Sad") emoji = "😔"; // Set emoji for Sad
                    if(mood == "Down") emoji = "☁️"; // Set emoji for Down
                    if(mood == "Happy") emoji = "😊"; // Set emoji for Happy
                    if(mood == "Excited") emoji = "🤩"; // Set emoji for Excited

                    return Container( // Wrapper for each card
                      margin: const EdgeInsets.only(bottom: 20), // Gap between cards
                      padding: const EdgeInsets.all(20), // Inner padding for card
                      decoration: BoxDecoration( // Card styling
                        color: Colors.white.withOpacity(0.05), // Translucent card background
                        borderRadius: BorderRadius.circular(20), // Rounded card corners
                        border: Border.all(color: Colors.white.withOpacity(0.05)), // Subtle border line
                      ), // End of BoxDecoration
                      child: Column( // Arrange content inside card vertically
                        crossAxisAlignment: CrossAxisAlignment.start, // Left-align content
                        children: [ // Card children
                          Row( // Arrange date and mood chip horizontally
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Date on left, mood on right
                            children: [ // Start Row children
                              Column( // Date column
                                crossAxisAlignment: CrossAxisAlignment.start, // Left-align text
                                children: [ // Start Date children
                                  Text(DateFormat('EEEE').format(date).toUpperCase(), // Format date to "MONDAY"
                                    style: const TextStyle(color: AppColors.auroraTeal, fontSize: 10, fontWeight: FontWeight.w900)), // Teal style
                                  Text(DateFormat('MMM dd, yyyy').format(date), // Format date to "Jan 01, 2026"
                                    style: const TextStyle(color: Colors.white38, fontSize: 12)), // Dim grey style
                                ], // End of Date children
                              ), // End of Column
                              Container( // The mood chip/badge
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Badge inner space
                                decoration: BoxDecoration( // Badge background
                                  color: Colors.white.withOpacity(0.05), // Faint white
                                  borderRadius: BorderRadius.circular(10), // Rounded badge
                                ), // End of BoxDecoration
                                child: Text("$emoji $mood", // Show emoji and mood text together
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)), // Bold white style
                              ), // End of badge Container
                            ], // End of Row children
                          ), // End of Row
                          const SizedBox(height: 15), // Gap after header
                          const Text("HIGHLIGHT", // Section label inside card
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)), // Orange bold style
                          const SizedBox(height: 6), // Tiny gap
                          Text(data['highlight'] ?? "...", // The actual highlight text from database
                            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)), // White text with extra line height
                        ], // End of card children
                      ), // End of Column
                    ); // End of Container
                  }, // End of ItemBuilder
                ); // End of ListView.builder
              }, // End of StreamBuilder builder
            ), // End of StreamBuilder
    ); // End of Scaffold
  } // End of Build
} // End of TimelinePage