import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whats_up/constants/app_variables.dart';

class ContactService {
  Future<void> sendContactsToServer(
      List<Map<String, dynamic>> friendsList, String? accessToken) async {
    String contactsJson = jsonEncode({'friends': friendsList});
    String baseUrl = AppVariables.baseUrl;
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
}
