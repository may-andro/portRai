import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/connectivity/domain/repository/_repository.dart';

@Register(as: ConnectivityRepository)
class ConnectivityPlusRepositoryImpl implements ConnectivityRepository {
  ConnectivityPlusRepositoryImpl() : _connectivity = Connectivity();

  /// Used before the service locator is ready (app start-up).
  ConnectivityPlusRepositoryImpl.standalone() : _connectivity = Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    final hasInternet = await _hasInternet(results);
    return hasInternet;
  }

  @override
  Stream<bool> watchConnection() {
    return _connectivity.onConnectivityChanged
        .asyncMap(_hasInternet)
        .distinct();
  }

  Future<bool> _hasInternet(List<ConnectivityResult> results) async {
    if (results.every((result) => result == ConnectivityResult.none)) {
      return false;
    }
    if (kIsWeb) return true;

    // An active network interface does not guarantee internet access
    // (e.g. Wi-Fi without uplink), so confirm with a DNS lookup.
    try {
      final addresses = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }
}
