import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerService {
  Future<void> sendContactsToServer(
      List<Map<String, dynamic>> friendsList, String? accessToken) async {
    String contactsJson = jsonEncode({'friends': friendsList});
    String url =
        'https://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/friends?access_token=$accessToken';

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

// json object that has 1 field friends with is an array of json obejects - first_name, last_name, and number
// connect to web socket. wss://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/cable?access_token=$accessToken. Needs 
// http://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/