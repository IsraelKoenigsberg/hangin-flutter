import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/pages/chat_folder/chat_list_page.dart';
import 'package:whats_up/pages/home_page.dart';
import 'package:whats_up/services/server_service.dart';
import 'package:whats_up/services/token_provider.dart';

class ContactSelectionScreen extends StatefulWidget {
  final Widget  nextPage;

  const ContactSelectionScreen({super.key, required this.nextPage});

  @override
  _ContactSelectionScreenState createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  List<Contact> contacts = [];
  List<Contact> selectedContacts = [];
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  // Fetch contacts and set the state
  Future<void> _fetchContacts() async {
    try {
      Iterable<Contact> contactsIterable =
          await ContactsService.getContacts(withThumbnails: false);
      setState(() {
        contacts = contactsIterable.toList();
      });
    } catch (e) {
      print("Error fetching contacts: $e");
    }
  }

  // Toggle contact selection
  void _onContactSelected(Contact contact, bool isSelected) {
    setState(() {
      isSelected
          ? selectedContacts.add(contact)
          : selectedContacts.remove(contact);
    });
  }

  // Toggle select all contacts
  void _onSelectAllChanged(bool isSelected) {
    setState(() {
      selectAll = isSelected;
      selectedContacts = isSelected ? List.from(contacts) : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Contacts"),
        actions: [
          Row(
            children: [
              Checkbox(
                value: selectAll,
                onChanged: (bool? value) {
                  _onSelectAllChanged(value ?? false);
                },
              ),
              const Text("Select All", style: TextStyle(color: Colors.blue)),
            ],
          ),
          TextButton(
            onPressed: () {
              sendSelectedContactsToServer();
              final navigator = Navigator.of(context); // Store navigator
              navigator.push(
                MaterialPageRoute(builder: (context) => widget.nextPage),
              );
            },
            child: const Text("Upload", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: contacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                bool isSelected = selectedContacts.contains(contact);
                return ListTile(
                  title: Text(contact.displayName ?? "Unknown"),
                  subtitle: Text(contact.phones?.isNotEmpty == true
                      ? contact.phones!.first.value ?? ""
                      : ""),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      _onContactSelected(contact, value ?? false);
                      setState(() {
                        selectAll = selectedContacts.length == contacts.length;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  // Send selected contacts to the server
  Future<void> sendSelectedContactsToServer() async {
    List<Map<String, dynamic>> selectedContactsData = selectedContacts
        .map((contact) {
          // Split the display name into first and last name
          String displayName = contact.displayName ?? "Unknown";
          List<String> nameParts = displayName.split(" ");
          String firstName = nameParts.isNotEmpty ? nameParts.first : "";
          String lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
          print("First Name: $firstName, Last Name: $lastName");
          // Collect the phone numbers
          List<String> phones = contact.phones
                  ?.map((phone) => phone.value ?? "")
                  .where((phone) => phone.isNotEmpty)
                  .toList() ??
              [];

          // Create an object for each phone number
          return phones.map((phone) {
            return {
              'first_name': firstName,
              'last_name': lastName,
              'number': phone,
            };
          }).toList();
        })
        .expand((contactList) => contactList)
        .toList();

    if (selectedContactsData.isEmpty) {
      print("No contacts selected.");
      return;
    }
    print(selectedContactsData.toString());
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final accessToken = tokenProvider.token;

    // Call the function to upload this list to the server
    await ServerService()
        .sendContactsToServer(selectedContactsData, accessToken);
  }
}
