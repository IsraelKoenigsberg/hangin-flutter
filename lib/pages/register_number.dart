import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:convert'; // For encoding data to JSON
import 'package:http/http.dart' as http;
import 'package:whats_up/pages/send_code.dart';

class RegisterNumber extends StatefulWidget {
  const RegisterNumber({
    super.key,
  });

  @override
  State<RegisterNumber> createState() => _TwoFactorCode();
}

class _TwoFactorCode extends State<RegisterNumber> {
  @override
  Widget build(BuildContext context) {
    TextEditingController phoneNumberController = TextEditingController();
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(
      //   // TRY THIS: Try changing the color here to a specific color (to
      //   // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
      //   // change color while the other colors stay the same.
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text("Register your number"),
      // ),
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
              const Text("Please Enter Your Phone Number"),
              TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
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
              ElevatedButton(
                  onPressed: () {
                    getCode(phoneNumberController);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SendCode(
                                phoneNumber: phoneNumberController.text,
                              )),
                    );
                  },
                  child: const Text(
                    "Continue",
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void getCode(TextEditingController phoneNumberController) async {
    String number = phoneNumberController.text;
    print("Number is:");
    print(number);
    await send2FARequest(number);

// http://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/create?number=
  }

  Future<void> send2FARequest(String number) async {
    // Define the URL
    final String url =
        'http://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/create?number=$number';

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(url), // Parse the URL
        headers: <String, String>{
          'Content-Type': 'application/json', // Specify JSON content type
        },
      );

      // Check if the request was successful
      if (response.statusCode == 204) {
        // Successfully sent the request
        print('2FA request sent successfully!');
      } else {
        // Request failed, handle the error
        print(
            'Failed to send 2FA request. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print('Error sending 2FA request: $e');
    }
  }
}
