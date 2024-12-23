import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/services/server_service.dart';
import 'package:whats_up/services/token_provider.dart';

/// Screen for selecting contacts from the user's device and uploading them to the server.
class ContactSelectionScreen extends StatefulWidget {
  /// The next page to navigate to after contact selection.
  /// This depends on from where the user is navigating from.
  final Widget nextPage;

  /// Constructor for the ContactSelectionScreen.
  const ContactSelectionScreen({super.key, required this.nextPage});

  @override
  // ignore: library_private_types_in_public_api
  _ContactSelectionScreenState createState() => _ContactSelectionScreenState();
}

/// State for managing the contact selection screen.
class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  /// List of all contacts fetched from the device.
  List<Contact> contacts = [];

  /// List of selected contacts.
  List<Contact> selectedContacts = [];

  /// Flag to indicate whether all contacts are selected.
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  /// Fetches contacts from the device.
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

  /// Toggles the selection state of a contact.
  void _onContactSelected(Contact contact, bool isSelected) {
    setState(() {
      isSelected
          ? selectedContacts.add(contact)
          : selectedContacts.remove(contact);
    });
  }

  /// Toggles the "select all" state and updates the selected contacts accordingly.
  void _onSelectAllChanged(bool isSelected) {
    setState(() {
      selectAll = isSelected;
      selectedContacts = isSelected ? List.from(contacts) : [];
    });
  }

  /// Sends the selected contacts to the server.
  Future<void> sendSelectedContactsToServer() async {
    // Processes the selected contacts to create a list of maps.
    // Each map contains the first name, last name, and number of a contact.
    List<Map<String, dynamic>> selectedContactsData = selectedContacts
        .map((contact) {
          String displayName = contact.displayName ?? "Unknown";
          List<String> nameParts = displayName.split(" ");
          String firstName = nameParts.isNotEmpty ? nameParts.first : "";
          String lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

          List<String> phones = contact.phones
                  ?.map((phone) => phone.value ?? "")
                  .where((phone) => phone.isNotEmpty)
                  .toList() ??
              [];

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

    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final accessToken = tokenProvider.token;

    await ServerService()
        .sendContactsToServer(selectedContactsData, accessToken);
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
              Navigator.push(
                context,
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
}
