import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/services/token_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final tokenProvider =
        Provider.of<TokenProvider>(context); // Access the provider

    // Get screen dimensions to handle responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')), // Added an AppBar
      body: Padding(
        padding: EdgeInsets.only(
            top: screenHeight * .07,
            bottom: screenHeight * .07,
            left: screenWidth * .05,
            right: screenWidth * .05),
        child: const Center(
          child: Text('Welcome to WhatsUp!'), // Placeholder content
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tokenProvider.deleteToken(); // Deletes the token and updates UI
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
