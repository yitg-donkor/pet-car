import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/providers/app_state_provider.dart';

void main() {
  group('connectivity helpers', () {
    test('treats non-none single connectivity results as online', () {
      expect(isConnectivityOnline(ConnectivityResult.wifi), isTrue);
      expect(isConnectivityOnline(ConnectivityResult.mobile), isTrue);
      expect(isConnectivityOnline(ConnectivityResult.ethernet), isTrue);
    });

    test('treats list-based results as online/offline correctly', () {
      expect(isConnectivityOnline([ConnectivityResult.wifi]), isTrue);
      expect(isConnectivityOnline([ConnectivityResult.none]), isFalse);
    });

    test('treats no connectivity as offline', () {
      expect(isConnectivityOnline(ConnectivityResult.none), isFalse);
    });
  });
}
