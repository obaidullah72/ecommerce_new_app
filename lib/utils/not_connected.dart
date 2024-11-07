import 'package:flutter/material.dart';

class NoNetworkScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoNetworkScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.signal_cellular_connected_no_internet_4_bar,
              size: size.height * 0.15,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'You are not connected to a network',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
