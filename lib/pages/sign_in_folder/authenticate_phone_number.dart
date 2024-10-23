import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whats_up/constants/app_strings.dart';

class AuthenticatePhoneNumber extends StatefulWidget {
  final String phoneNumber;
  const AuthenticatePhoneNumber({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<AuthenticatePhoneNumber> createState() => _TwoFactorCode();
}

class _TwoFactorCode extends State<AuthenticatePhoneNumber> {
  bool invalidOTP = false;
  late String phoneNumber;
  @override
  void initState() {
    super.initState();
    phoneNumber = widget.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();
    // Get screen dimensions
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
              if (invalidOTP) ...[
                const Text(
                  AppStrings.invalidOTPMessage,
                  style: TextStyle(color: Colors.red),
                )
              ],
              const SizedBox(
                height: 12,
              ),
              const Text(AppStrings.enterOTP),
              const SizedBox(
                height: 12,
              ),
              TextField(
                controller: codeController,
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
                    await sendReceivedCode(phoneNumber, codeController.text);
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

  Future<void> sendReceivedCode(String number, String code) async {
    debugPrint("Code");
    debugPrint(code);
    const String clientId = 'lRFvRZk-bHaquwnHC4ME0PE9Dha3aNmW84gaFFLAO1c';
    const String clientSecret = "mRzrOqNuMVfrmIvVZEWs6wS-2igjCj587LMgnUBfoyE";
    final String url =
        'http://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/oauth'
        '/token?client_id=$clientId&client_secret=$clientSecret'
        '&grant_type=password&number=$number&code=$code';
    try {
      final response = await http.post(
        Uri.parse(url), // Parse the URL
        headers: <String, String>{
          'Content-Type': 'application/json', // Specify JSON content type
        },
      );
      if (response.statusCode == 200) {
        debugPrint("OTP Success!");
        setState(() {
          invalidOTP = false;
        });
        debugPrint("Status code and body");
        print(response.statusCode);
        print(response.body);
      } else {
        setState(() {
          invalidOTP = true;
        });
        debugPrint("Invalid OTP");
        debugPrint("Status code and body");
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      debugPrint("OTP error: $e");
    }
  }
}
