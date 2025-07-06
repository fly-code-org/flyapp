// login_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fly/core/config/config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  // Google Sign-In setup
final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile','https://www.googleapis.com/auth/calendar.events'],
    clientId: AppConfig.googleClientId // Android client ID
  );
  String _status = "Not signed in";

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        setState(() {
          _status = "Sign-in aborted by user";
        });
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      print("Access Token: ${auth.accessToken}");
      print("ID Token: ${auth.idToken}");

      setState(() {
        _status = "Signed in as ${account.email}";
      });

      // TODO: send auth.accessToken to your backend
      final accessToken = auth.accessToken;

    if (accessToken == null) {
      setState(() {
        _status = "Access token is null";
      });
      return;
    }

    final url = Uri.parse(
      'https://api.flyapp.in/users/external/v1/google-login/?access_token=$accessToken&role=user&current_platform=web',
    );

    final response = await http.get(url);

if (response.statusCode == 200) {
  print("Raw Response: ${response.body}");

  final Map<String, dynamic> jsonResponse = json.decode(response.body);
  final Map<String, dynamic>? data = jsonResponse['data'];

  if (data != null) {
    final jwt = data['jwt_token'];
    final isEmailVerified = data['is_email_verified'];
    final isPhoneVerified = data['is_phone_verified'];

    print("JWT Token: $jwt");
    print("Email Verified: $isEmailVerified");
    print("Phone Verified: $isPhoneVerified");

    setState(() {
      _status = "Signed in successfully";
    });
  } else {
    print("Data field is null in response");
    setState(() {
      _status = "Data field is null";
    });
  }
} else {
  print("Backend Error (${response.statusCode}): ${response.body}");
  setState(() {
    _status = "Backend error: ${response.statusCode}";
  });
}

    } catch (error) {
      print("Sign-In Error: $error");
      setState(() {
        _status = "Sign-in failed: $error";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 27,
                    fontWeight: FontWeight.w400,
                    height: 33.75 / 27,
                    letterSpacing: 0.25,
                    // color: Color(0xFF8545E1),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Can we get your number",
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 23,
                    fontWeight: FontWeight.w400,
                    height: 28.75 / 23,
                    color: Color(0xFF8545E1),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 322,
                  height: 57,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF8545E1)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adjust padding for icon
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 22.5 / 18,
                        letterSpacing: 0.15,
                        color: Color(0xFF8545E1),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your mobile number",
                        hintStyle: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 20.5 / 18,
                          letterSpacing: 0.15,
                          color: Color(0xFF8545E1).withOpacity(0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Color(0xFF8545E1),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "OTP Verification",
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 23,
                    fontWeight: FontWeight.w400,
                    height: 28.75 / 23,
                    color: Color(0xFF8545E1),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "For your security, we require your phone number for quick One Time Password verification for a safe and secure experience.",
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 23,
                    fontWeight: FontWeight.w400,
                    height: 28.75 / 23,
                    color: Color(0xFF8545E1),
                  ),
                ),
                Text(_status),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: Icon(Icons.login),
              label: Text("Sign in with Google"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 176,
              height: 53,
              decoration: BoxDecoration(
                color: Color(0xFF8545E1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextButton(
                onPressed: () {
                  // Add functionality here for OTP request
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                ),
                child: Text(
                  "Get OTP",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
