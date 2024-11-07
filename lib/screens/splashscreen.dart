import 'dart:async'; // Import to use Timer
import 'package:ecommerce_new_app/screens/main_screens.dart'; // Import your Main Screen
import 'package:ecommerce_new_app/screens/welcomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the initialization process
    _initialize();
  }

  /// Initializes the splash screen by waiting for a duration and then navigating
  Future<void> _initialize() async {
    // Wait for 4 seconds (you can adjust the duration as needed)
    await Future.delayed(const Duration(seconds: 5));

    // Retrieve the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    // Check if the widget is still mounted before navigating
    if (mounted) {
      if (user != null) {
        // User is signed in, check if user data exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Check if the user document exists
        if (userDoc.exists) {
          // User data found, navigate to MainScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // User data not found, navigate to SignInScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      } else {
        // User is not signed in, navigate to SignInScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // Optional: You can set a background color if desired
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/Animation - 1727180490950.json",
              width: size.width * 1, // Adjust the size as needed
              height: size.height * 0.4,
              fit: BoxFit.contain,
            ),
            // Text Label
            const Text(
              'E-Commerce Mobile App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo, // Adjust color as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
