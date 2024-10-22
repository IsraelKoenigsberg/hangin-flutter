import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SendCode extends StatefulWidget {
  final String phoneNumber;
  const SendCode({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<SendCode> createState() => _TwoFactorCode();
}

class _TwoFactorCode extends State<SendCode> {
  late String phoneNumber;
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
              const Text("Please Enter Your Verification Code"),
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
                  onPressed: () {
                    sendReceivedCode(phoneNumber, codeController.text);
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
    print("Code");
    print(code);
    final String url =
        'http://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/oauth/token?number=$number&code=$code&grant_type=password&client_id=Z3ZCYP_TwEAIuuDrLzBjFKgPU7fZey1ufiBG_QE2Rqc&client_secret=v-3Ad-QhBO-0RMJ-JT2sxYORVgknvKCeEiw_UBhNf7o';
    final response = await http.post(
      Uri.parse(url), // Parse the URL
      headers: <String, String>{
        'Content-Type': 'application/json', // Specify JSON content type
      },
    );
    print("Status code and body");
    print(response.statusCode);
    print(response.body);
  }
}
