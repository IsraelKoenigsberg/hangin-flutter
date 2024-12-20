import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContactsPage extends StatelessWidget {
  final String apiUrl = "base_url/friends"; // Replace with actual base URL
  final String accessToken =
      "insert_access_token_here"; // Replace with your access token

  Future<Map<String, dynamic>> fetchContactsAndFriends() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts and Friends'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchContactsAndFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts or friends found.'));
          }

          final friends = snapshot.data!['friends'] ?? [];
          final contacts = snapshot.data!['contacts'] ?? [];

          return ListView(
            children: [
              // Display friends
              if (friends.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Friends',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...friends
                    .map<Widget>((friend) =>
                        ContactCard(contact: friend, isFriend: true))
                    .toList(),
              ],
              // Display contacts
              if (contacts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Contacts',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...contacts
                    .map<Widget>((contact) =>
                        ContactCard(contact: contact, isFriend: false))
                    .toList(),
              ],
            ],
          );
        },
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final Map<String, dynamic> contact;
  final bool isFriend;

  const ContactCard({required this.contact, required this.isFriend});

  @override
  Widget build(BuildContext context) {
    final firstName = contact['first_name'] ?? '';
    final lastName = contact['last_name'] ?? '';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      child: ListTile(
        title: Text('$firstName $lastName'),
        subtitle: Text(isFriend ? 'Friend' : 'Contact'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactDetailsPage(contact: contact),
            ),
          );
        },
      ),
    );
  }
}

class ContactDetailsPage extends StatelessWidget {
  final Map<String, dynamic> contact;

  const ContactDetailsPage({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First Name: ${contact['first_name'] ?? ''}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Last Name: ${contact['last_name'] ?? ''}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Number: ${contact['number'] ?? ''}',
              style: TextStyle(fontSize: 16),
            ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
