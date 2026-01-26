import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_screen.dart'; // Make sure this matches your filename

void main() async {
  // Ensures Flutter is fully loaded before starting Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Connects your app to your Firebase project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MemoauraApp());
}

class MemoauraApp extends StatelessWidget {
  const MemoauraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memoaura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      
      // THE ROUTES MAP (This is what tells the buttons where to go)
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signin': (context) => const SigninPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}