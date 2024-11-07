import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_new_app/provider/cart_provider.dart';
import 'package:ecommerce_new_app/provider/product_provider.dart';
import 'package:ecommerce_new_app/provider/themeprovider.dart';
import 'screens/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC23XYRSQtFcjw0wD6PNywYASegmMvnQQ8",
      appId: "1:668036540532:android:3d29f52d7655e2ad64c921",
      messagingSenderId: "668036540532",
      projectId: "ecommerce-app-bec73",
      storageBucket: "ecommerce-app-bec73.appspot.com",
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Ecommerce App',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const ConnectivityAwareScreen(),
    );
  }
}

// Main screen that checks for connectivity
class ConnectivityAwareScreen extends StatelessWidget {
  const ConnectivityAwareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Ecommerce App'),
      // ),
      body: StreamBuilder<ConnectivityResult>(
        stream: Connectivity().onConnectivityChanged, // Correct stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final connectivityResult = snapshot.data;

            if (connectivityResult == ConnectivityResult.mobile ||
                connectivityResult == ConnectivityResult.wifi) {
              return const SplashScreen(); // Display your main screen if connected
            } else {
              return const NoConnectionScreen(); // Show no connection screen if no internet
            }
          } else {
            // Waiting for the connection status
            return const NoConnectionScreen(); // Show no connection screen if no internet
            // return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// No connection screen
class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('No Internet Connection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.wifi_off, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text('You are offline', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
