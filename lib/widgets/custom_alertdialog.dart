import 'package:ecommerce_new_app/screens/welcomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDialogWidget extends StatelessWidget {
  const CustomDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          const CardDialogs(),
          Positioned(
              top: 0,
              right: 0,
              height: 28,
              width: 28,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    shape: const CircleBorder(),
                    backgroundColor: const Color(0xffEC5b5b)),
                child: Image.asset('assets/close.png'),
              ))
        ],
      ),
    );
  }
}

class CardDialogs extends StatelessWidget {
  const CardDialogs({super.key});

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false); // Update the preference
      print('User signed out successfully.');
    } catch (e) {
      print('Error during sign out: $e'); // Handle errors gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(14),
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 32,
      ),
      decoration: BoxDecoration(
        color: Color(0xff2A303E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/warning.png',
            width: 100,
            height: 100,
          ),
          Gap(10),
          Text(
            'Logout',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              color: Color(0xffEC5858),
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(4),
          Text(
            'Are You Sure You Want to Logout?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          Gap(32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 32,
                  ),
                  foregroundColor: Color(0xffEC5858),
                  side: BorderSide(
                    color: Color(0xffEC5858),
                  ),
                ),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _signOut(); // Call the function properly with parentheses.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                    (route) => false, // Removes all previous routes
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xff2A303E),
                  backgroundColor: Color(0xff5BEC84),
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 32,
                  ),
                ),
                child: Text('Yes'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
