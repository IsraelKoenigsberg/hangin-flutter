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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (invalidNumber) ...[
                Text(
                  AppStrings.invalidNumberMessage,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                AppStrings.enterNumber,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: AppStrings.enterNumberHint,
                ),
              ),
              const SizedBox(height: 24),
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
                child: Text(AppStrings.continueString),
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
    debugPrint(number);
    const baseUrl = AppVariables.baseUrl;
    final String url = '$baseUrl/create?number=$number';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json'},
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
