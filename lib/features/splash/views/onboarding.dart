import 'package:flutter/material.dart';
import 'package:fly/features/auth/presentation/pages/register_screen.dart';
// Import the new login screen file

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  double dragPosition = 0.0;
  bool showTitle = false;
  bool showSheet = false;
  bool showLoginScreen = false;

  late final DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        showTitle = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          showSheet = true;
        });
        _scheduleSheetOpenAnimation();
      });
    });
  }

  /// After the sheet is in the tree, animate it up so the user does not need
  /// to drag the handle manually.
  void _scheduleSheetOpenAnimation() {
    var attempts = 0;
    void tryAnimate() {
      if (!mounted) return;
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          0.8,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
        );
        return;
      }
      attempts++;
      if (attempts < 40) {
        WidgetsBinding.instance.addPostFrameCallback((_) => tryAnimate());
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => tryAnimate());
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
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
            top: dragPosition > 0.3 ? 50 : MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/fly_logo.png',
                fit: BoxFit.none,
                height: dragPosition > 0.3 ? 100 : 100,
              ),
            ),
          ),
          if (showTitle) 
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: dragPosition < 0.3 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Text(
                    "first love yourself",
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          if (showSheet)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    setState(() {
                      dragPosition = notification.extent;
                    });
                    return true;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Stack(
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
                                  if (!showLoginScreen) 
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
                                            onPressed: () {
                                              setState(() {
                                                showLoginScreen = true; 
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.all(0),
                                            ),
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
                              RegisterScreen(), // Display login screen
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (!showSheet) 
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Created with 🤍 in India",
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

