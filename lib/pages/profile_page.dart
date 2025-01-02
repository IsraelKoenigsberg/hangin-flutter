import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/services/server_service.dart';
import 'package:whats_up/services/token_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userInfo;
  bool _isEditing = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      final userInfo = await ServerService().getUserInfo(token);
      setState(() {
        _userInfo = userInfo;
        _firstNameController.text = userInfo['first_name'] ?? '';
        _lastNameController.text = userInfo['last_name'] ?? '';
      });
    } catch (e) {
      print('Error loading user info: $e');
      // Optionally show an error message
    }
  }

  Future<void> _saveUserInfo() async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      await ServerService().editUserProfile(
        _firstNameController.text,
        _lastNameController.text,
        token,
      );
      setState(() {
        _userInfo?['first_name'] = _firstNameController.text;
        _userInfo?['last_name'] = _lastNameController.text;
        _isEditing = false;
      });
    } catch (e) {
      print('Error saving user info: $e');
      // Optionally show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _userInfo == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing) ...[
                    TextField(
                      controller: _firstNameController,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                  ] else ...[
                    Text('First Name: ${_userInfo!['first_name'] ?? ''}'),
                    const SizedBox(height: 10),
                    Text('Last Name: ${_userInfo!['last_name'] ?? ''}'),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isEditing
                        ? _saveUserInfo
                        : () => setState(() => _isEditing = true),
                    child: Text(_isEditing ? 'Save' : 'Edit'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
