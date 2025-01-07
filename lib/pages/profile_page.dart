import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/services/profile_and_contacts_service.dart';
import 'package:whats_up/services/token_provider.dart';

/// Widget for displaying and editing user profile information.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

/// State class for managing the profile page.
class _ProfilePageState extends State<ProfilePage> {
  /// Stores the user's information.
  Map<String, dynamic>? _userInfo;

  /// Flag to indicate whether the profile is being edited.
  bool _isEditing = false;

  /// Controller for the first name text field.
  final TextEditingController _firstNameController = TextEditingController();

  /// Controller for the last name text field.
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Load user information when the widget initializes.
  }

  /// Loads user information from the server.
  Future<void> _loadUserInfo() async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      final userInfo = await ProfileAndContactsService().getUserInfo(token);
      setState(() {
        _userInfo = userInfo;
        _firstNameController.text = userInfo['first_name'] ?? '';
        _lastNameController.text = userInfo['last_name'] ?? '';
      });
    } catch (e) {
      print('Error loading user info: $e');
      // Consider showing an error message to the user.
    }
  }

  /// Saves the updated user information to the server.
  Future<void> _saveUserInfo() async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      await ProfileAndContactsService().editUserProfile(
        _firstNameController.text,
        _lastNameController.text,
        token,
      );
      setState(() {
        _userInfo?['first_name'] = _firstNameController.text;
        _userInfo?['last_name'] = _lastNameController.text;
        _isEditing = false; // Exit editing mode after saving.
      });
    } catch (e) {
      print('Error saving user info: $e');
      // Consider showing an error message to the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true, // Center the app bar title.
      ),
      body: _userInfo == null // Display loading indicator while fetching data.
          ? const Center(child: CircularProgressIndicator())
          : Center(
              // Center the content of the page.
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Vertically center the children within the column.
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Horizontally center the children.
                  children: [
                    if (_isEditing) ...[
                      // Display text fields for editing.
                      TextField(
                        controller: _firstNameController,
                        decoration:
                            const InputDecoration(labelText: 'First Name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _lastNameController,
                        decoration:
                            const InputDecoration(labelText: 'Last Name'),
                      ),
                    ] else ...[
                      // Display user information.
                      Text(
                        'First Name: ${_userInfo!['first_name'] ?? ''}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge, // Use titleLarge text style from the theme.
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Last Name: ${_userInfo!['last_name'] ?? ''}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      // Button to toggle edit mode or save changes.
                      onPressed: _isEditing
                          ? _saveUserInfo
                          : () => setState(() => _isEditing = true),
                      child: Text(_isEditing ? 'Save' : 'Edit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _firstNameController
        .dispose(); // Dispose of the controllers to prevent memory leaks.
    _lastNameController.dispose();
    super.dispose();
  }
}
