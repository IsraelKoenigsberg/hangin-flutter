import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class TokenProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _token;

  String? get token => _token;

  // Load token from secure storage
  Future<void> loadToken() async {
    _token = await _storage.read(key: 'access_token');
    notifyListeners(); // Notify widgets to rebuild if token changes
  }

  // Save token to secure storage
  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: 'access_token', value: token);
    notifyListeners();
  }

  // Delete token from secure storage
  Future<void> deleteToken() async {
    _token = null;
    await _storage.delete(key: 'access_token');
    notifyListeners();
  }
}
