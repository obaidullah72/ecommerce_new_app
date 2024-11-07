import 'package:ecommerce_new_app/screens/main_screens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OrderSucessScreen extends StatefulWidget {
  const OrderSucessScreen({super.key});

  @override
  State<OrderSucessScreen> createState() => _OrderSucessScreenState();
}

class _OrderSucessScreenState extends State<OrderSucessScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/paymentdone.json',
            width: 200, // Adjust size as needed
            height: 200,
            fit: BoxFit.fill,
          ),
          Text(
            'Success!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: size.width * 0.075,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'Your Order will be delievered is soon!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              fontSize: size.width * 0.05,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'Thank you for choosing our App',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black45,
              fontSize: size.width * 0.04,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MainScreen()));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Thank you very much for your trust!!")));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Continue Shopping",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
