import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnection {
  Stream<InternetStatus> get onStatusChange async* {
    final connectivity = Connectivity();
    await for (var result in connectivity.onConnectivityChanged) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        yield InternetStatus.connected;
      } else {
        yield InternetStatus.disconnected;
      }
    }
  }
}

enum InternetStatus { connected, disconnected }
