import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/pages/chat_folder/chat_list_page.dart';
import 'package:whats_up/pages/sign_in_folder/register_phone_number.dart';
import 'package:whats_up/services/server_service.dart';
import 'package:whats_up/services/token_provider.dart';

/// The main function that launches the app.
void main() {
  runApp(
    MultiProvider(
      // Provides multiple dependencies to the app.
      providers: [
        ChangeNotifierProvider(
            create: (_) => TokenProvider()
              ..loadToken()), // Provides the TokenProvider, loading the token initially.
        Provider<ServerService>(
            create: (_) => ServerService()), // Provides the ServerService.
      ],
      child: const MyApp(), // The root widget of the app.
    ),
  );
}

/// The root widget of the app.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Manages the state of the MyApp widget.
class _MyAppState extends State<MyApp> {
  /// Future that checks the token status when the app starts.
  late Future<bool> _initialCheck;

  @override
  void initState() {
    super.initState();
    _initialCheck = _checkTokenStatus(); // Check token status on startup.
  }

  /// Checks the validity and expiration status of the access token.
  Future<bool> _checkTokenStatus() async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    await tokenProvider.loadToken(); // Load the token from storage.

    // If no token is found, return false (navigate to login).
    if (tokenProvider.token == null) {
      return false;
    }

    bool isExpired = await tokenProvider.isTokenExpired();
    // If token is expired, attempt to refresh it.
    if (isExpired) {
      try {
        await tokenProvider.refreshAccessToken();
      } catch (e) {
        print('Error refreshing token: $e'); // Log the error.
        return false; // Return false if refresh fails.
      }
    }

    return true; // Token is valid or was successfully refreshed.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The main MaterialApp widget.
      debugShowCheckedModeBanner: false, // Hide the debug banner.
      theme: ThemeData(
        // Defines the app's theme.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Base color for the color scheme.
          primary: Colors.deepPurple,
          secondary: Colors.amber,
          surface: Colors.white,
          background: Colors.grey.shade100,
          error: Colors.redAccent,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              // Style for large display text.
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple),
          titleLarge: TextStyle(
              // Style for large titles.
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
          bodyLarge: TextStyle(
              fontSize: 16, color: Colors.black87), // Style for body text.
          bodyMedium: TextStyle(
              fontSize: 14,
              color: Colors.black54), // Style for smaller body text.
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          // Theme for elevated buttons.
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          // Theme for input decorations.
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        appBarTheme: const AppBarTheme(
          // Theme for app bars.
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true, // Use Material Design 3.
      ),
      themeMode: ThemeMode.system, // Use the system's theme mode.
      home: FutureBuilder<bool>(
        // Builds the initial home screen based on token status.
        future: _initialCheck, // The future that checks the token.
        builder: (context, snapshot) {
          // Builder function for the FutureBuilder.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while checking token.
          } else if (snapshot.hasError) {
            return const RegisterPhoneNumber(); // Navigate to registration if an error occurs.
          } else if (snapshot.data == true) {
            return const ChatListPage(); // Navigate to chat list if the token is valid.
          } else {
            return const RegisterPhoneNumber(); // Navigate to registration if the token is invalid.
          }
        },
      ),
    );
  }
}
