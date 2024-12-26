import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:whats_up/constants/app_variables.dart';
import 'package:whats_up/pages/chat_folder/chat_list_page.dart';
import 'package:whats_up/pages/contacts/contact_detail_page.dart';
import 'package:whats_up/pages/contacts/contact_selection_screen.dart';
import 'package:whats_up/services/token_provider.dart';

/// Page displaying the user's contacts and friends.
class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final tokenProvider = Provider.of<TokenProvider>(context);
    final accessToken = tokenProvider.token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts and Friends'),
        actions: [
          // "Add Contact" button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to contact selection screen
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
          // Back button to navigate to ChatListPage
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatListPage(),
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        // Fetch data asynchronously
        future:
            accessToken != null ? fetchContactsAndFriends(accessToken) : null,
        builder: (context, snapshot) {
          // Display loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (accessToken == null) {
            // Handle the case where the user is not logged in
            return const Center(child: Text('Not logged in.'));
          } else if (snapshot.hasError) {
            // Display error message if data fetching fails
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Display message if no contacts or friends are found
            return const Center(child: Text('No contacts or friends found.'));
          }

          // Extract friends and contacts from the fetched data
          final friends = snapshot.data!['friends'] ?? [];
          final contacts = snapshot.data!['contacts'] ?? [];

          // Build the list of contacts and friends
          return ListView(
            children: [
              // Display friends section
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
              // Display contacts section
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
          // Navigate to contact details page
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
