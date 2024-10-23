import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whats_up/constants/app_strings.dart';
import 'package:whats_up/pages/sign_in_folder/authenticate_phone_number.dart';

class RegisterPhoneNumber extends StatefulWidget {
  const RegisterPhoneNumber({
    super.key,
  });

  @override
  State<RegisterPhoneNumber> createState() => _TwoFactorCode();
}

class _TwoFactorCode extends State<RegisterPhoneNumber> {
  TextEditingController phoneNumberController = TextEditingController();
  bool invalidNumber = false;
  @override
  Widget build(BuildContext context) {
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
              if (invalidNumber) ...[
                const Text(
                  AppStrings.invalidNumberMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(
                height: 12,
              ),
              const Text(AppStrings.enterNumber),
              const SizedBox(
                height: 12,
              ),
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
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await getCode();
                    if (!invalidNumber) {
                      navigator.push(
                        MaterialPageRoute(
                            builder: (context) => AuthenticatePhoneNumber(
                                  phoneNumber: phoneNumberController.text,
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

  Future<void> getCode() async {
    String number = phoneNumberController.text;
    debugPrint("Number is:");
    debugPrint(number);
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
        debugPrint('2FA request sent successfully!');
        setState(() {
          invalidNumber = false;
        });
      } else {
        // Request failed, handle the error
        setState(() {
          invalidNumber = true;
        });
        debugPrint(
            'Failed to send 2FA request. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      debugPrint('Error sending 2FA request: $e');
      setState(() {
        invalidNumber = true;
      });
    }
  }
}
