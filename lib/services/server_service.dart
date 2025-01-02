import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whats_up/constants/app_variables.dart';

class ServerService {
  String baseUrl = AppVariables.baseUrl;

  Future<void> sendContactsToServer(
      List<Map<String, dynamic>> friendsList, String? accessToken) async {
    String contactsJson = jsonEncode({'friends': friendsList});
    String url = '$baseUrl/friends?access_token=$accessToken';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: contactsJson,
      );

      if (response.statusCode == 201) {
        print("Contacts uploaded successfully.");
      } else {
        print("Failed to upload contacts. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error sending contacts to server: $e");
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    String url = '$baseUrl/user';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      print("response: ");
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load contacts and friends');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<void> editUserProfile(
      String firstName, String lastName, String accessToken) async {
    String baseUrl = AppVariables.baseUrl;
    String url = '$baseUrl/user';

    final body = jsonEncode({
      "user": {
        "first_name": firstName,
        "last_name": lastName,
      }
    });

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );
      print(response.body);
      if (response.statusCode == 200) {
        print("User profile updated successfully.");
      } else {
        print(
            "Failed to update user profile. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  /// Fetches contacts and friends from the server.
  Future<Map<String, dynamic>> fetchContactsAndFriends(
      String accessToken) async {
    const String baseUrl = AppVariables.baseUrl;
    const String apiUrl = '$baseUrl/friends';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load contacts and friends');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
