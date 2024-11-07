// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
//
// class NetworkProvider extends ChangeNotifier {
//   bool _isConnected = true;
//
//   bool get isConnected => _isConnected;
//
//   final Connectivity _connectivity = Connectivity();
//
//   NetworkProvider() {
//     _checkInitialConnection();
//     _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
//       _checkConnectionStatus(result);
//     });
//   }
//
//   void _checkInitialConnection() async {
//     ConnectivityResult result = await _connectivity.checkConnectivity();
//     _checkConnectionStatus(result);
//   }
//
//   void _checkConnectionStatus(ConnectivityResult result) async {
//     if (result == ConnectivityResult.none) {
//       _isConnected = false;
//     } else {
//       // Use internet_connection_checker to verify actual internet connection
//       _isConnected = await InternetConnectionCheckerPlus().hasConnection;
//     }
//     notifyListeners();
//   }
// }
