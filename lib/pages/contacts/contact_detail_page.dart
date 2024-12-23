import 'package:flutter/material.dart';

class ContactDetailsPage extends StatelessWidget {
  final Map<String, dynamic> contact;

  const ContactDetailsPage({super.key, required this.contact});

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
