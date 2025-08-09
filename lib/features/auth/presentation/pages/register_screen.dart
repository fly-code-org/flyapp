// login_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fly/core/config/config.dart';
import 'package:fly/features/auth/presentation/widgets/already_member_text.dart';
import 'package:fly/features/auth/presentation/widgets/input_text_field.dart';
import 'package:fly/features/auth/presentation/widgets/or_continue_with.dart';
import 'package:fly/features/auth/presentation/widgets/role_selector.dart';
import 'package:fly/features/profile_creation/presentation/views/user_profile_form.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  
  // Google Sign-In setup
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile','https://www.googleapis.com/auth/calendar.events'],
      clientId: AppConfig.googleClientId // Android client ID
    );
  String _status = "";
  bool _isLogin = false;
  String selectedRole = '';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      _isLogin ? "Log In" : "Create your account",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        height: 33.75 / 27,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!_isLogin)
                    RoleSelector(
                    onRoleSelected: (role) {
                      setState(() {
                        selectedRole = role;  // ✅ Important line
                        _status = "$role selected";
                      });
                    },
                  ),

                  if (!_isLogin) const SizedBox(height: 30),

                  InputTextField(
                    label: "Enter your Email",
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                    controller: emailController,
                  ),
                  InputTextField(
                    label: "Enter your password",
                    icon: Icons.lock_outline,
                    inputType: TextInputType.visiblePassword,
                    obscureText: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 5),

                  if (!_isLogin)
                    const Text(
                      "💪🏻 Keep it strong and safe.",
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 28.75 / 23,
                        color: Colors.red,
                      ),
                    ),

                  if (!_isLogin)
                    const Text(
                      "Min 8 letters, add numbers or symbols.",
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 28.75 / 23,
                        color: Colors.black,
                      ),
                    ),

                  if (!_isLogin) Text(_status),

                  const SizedBox(height: 20),

                  Center(
                    child: Container(
                      width: 377,
                      height: 53,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          center: Alignment.center,
                          radius: 3.0,
                          colors: [
                            Color(0xFFC36AFD),
                            Color(0xFF7A5AF8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (selectedRole.isEmpty && !_isLogin) {
                            setState(() {
                              _status = "Please select a role first";
                            });
                            return;
                          }

                          Get.toNamed('/email-verification', arguments: {
                            'role': selectedRole,
                          });

                          // TODO: Add login/register logic here
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          _isLogin ? "Log in" : "Continue",
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lexend',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const OrContinueWith(),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: _handleGoogleSignIn,
                    child: Container(
                      width: 377,
                      height: 53,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icon/google.png',
                            height: 22,
                            width: 22,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Google',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            AlreadyMemberText(
              text: _isLogin
                  ? "Not logged in? Signup here"
                  : "Already a fly member? Login here",
              onTap: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
            ),

          ],
        ),
      ),
    );
  }
}