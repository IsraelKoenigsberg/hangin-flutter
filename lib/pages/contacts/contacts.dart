import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/pages/chat_folder/chat_list_page.dart';
import 'package:whats_up/pages/contacts/contact_detail_page.dart';
import 'package:whats_up/pages/sign_in_folder/contact_selection_screen.dart';
import 'package:whats_up/services/server_service.dart';
import 'package:whats_up/services/token_provider.dart';

/// Page displaying the user's contacts and friends.
class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

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
        future: accessToken != null
            ? ServerService().fetchContactsAndFriends(accessToken)
            : null,
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
