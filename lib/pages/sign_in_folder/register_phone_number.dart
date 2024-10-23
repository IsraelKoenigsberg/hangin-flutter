import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whats_up/constants/app_strings.dart';
import 'package:whats_up/pages/sign_in_folder/authenticate_phone_number.dart';

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
      body: Padding(
        // Padding for the main content to maintain consistent spacing
        padding: EdgeInsets.only(
            top: screenHeight * .05,
            left: screenWidth * .07,
            right: screenWidth * .07,
            bottom: screenHeight * .05),
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
                  style: TextStyle(color: Colors.red), // Error text in red
                ),
              ],
              const SizedBox(
                height: 12, // Space between error text and input field
              ),
              const Text(AppStrings.enterNumber),
              const SizedBox(
                height: 12, // Space between prompt and phone number input
              ),
              // Input field for the phone number
              TextField(
                controller: phoneNumberController,
                keyboardType:
                    TextInputType.phone, // Ensure number keyboard is used
                decoration: const InputDecoration(
                  border:
                      OutlineInputBorder(), // Outlined border for input field
                  isDense: true, // Compact spacing for text field content
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0), // Padding within the text field
                ),
              ),
              const SizedBox(
                height: 16, // Space between input and button
              ),
              // Button to submit the phone number and trigger code generation
              ElevatedButton(
                  onPressed: () async {
                    final navigator =
                        Navigator.of(context); // Store navigator instance
                    await getCode(); // Call function to send 2FA code

                    // Only navigate to next screen if the number is valid
                    if (!invalidNumber) {
                      navigator.push(
                        MaterialPageRoute(
                            builder: (context) => AuthenticatePhoneNumber(
                                  phoneNumber: phoneNumberController
                                      .text, // Pass the phone number to the next screen
                                )),
                      );
                    }
                  },
                  child: const Text(
                    AppStrings.continueString, // Text for the button
                  ))
            ],
          ),
        ),
      ),
    );
  }

  // Function to send a request to the server to generate a 2FA code for the phone number
  Future<void> getCode() async {
    // Get the phone number from the input field
    String number = phoneNumberController.text;
    debugPrint("Number is:"); // Debugging log to show the number entered
    debugPrint(number); // Print the number to the debug console

    // Define the URL for the API request, including the phone number
    final String url =
        'http://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/create?number=$number';

    try {
      // Send a POST request to the server
      final response = await http.post(
        Uri.parse(url), // Parse the URL for the request
        headers: <String, String>{
          'Content-Type':
              'application/json', // Specify that the content is JSON
        },
      );

      // Check if the request was successful (HTTP status code 204)
      if (response.statusCode == 204) {
        // Log success and update UI state to indicate the number is valid
        debugPrint('2FA request sent successfully!');
        setState(() {
          invalidNumber = false; // Reset the invalid flag on success
        });
      } else {
        // Handle case where the server returns an error response
        setState(() {
          invalidNumber = true; // Set the invalid flag to true
        });
        debugPrint(
            'Failed to send 2FA request. Status code: ${response.statusCode}'); // Log the error
        debugPrint('Response body: ${response.body}'); // Log the response body
      }
    } catch (e) {
      // Handle any exceptions (e.g., network errors)
      debugPrint('Error sending 2FA request: $e'); // Log the exception
      setState(() {
        invalidNumber = true; // Set the invalid flag to true on error
      });
    }
  }
}
