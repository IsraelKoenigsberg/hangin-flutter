import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whats_up/constants/app_strings.dart';
import 'package:whats_up/pages/chat_folder/chat_list_page.dart';
import 'package:whats_up/pages/sign_in_folder/authenticate_phone_number.dart';
import 'package:whats_up/pages/sign_in_folder/contact_selection_screen.dart';

/// Registers a user phone number by sending it a One Time Password (OTP) for
/// Two Factor Authentication.
class RegisterPhoneNumber extends StatefulWidget {
  const RegisterPhoneNumber({
    super.key,
  });

  @override
  State<RegisterPhoneNumber> createState() => _TwoFactorCode();
}

class _TwoFactorCode extends State<RegisterPhoneNumber> {
  // Controller to capture the phone number input by the user
  TextEditingController phoneNumberController = TextEditingController();

  // Boolean flag to indicate whether the entered number is invalid
  bool invalidNumber = false;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to handle responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[70], // Light blue background color
      body: Padding(
        // Padding for the main content to maintain consistent spacing
        padding: EdgeInsets.only(
          top: screenHeight * .05,
          left: screenWidth * .07,
          right: screenWidth * .07,
          bottom: screenHeight * .05,
        ),
        child: Center(
          // Main layout: a column aligned centrally both vertically and horizontally
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display an error message if the phone number is invalid
              if (invalidNumber) ...[
                const Text(
                  AppStrings.invalidNumberMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                AppStrings.enterNumber,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 16),
              // Input field for the phone number
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter phone number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 12.0,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () {
                    final navigator = Navigator.of(context); // Store navigator
                    navigator.push(
                      MaterialPageRoute(
                          builder: (context) => ContactSelectionScreen(nextPage: ChatListPage(),)),
                    );
                  },
                  child: Text("Contact Upload Test")),
              // Button to submit the phone number and trigger code generation
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await getCode();

                  if (!invalidNumber) {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (context) => AuthenticatePhoneNumber(
                          phoneNumber: phoneNumberController.text,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 24.0,
                  ),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  shadowColor: Colors.blue.shade200,
                  elevation: 6,
                ),
                child: const Text(
                  AppStrings.continueString,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to send a request to the server to generate a 2FA code for the phone number
  Future<void> getCode() async {
    String number = phoneNumberController.text;
    debugPrint("Number is:");
    debugPrint(number);

    final String url =
        'https://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/create?number=$number';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        debugPrint('2FA request sent successfully!');
        setState(() {
          invalidNumber = false;
        });
      } else {
        setState(() {
          invalidNumber = true;
        });
        debugPrint(
            'Failed to send 2FA request. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending 2FA request: $e');
      setState(() {
        invalidNumber = true;
      });
    }
  }
}
