import 'package:flutter/material.dart';
import 'package:fly/features/auth/presentation/pages/register_screen.dart';

class OnboardingSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final double dragPosition;
  final bool showLoginScreen;
  final VoidCallback onBegin;

  const OnboardingSheetContent({
    super.key,
    required this.scrollController,
    required this.dragPosition,
    required this.showLoginScreen,
    required this.onBegin,
  });

@override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          controller: scrollController,
          children: [
            if (!showLoginScreen)
              Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: 326,
                      height: 500,
                      child: AnimatedOpacity(
                        opacity: dragPosition > 0.1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          "Welcome to your safe space to connect, grow, and heal anonymously.",
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            height: 50 / 40,
                            color: Color(0xFF8545E1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: AnimatedOpacity(
                      opacity: dragPosition > 0.1 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: 176,
                        height: 53,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                        decoration: BoxDecoration(
                          color: Color(0xFF8545E1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: TextButton(
                          onPressed: onBegin,
                          style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                          child: Text(
                            "Let's Begin",
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
                  ),
                ],
              )
            else
              RegisterScreen(),
          ],
        ),
      ],
    );
  }
}
