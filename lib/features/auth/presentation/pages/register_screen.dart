// login_screen.dart
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fly/core/config/config.dart';
import 'package:fly/core/config/fly_google_sign_in.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/storage/onboarding_progress.dart';
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
  late final AuthController _authController;

  final GoogleSignIn _googleSignIn = createFlyAuthGoogleSignIn();
  String _status = "";
  bool _isLogin = false;
  String selectedRole = 'User';
  bool _isGoogleLogin = false;
  bool _passwordFocused = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _authController = sl<AuthController>();
    _passwordFocusNode.addListener(() {
      if (mounted) setState(() => _passwordFocused = _passwordFocusNode.hasFocus);
    });
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
        if (_isGoogleLogin) {
          _handleGoogleAuthSuccess();
          _isGoogleLogin = false;
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
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleAuthSuccess() async {
    if (_authController.message.value.isNotEmpty) {
      // Navigate based on mode
      if (_isLogin) {
        print('✅ [LOGIN] Navigating to home screen...');
        // Returning user: their account is already onboarded.
        await OnboardingProgress.markComplete();
        // Navigate to home screen after login
        Get.offAllNamed(AppRoutes.Home);
        print('✅ [LOGIN] Navigation to home completed');
      } else {
        // Fresh signup: reset any stale progress and gate onboarding from the
        // first post-signup step so a half-registered user can be resumed.
        await OnboardingProgress.saveStep(
          step: AppRoutes.emailVerification,
          role: selectedRole,
          email: emailController.text.trim(),
        );
        // Navigate to email verification after signup
        Get.toNamed(
          AppRoutes.emailVerification,
          arguments: {
            'role': selectedRole,
            'email': emailController.text.trim(),
            'phone_number': '',
          },
        );
      }
    }
  }

  Future<void> _handleGoogleAuthSuccess() async {
    if (_authController.message.value.isNotEmpty) {
      print('✅ Google Auth Successful!');
      print('   📨 Message: ${_authController.message.value}');
      print('   🎫 Token stored: ${_authController.token.value.isNotEmpty}');
      print('   🔐 Is Login Mode: $_isLogin');
      print('   🆕 Is New User: ${_authController.isNewUser.value}');

      // Signup flow: user was on signup form (!_isLogin) OR backend says new user.
      // When on signup form we always treat as signup so we don't depend on backend is_new_user.
      final isSignupFlow = !_isLogin || _authController.isNewUser.value;
      if (isSignupFlow) {
        print('✅ [GOOGLE SIGNUP] Navigating to profile / intro flow...');
        final role = selectedRole.isNotEmpty
            ? selectedRole.toLowerCase()
            : 'user';
        print('   👤 Navigating with role: $role');

        if (role == 'user') {
          print('   🚀 Navigating to: /create-user-profile');
          // Google email is pre-verified, so onboarding resumes at profile creation.
          await OnboardingProgress.saveStep(
            step: AppRoutes.createUserProfile,
            role: role,
          );
          Get.toNamed(AppRoutes.createUserProfile, arguments: {'role': role});
        } else {
          // MHP: route to quiz intro (MHP flow)
          print('   🚀 Navigating to: /intro-quiz (MHP flow)');
          await OnboardingProgress.saveStep(
            step: AppRoutes.IntroScreen,
            role: role,
          );
          Get.toNamed(AppRoutes.IntroScreen, arguments: {'role': role});
        }
      } else {
        // Existing user logging in via Google - navigate to home
        print('✅ [GOOGLE LOGIN] Existing user, navigating to home screen...');
        await OnboardingProgress.markComplete();
        Get.offAllNamed(AppRoutes.Home);
        print('✅ [GOOGLE LOGIN] Navigation to home completed');
      }
    }
  }

  Future<void> _handleSignup() async {
    if (userNameController.text.isEmpty) {
      setState(() => _status = "Please enter a username");
      return;
    }
    if (firstNameController.text.isEmpty) {
      setState(() => _status = "Please enter your first name");
      return;
    }
    if (lastNameController.text.isEmpty) {
      setState(() => _status = "Please enter your last name");
      return;
    }
    if (emailController.text.isEmpty) {
      setState(() => _status = "Please enter your email");
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() => _status = "Please enter a password");
      return;
    }
    if (selectedRole.isEmpty) {
      setState(() => _status = "Please select a role");
      return;
    }

    await _authController.signup(
      userName: userNameController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      password: passwordController.text,
      phoneNumber: '',
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
      final serverAuthCode = account.serverAuthCode?.trim();

      if (accessToken == null) {
        setState(() {
          _status = "Access token is null";
        });
        return;
      }
      if (AppConfig.googleWebClientId.isEmpty) {
        print(
          '⚠️ GOOGLE_OAUTH_CLIENT_ID is empty; serverAuthCode will be null — set it in .env (same as fly-be)',
        );
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
        serverAuthCode: serverAuthCode,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scrollable form content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
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
                        selectedRole = role;
                        _status = '';
                      });
                    },
                  ),

                if (!_isLogin) const SizedBox(height: 20),

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
                  focusNode: _passwordFocusNode,
                ),

                if (!_isLogin && _passwordFocused) ...[
                  const SizedBox(height: 6),
                  const Text(
                    "💪🏻 Keep it strong and safe.",
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                  const Text(
                    "Min 8 letters, add numbers or symbols.",
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],

                if (_status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
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
              ],
            ),
          ),
        ),

        // Sticky footer — always visible
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 53,
                child: DecoratedBox(
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
                      padding: EdgeInsets.zero,
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
                            _isLogin ? "Log in" : "Create account",
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
              const SizedBox(height: 16),
              const OrContinueWith(),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _handleGoogleSignIn,
                child: Container(
                  width: double.infinity,
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
              const SizedBox(height: 12),
              AlreadyMemberText(
                text: _isLogin
                    ? "Not logged in? Signup here"
                    : "Already a fly member? Login here",
                onTap: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _status = '';
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
