import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whats_up/constants/app_variables.dart';

/// A service class for interacting with the server.
class ServerService {
  /// The base URL for the server.
  String baseUrl = AppVariables.baseUrl;

  /// Sends a list of contacts to the server.
  ///
  /// [friendsList] The list of contacts to send.  Each contact should be a map
  /// with at least a 'number' field.
  /// [accessToken] The user's access token for authentication.
  Future<void> sendContactsToServer(
      List<Map<String, dynamic>> friendsList, String? accessToken) async {
    // Encode the contacts list as a JSON string.
    String contactsJson = jsonEncode({'friends': friendsList});

    // Construct the full URL for the friends endpoint.
    String url = '$baseUrl/friends?access_token=$accessToken';

    try {
      // Send a POST request to the server with the contacts data.
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $accessToken', // Include access token in headers
        },
        body: contactsJson,
      );

      // Check if the request was successful (status code 201).
      if (response.statusCode == 201) {
        print("Contacts uploaded successfully.");
      } else {
        // Print error information if the request fails.
        print("Failed to upload contacts. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      // Handle any errors that occur during the request.
      print("Error sending contacts to server: $e");
    }
  }

  /// Retrieves user information from the server.
  ///
  /// [accessToken] The user's access token.
  Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    // Construct the URL for the user endpoint.
    String url = '$baseUrl/user';

    try {
      // Send a GET request to retrieve user information.
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken', // Include the access token
        },
      );

      // Check for a successful response (status code 200).
      if (response.statusCode == 200) {
        // Decode and return the JSON response.
        return json.decode(response.body);
      } else {
        // Throw an exception if the request fails.
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }

  /// Edits the user's profile information.
  ///
  /// [firstName] The updated first name.
  /// [lastName] The updated last name.
  /// [accessToken] The user's access token.
  Future<void> editUserProfile(
      String firstName, String lastName, String accessToken) async {
    String baseUrl = AppVariables.baseUrl;
    String url = '$baseUrl/user';

    // Create the request body with updated first and last names
    final body = jsonEncode({
      "user": {
        "first_name": firstName,
        "last_name": lastName,
      }
    });

    try {
      // Send a PATCH request to update the user profile.
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body, // Add the request body
      );

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
  ///
  /// [accessToken] The user's access token.
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
