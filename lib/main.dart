import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/pages/chat_folder/chat_list_page.dart';
import 'package:whats_up/pages/sign_in_folder/register_phone_number.dart';
import 'package:whats_up/services/server_service.dart';
import 'package:whats_up/services/token_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TokenProvider()..loadToken()),
        Provider<ServerService>(create: (_) => ServerService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _initialCheck;

  @override
  void initState() {
    super.initState();
    _initialCheck = _checkTokenStatus();
  }

  /// Check token validity and expiration status
  Future<bool> _checkTokenStatus() async {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    await tokenProvider.loadToken();

    if (tokenProvider.token == null) {
      return false;
    }

    bool isExpired = await tokenProvider.isTokenExpired();
    if (isExpired) {
      try {
        await tokenProvider.refreshAccessToken();
      } catch (e) {
        print('Error refreshing token: $e');
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
          secondary: Colors.amber,
          surface: Colors.white,
          background: Colors.grey.shade100,
          error: Colors.redAccent,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),

      themeMode:
          ThemeMode.system, // Automatically switch based on system settings
      home: FutureBuilder<bool>(
        future: _initialCheck,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show a loader while checking
          } else if (snapshot.hasError) {
            return const RegisterPhoneNumber(); // Handle error case
          } else if (snapshot.data == true) {
            return ChatListPage(); // Token valid and not expired
          } else {
            return const RegisterPhoneNumber(); // Token missing or expired
          }
        },
      ),
    );
  }
}
