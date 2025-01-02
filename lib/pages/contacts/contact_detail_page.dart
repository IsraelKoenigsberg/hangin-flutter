import 'package:flutter/material.dart';

/// Displays detailed information about a contact.
class ContactDetailsPage extends StatelessWidget {
  /// The contact information to display.  This should be a Map with keys
  /// for 'first_name', 'last_name', and 'number'.
  final Map<String, dynamic> contact;

  /// Creates a ContactDetailsPage.
  ///
  /// The [contact] parameter is required and should contain the contact's details.
  const ContactDetailsPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold provides basic app structure.
      appBar: AppBar(
        // App bar with a title.
        title: const Text('Contact Details'),
      ),
      body: Padding(
        // Add padding around the content.
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Arrange content vertically.
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the start.
          children: [
            Text(
              'First Name: ${contact['first_name'] ?? ''}', // Display first name, or an empty string if null.
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10), // Add vertical spacing.
            Text(
              'Last Name: ${contact['last_name'] ?? ''}', // Display last name, or an empty string if null.
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10), // Add vertical spacing.
            Text(
              'Number: ${contact['number'] ?? ''}', // Display number, or an empty string if null.
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
