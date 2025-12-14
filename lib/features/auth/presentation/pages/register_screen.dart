// login_screen.dart
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fly/core/config/config.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/auth/presentation/controllers/auth_controller.dart';
import 'package:fly/features/auth/presentation/widgets/already_member_text.dart';
import 'package:fly/features/auth/presentation/widgets/input_text_field.dart';
import 'package:fly/features/auth/presentation/widgets/or_continue_with.dart';
import 'package:fly/features/auth/presentation/widgets/role_selector.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Get AuthController from dependency injection
  late final AuthController _authController;

  // Google Sign-In setup
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar.events',
    ],
    clientId: AppConfig.googleClientId, // Android client ID
  );
  String _status = "";
  bool _isLogin = false;
  String selectedRole = '';
  bool _isGoogleLogin = false;

  // Controllers for form fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authController = sl<AuthController>();
    // Listen to auth controller changes
    ever(_authController.isLoading, (isLoading) {
      if (mounted) setState(() {});
    });
    ever(_authController.errorMessage, (error) {
      if (mounted && error.isNotEmpty) {
        setState(() {
          _status = error;
        });
      }
    });
    ever(_authController.message, (message) {
      if (mounted && message.isNotEmpty) {
        setState(() {
          _status = message;
        });
        // Navigate on success
        if (_isGoogleLogin) {
          _handleGoogleAuthSuccess();
          _isGoogleLogin = false; // Reset flag
        } else {
          _handleAuthSuccess();
        }
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthSuccess() async {
    if (_authController.message.value.isNotEmpty) {
      // Navigate based on mode
      if (_isLogin) {
        print('✅ [LOGIN] Navigating to home screen...');
        // Navigate to home screen after login
        Get.offAllNamed(AppRoutes.Home);
        print('✅ [LOGIN] Navigation to home completed');
      } else {
        // Navigate to email verification after signup
        Get.toNamed(
          AppRoutes.emailVerification,
          arguments: {
            'role': selectedRole,
            'email': emailController.text.trim(),
          },
        );
      }
    }
  }

  Future<void> _handleGoogleAuthSuccess() async {
    if (_authController.message.value.isNotEmpty) {
      print('✅ Google Signup Successful!');
      print('   📨 Message: ${_authController.message.value}');
      print('   🎫 Token stored: ${_authController.token.value.isNotEmpty}');

      // Navigate to profile creation screen based on role
      // Convert to lowercase for comparison (RoleSelector returns "User" or "MHP")
      final role = selectedRole.isNotEmpty
          ? selectedRole.toLowerCase()
          : 'user';
      print('   👤 Navigating with role: $role');

      if (role == 'user') {
        print('   🚀 Navigating to: /create-user-profile');
        Get.toNamed('/create-user-profile', arguments: {'role': role});
      } else {
        print('   🚀 Navigating to: /create-mhp-profile');
        Get.toNamed('/create-mhp-profile', arguments: {'role': role});
      }
    }
  }

  Future<void> _handleSignup() async {
    // Validate required fields
    if (userNameController.text.isEmpty) {
      setState(() {
        _status = "Please enter a username";
      });
      return;
    }
    if (firstNameController.text.isEmpty) {
      setState(() {
        _status = "Please enter your first name";
      });
      return;
    }
    if (lastNameController.text.isEmpty) {
      setState(() {
        _status = "Please enter your last name";
      });
      return;
    }
    if (phoneNumberController.text.isEmpty) {
      setState(() {
        _status = "Please enter your phone number";
      });
      return;
    }
    if (emailController.text.isEmpty) {
      setState(() {
        _status = "Please enter your email";
      });
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        _status = "Please enter a password";
      });
      return;
    }
    if (selectedRole.isEmpty) {
      setState(() {
        _status = "Please select a role";
      });
      return;
    }

    await _authController.signup(
      userName: userNameController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      password: passwordController.text,
      phoneNumber: phoneNumberController.text.trim(),
      email: emailController.text.trim(),
      role: selectedRole,
    );
  }

  Future<void> _handleLogin() async {
    // Validate required fields
    if (emailController.text.isEmpty) {
      setState(() {
        _status = "Please enter your email";
      });
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        _status = "Please enter your password";
      });
      return;
    }

    print('🔐 Starting login process...');
    print('📧 Email: ${emailController.text.trim()}');

    await _authController.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    // Debug: Check token after login attempt
    if (_authController.message.value.isNotEmpty) {
      print('✅ Login successful!');
      print('🎫 Token stored: ${_authController.token.value.isNotEmpty}');
      final storedToken = await _authController.getStoredToken();
      print(
        '💾 Token in storage: ${storedToken != null && storedToken.isNotEmpty}',
      );
      if (storedToken != null) {
        print(
          '🔑 Token preview: ${storedToken.substring(0, storedToken.length > 20 ? 20 : storedToken.length)}...',
        );
      }
    } else if (_authController.errorMessage.value.isNotEmpty) {
      print('❌ Login failed: ${_authController.errorMessage.value}');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      // Validate role selection for signup
      if (!_isLogin && selectedRole.isEmpty) {
        setState(() {
          _status = "Please select a role first";
        });
        return;
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        setState(() {
          _status = "Sign-in aborted by user";
        });
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      print("🔐 Google Sign-In Account: ${account.email}");
      print("🎫 Access Token received: ${auth.accessToken != null}");

      final accessToken = auth.accessToken;

      if (accessToken == null) {
        setState(() {
          _status = "Access token is null";
        });
        return;
      }

      // Determine current platform
      String currentPlatform = 'web';
      if (kIsWeb) {
        currentPlatform = 'web';
      } else if (Platform.isIOS) {
        currentPlatform = 'ios';
      } else if (Platform.isAndroid) {
        currentPlatform = 'android';
      }

      // Use selected role or default to 'user', convert to lowercase for API
      final role = selectedRole.isNotEmpty
          ? selectedRole.toLowerCase()
          : 'user';

      print('🚀 Starting Google login');
      print('   📧 Email: ${account.email}');
      print('   👤 Selected Role: $selectedRole');
      print('   🔄 Converted Role: $role');
      print('   📱 Platform: $currentPlatform');
      print(
        '   🎫 Access Token: ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...',
      );

      // Set flag to indicate this is a Google login
      _isGoogleLogin = true;

      // Call the controller's googleLogin method
      await _authController.googleLogin(
        accessToken: accessToken,
        role: role,
        currentPlatform: currentPlatform,
      );

      // Navigation will be handled by the ever listener for message
    } catch (error) {
      print("❌ Google Sign-In Error: $error");
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
                          selectedRole = role; // ✅ Important line
                          _status = "$role selected";
                        });
                      },
                    ),

                  if (!_isLogin) const SizedBox(height: 30),

                  // Signup specific fields
                  if (!_isLogin)
                    InputTextField(
                      label: "Username",
                      icon: Icons.person_outline,
                      inputType: TextInputType.text,
                      controller: userNameController,
                    ),
                  if (!_isLogin)
                    InputTextField(
                      label: "First Name",
                      icon: Icons.person_outline,
                      inputType: TextInputType.name,
                      controller: firstNameController,
                    ),
                  if (!_isLogin)
                    InputTextField(
                      label: "Last Name",
                      icon: Icons.person_outline,
                      inputType: TextInputType.name,
                      controller: lastNameController,
                    ),
                  if (!_isLogin)
                    InputTextField(
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      inputType: TextInputType.phone,
                      controller: phoneNumberController,
                    ),

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

                  // Show status/error message
                  if (_status.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _status,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: _authController.errorMessage.value.isNotEmpty
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  Center(
                    child: Container(
                      width: 377,
                      height: 53,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          center: Alignment.center,
                          radius: 3.0,
                          colors: [Color(0xFFC36AFD), Color(0xFF7A5AF8)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: TextButton(
                        onPressed: _authController.isLoading.value
                            ? null
                            : () {
                                if (_isLogin) {
                                  _handleLogin();
                                } else {
                                  _handleSignup();
                                }
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _authController.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
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
