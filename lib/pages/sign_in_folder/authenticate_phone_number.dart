import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:whats_up/constants/app_strings.dart';
import 'package:whats_up/constants/app_variables.dart';
import 'package:whats_up/pages/chat_folder/chat_list_page.dart';
import 'package:whats_up/pages/sign_in_folder/contact_selection_screen.dart';
import 'package:whats_up/services/token_provider.dart';

/// Sends the OTP back to Twilio Servers to check if the OTP received is
/// correct.
class AuthenticatePhoneNumber extends StatefulWidget {
  final String phoneNumber;

  const AuthenticatePhoneNumber({
    super.key,
    required this.phoneNumber, // Requires the phone number for OTP authentication
  });

  @override
  State<AuthenticatePhoneNumber> createState() => _TwoFactorCode();
}

class _TwoFactorCode extends State<AuthenticatePhoneNumber> {
  bool invalidOTP = false; // Tracks whether the OTP entered is invalid
  late String phoneNumber; // Phone number passed from the widget

  @override
  void initState() {
    super.initState();
    phoneNumber = widget.phoneNumber; // Initialize the phone number
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController codeController =
        TextEditingController(); // Controller for OTP input field

    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            top: screenHeight * .05,
            left: screenWidth * .07,
            right: screenWidth * .07,
            bottom: screenHeight * .05),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display error message if the OTP is invalid
              if (invalidOTP) ...[
                const Text(
                  AppStrings.invalidOTPMessage,
                  style: TextStyle(color: Colors.red),
                )
              ],
              const SizedBox(
                height: 12,
              ),
              const Text(AppStrings.enterOTP), // Prompt user to enter OTP
              const SizedBox(
                height: 12,
              ),
              // TextField to input OTP
              TextField(
                controller: codeController,
                keyboardType: TextInputType.phone, // Numeric input for OTP
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                ),
              ),
              const SizedBox(
                height: 16,
              ),

              // Button to submit OTP and navigate to HomePage if successful
              ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context); // Store navigator
                    await sendReceivedCode(phoneNumber,
                        codeController.text); // Send OTP for validation
                    if (!invalidOTP) {
                      // If OTP is valid, navigate to Contact Screen
                      navigator.push(
                        MaterialPageRoute(
                            builder: (context) => const ContactSelectionScreen(
                                  nextPage: ChatListPage(),
                                )),
                      );
                    }
                  },
                  child: const Text(
                    AppStrings.continueString,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  // Function to send OTP for validation and handle response
  Future<void> sendReceivedCode(String number, String code) async {
    debugPrint("Code");
    debugPrint(code); // Debugging: print entered OTP code

    // Client credentials for authentication
    const String clientId = 'lRFvRZk-bHaquwnHC4ME0PE9Dha3aNmW84gaFFLAO1c';
    const String clientSecret = "mRzrOqNuMVfrmIvVZEWs6wS-2igjCj587LMgnUBfoyE";
    String baseUrl = AppVariables.baseUrl;
    // Construct the URL for sending OTP with client credentials
    final String url = '$baseUrl/oauth'
        '/token?client_id=$clientId&client_secret=$clientSecret'
        '&grant_type=password&number=$number&code=$code';

    try {
      // Send the OTP for verification
      final response = await http.post(
        Uri.parse(url), // Parse the URL
        headers: <String, String>{
          'Content-Type': 'application/json', // Specify JSON content type
        },
      );

      // Handle successful OTP verification
      if (response.statusCode == 200) {
        // Extract access token from response
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        final expiresIn = data['expires_in'];
        final createdAt = data['created_at'];
        final refreshToken = data['refresh_token'];
        final expirationTime = createdAt + expiresIn;
        print("Created At");
        print(createdAt);
        print("Expiration In");
        print(expiresIn);
        print("Access Token");
        print(accessToken);
        final tokenProvider =
            // ignore: use_build_context_synchronously
            Provider.of<TokenProvider>(context, listen: false);
        tokenProvider.saveToken(
            accessToken, expirationTime, refreshToken, clientId, clientSecret);
        debugPrint("OTP Success!"); // Debugging: OTP verification success
        setState(() {
          invalidOTP = false; // Set invalidOTP flag to false if OTP is valid
        });
        debugPrint("Status code and body");
        print(response.statusCode); // Debugging: print status code
        print(response.body); // Debugging: print response body
      } else {
        // Handle invalid OTP
        setState(() {
          invalidOTP = true; // Set invalidOTP flag to true if OTP is invalid
        });
        debugPrint("Invalid OTP");
        debugPrint("Status code and body");
        print(response.statusCode); // Debugging: print status code
        print(response.body); // Debugging: print response body
      }
    } catch (e) {
      // Catch any errors during the OTP verification process
      debugPrint("OTP error: $e"); // Debugging: print error message
    }
  }
}
