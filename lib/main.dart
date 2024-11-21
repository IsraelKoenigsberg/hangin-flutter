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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final tokenProvider = Provider.of<TokenProvider>(context);

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: tokenProvider.token != null
          ? const HomePage()
          : const RegisterPhoneNumber(),
    );
  }
}
