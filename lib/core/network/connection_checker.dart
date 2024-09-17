import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  final InternetConnection connectionChecker;
  const ConnectionCheckerImpl({required this.connectionChecker});

  @override
  Future<bool> get isConnected async =>
      await connectionChecker.hasInternetAccess;
}
