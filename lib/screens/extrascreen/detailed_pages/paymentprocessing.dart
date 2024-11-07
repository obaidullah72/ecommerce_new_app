import 'dart:async'; // To handle the timer
import 'package:ecommerce_new_app/screens/extrascreen/detailed_pages/ordersuccessscreen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class PaymentProcessing extends StatefulWidget {
  const PaymentProcessing({super.key});

  @override
  State<PaymentProcessing> createState() => _PaymentProcessingState();
}

class _PaymentProcessingState extends State<PaymentProcessing> {
  @override
  void initState() {
    super.initState();

    // Timer to navigate away after 5 seconds
    Timer(const Duration(seconds: 5), () {
      // Add logic here to navigate to the next screen or perform some action
      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderSucessScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center the Lottie animation
        child: Lottie.asset(
          'assets/paymentprocessing.json',
          width: 200, // Adjust size as needed
          height: 200,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
