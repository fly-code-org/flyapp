import 'package:flutter/material.dart';
import 'package:fly/features/start_quiz/widgets/gradient_button.dart';
import 'package:get/get.dart';

class GetInterestScreen extends StatefulWidget {
  const GetInterestScreen({super.key});

  @override
  State<GetInterestScreen> createState() => _GetInterestScreenState();
}

class _GetInterestScreenState extends State<GetInterestScreen> {
  double _dragPosition = 0.8;
  late final String role;

  // Track which button text to show
  bool _showSureLetsGo = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    role = (args['role'] ?? 'user').toLowerCase();
    print("PhoneVerification role: $role");
  }

  void _handleButtonPressed() {
    if (_showSureLetsGo) {
      // Navigate with "Sure, let's go"
      Get.toNamed('/intro-quiz', arguments: {'text': "Sure, let's go"});
      setState(() {
        _showSureLetsGo = false; // Switch text on next render
      });
    } else {
      // Navigate with "Next >>>>"
      Get.toNamed('/intro-quiz', arguments: {'text': "Next >>>>"});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_fly.png',
              fit: BoxFit.cover,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _dragPosition > 0.3
                ? 50
                : MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/fly_logo.png',
                fit: BoxFit.none,
                height: 100,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  setState(() {
                    _dragPosition = notification.extent;
                  });
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                       const Text(
                        "Which tags would you like to follow?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 27,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
