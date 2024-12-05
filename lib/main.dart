import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/pages/home_page.dart';
import 'package:whats_up/pages/sign_in_folder/register_phone_number.dart';
import 'package:whats_up/services/token_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TokenProvider()..loadToken()),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
            return const HomePage(); // Token valid and not expired
          } else {
            return const RegisterPhoneNumber(); // Token missing or expired
          }
        },
      ),
    );
  }
}
