import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http;
import 'package:whats_up/constants/app_variables.dart';

/// Mamages the access token and gives access to it in all classes.
class TokenProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;

  String? get token => _token;

  /// Load token and expiration time from secure storage
  Future<void> loadToken() async {
    _token = await _storage.read(key: 'access_token');
    notifyListeners();
  }

  /// Retrieve expiration time from secure storage
  Future<int?> getExpirationTime() async {
    final expirationTimeString = await _storage.read(key: 'expiration_time');
    return expirationTimeString != null
        ? int.tryParse(expirationTimeString)
        : null;
  }

  /// Check if the token is expired (based on storage values)
  Future<bool> isTokenExpired() async {
    final expirationTime = await getExpirationTime();
    if (expirationTime == null) return true;

    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return currentTime >= expirationTime;
  }

  /// Save token, expiration time, refresh token, client ID, and client secret to storage
  Future<void> saveToken(String token, int expirationTime, String refreshToken,
      String clientId, String clientSecret) async {
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(
        key: 'expiration_time', value: expirationTime.toString());
    await _storage.write(key: 'client_id', value: clientId);
    await _storage.write(key: 'client_secret', value: clientSecret);
    _token = token; // Update in-memory copy
    notifyListeners();
  }

  /// Retrieve client ID from secure storage
  Future<String?> getClientId() async => await _storage.read(key: 'client_id');

  /// Retrieve client secret from secure storage
  Future<String?> getClientSecret() async =>
      await _storage.read(key: 'client_secret');

  /// Retrieve refresh token from secure storage
  Future<String?> getRefreshToken() async =>
      await _storage.read(key: 'refresh_token');

  /// Delete all stored credentials from secure storage
  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'expiration_time');
    await _storage.delete(key: 'client_id');
    await _storage.delete(key: 'client_secret');
    _token = null;
    notifyListeners();
  }

  /// Refresh the access token using the stored credentials
  Future<void> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    final clientId = await getClientId();
    final clientSecret = await getClientSecret();
    if (refreshToken == null || clientId == null || clientSecret == null) {
      throw Exception("Missing refresh token or client credentials.");
    }
    String baseUrl = AppVariables.baseUrl;
    final uri = Uri.parse('$baseUrl/oauth'
        '/token?client_id=$clientId&client_secret=$clientSecret'
        '&grant_type=refresh_token&refresh_token=$refreshToken');

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(
        data['access_token'],
        data['created_at'] + data['expires_in'],
        data['refresh_token'],
        clientId,
        clientSecret,
      );
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }
}
