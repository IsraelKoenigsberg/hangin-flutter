import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:whats_up/pages/chat_folder/chat_list_page.dart';
import 'package:whats_up/pages/contacts/contact_detail_page.dart';
import 'package:whats_up/pages/sign_in_folder/contact_selection_screen.dart';
import 'package:whats_up/services/token_provider.dart';

class ContactsPage extends StatelessWidget {
  final String apiUrl =
      "https://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/friends";

  const ContactsPage({super.key});

  Future<Map<String, dynamic>> fetchContactsAndFriends(
      String accessToken) async {
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
    final tokenProvider = Provider.of<TokenProvider>(context);
    final accessToken = tokenProvider.token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts and Friends'),
        actions: [
          // Add FAB in AppBar
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactSelectionScreen(
                    nextPage: ContactsPage(),
                  ),
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatListPage(), // Replace with the page you want to navigate to
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: accessToken != null
            ? fetchContactsAndFriends(accessToken)
            : null, // Only call if accessToken is available
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (accessToken == null) {
            // Handle null accessToken case
            return const Center(
                child: Text('Not logged in.')); // Or appropriate message
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contacts or friends found.'));
          }

          final friends = snapshot.data!['friends'] ?? [];
          final contacts = snapshot.data!['contacts'] ?? [];

          return ListView(
            // ... (rest of your ListView builder code remains the same)

            children: [
              // Display friends
              if (friends.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
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

  const ContactCard({super.key, required this.contact, required this.isFriend});

  @override
  Widget build(BuildContext context) {
    final firstName = contact['first_name'] ?? '';
    final lastName = contact['last_name'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
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
