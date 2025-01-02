import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whats_up/constants/app_strings.dart';
import 'package:whats_up/constants/app_variables.dart';
import 'package:whats_up/pages/sign_in_folder/authenticate_phone_number.dart';

/// Registers a user phone number by sending it a One Time Password (OTP) for
/// Two Factor Authentication.
class RegisterPhoneNumber extends StatefulWidget {
  const RegisterPhoneNumber({super.key});

  @override
  State<RegisterPhoneNumber> createState() => _TwoFactorCode();
}

class _TwoFactorCode extends State<RegisterPhoneNumber> {
  /// Controller to capture the phone number input by the user.
  final TextEditingController phoneNumberController = TextEditingController();

  /// Boolean flag to indicate whether the entered number is invalid.
  bool invalidNumber = false;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to handle responsive design.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[70], // Set background color to a light blue.
      body: Padding(
        // Add padding around the main content for consistent spacing.
        padding: EdgeInsets.only(
          top: screenHeight * .05,
          left: screenWidth * .07,
          right: screenWidth * .07,
          bottom: screenHeight * .05,
        ),
        child: Center(
          // Center the content both vertically and horizontally.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Conditionally display an error message if the number is invalid.
              if (invalidNumber) ...[
                const Text(
                  AppStrings
                      .invalidNumberMessage, // Display invalid number message.
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                const SizedBox(height: 12), // Add some spacing below the error.
              ],
              const Text(
                AppStrings
                    .enterNumber, // Display "Enter your phone number" message.
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(
                  height: 16), // Spacing between text and input field.
              // Input field for the phone number, wrapped in a decorated container.
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the input field.
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners.
                  boxShadow: [
                    // Add a shadow effect to the container.
                    BoxShadow(
                      color: Colors.blue.shade100,
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller:
                      phoneNumberController, // Associate with the controller.
                  keyboardType:
                      TextInputType.phone, // Set keyboard type for phone input.
                  decoration: InputDecoration(
                    hintText: AppStrings
                        .enterNumberHint, // Placeholder text for the input field.
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners.
                      borderSide: BorderSide.none, // No border.
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 12.0,
                    ), // Add padding inside the input area.
                    filled: true, // Fill the input field background.
                    fillColor: Colors.white, // White fill color.
                  ),
                ),
              ),
              const SizedBox(height: 24), // Add spacing below the input field.

              // Button to submit the entered phone number.
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await getCode(); // Call the function to get the OTP code.

                  // Navigate to the OTP authentication screen if the number is valid.
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
                  // Customize the button's appearance.
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 24.0,
                  ),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Rounded corners.
                  ),
                  shadowColor: Colors.blue.shade200,
                  elevation: 6,
                ),
                child: const Text(
                  AppStrings.continueString, // "Continue" button text.
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

  /// Sends a request to the server to generate a 2FA code for the phone number.
  Future<void> getCode() async {
    String number = phoneNumberController.text;
    debugPrint("Number is:");
    debugPrint(number); // Print the entered phone number for debugging.
    const baseUrl = AppVariables.baseUrl; // Base URL for the API endpoint.
    final String url =
        '$baseUrl/create?number=$number'; // Construct the full URL.

    try {
      final response = await http.post(
        // Send a POST request to the server.
        Uri.parse(url), // Parse the constructed URL.
        headers: <String, String>{
          'Content-Type': 'application/json', // Set content type to JSON.
        },
      );

      if (response.statusCode == 204) {
        // Check for a successful response (204 No Content).
        debugPrint('2FA request sent successfully!');
        setState(() {
          invalidNumber =
              false; // Set invalidNumber to false if the request is successful.
        });
      } else {
        // Handle error cases if the request fails.
        setState(() {
          invalidNumber =
              true; // Set invalidNumber to true if the request fails.
        });
        debugPrint(
            'Failed to send 2FA request. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint(
          'Error sending 2FA request: $e'); // Catch and print any errors.
      setState(() {
        invalidNumber = true; // Set invalidNumber to true if there's an error.
      });
    }
  }
}
