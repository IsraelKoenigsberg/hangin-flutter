import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/services/server_service.dart';
import 'package:whats_up/services/token_provider.dart'; // Import your ServerService

class ContactDetailsPage extends StatelessWidget {
  final Map<String, dynamic> contact;

  const ContactDetailsPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First Name: ${contact['first_name'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Last Name: ${contact['last_name'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Number: ${contact['number'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class EditContactDialog extends StatefulWidget {
  final Map<String, dynamic> contact;

  const EditContactDialog({required this.contact});

  @override
  State<EditContactDialog> createState() => EditContactDialogState();
}

class EditContactDialogState extends State<EditContactDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.contact['first_name']);
    _lastNameController =
        TextEditingController(text: widget.contact['last_name']);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokenProvider = Provider.of<TokenProvider>(context);
    String? accessToken = tokenProvider.token;
    return AlertDialog(
      title: const Text('Edit Contact'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Close the dialog
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
