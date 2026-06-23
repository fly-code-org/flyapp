import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fly/features/auth/presentation/pages/register_screen.dart';

// ── Tag definition ────────────────────────────────────────────────────────────

class _TagData {
  final String label;
  final Color color;
  final double top;
  final double? left;
  final double? right;

  const _TagData({
    required this.label,
    required this.color,
    required this.top,
    this.left,
    this.right,
  });
}

// Four feature tags overlaid on the welcome text block (326px wide).
// top/left/right are relative to the text Stack's coordinate space.
const _kTags = [
  _TagData(
    label: 'dedicated to selfcare',
    color: Color(0xFF42A5F5),
    top: 30,
    right: -8,
  ),
  _TagData(
    label: 'explore nearby events',
    color: Color(0xFFEC407A),
    top: 80,
    left: -8,
  ),
  _TagData(
    label: 'anonymous chat',
    color: Color(0xFFFF7043),
    top: 130,
    right: -15,
  ),
  _TagData(
    label: 'connect with MHPs',
    color: Color(0xFF66BB6A),
    top: 180,
    left: -8,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> with TickerProviderStateMixin {
  double dragPosition = 0.0;
  bool showTitle = false;
  bool showSheet = false;

  // auth sheet state
  bool _showLoginScreen = false;
  bool _loginMode = false;

  // tag animation state
  bool _tagsSequenceStarted = false;
  bool _showButton = false;
  bool _showLoginLink = false;

  late final DraggableScrollableController _sheetController;
  late final List<AnimationController> _tagControllers;
  late final List<Animation<double>> _tagScales;
  late final List<Animation<double>> _tagRotations;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _initTagAnimations();

    // Existing splash timing: title after 3s, sheet after another 3s
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => showTitle = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => showSheet = true);
        _scheduleSheetOpenAnimation();
      });
    });
  }

  void _initTagAnimations() {
    final rng = math.Random();

    _tagControllers = List.generate(
      _kTags.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      ),
    );

    // Scale: 0→1 with elastic overshoot (first 60% of controller timeline)
    _tagScales = _tagControllers
        .map(
          (ctrl) => Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: ctrl,
              curve: const Interval(0, 0.6, curve: Curves.elasticOut),
            ),
          ),
        )
        .toList();

    // Rotation: 0→random tilt (last 40% of controller timeline)
    // Each tag is guaranteed a 3°–8° tilt; direction is fully random so every
    // app launch looks slightly different ("misfit" effect).
    _tagRotations = List.generate(_kTags.length, (i) {
      final magnitude = rng.nextDouble() * 5 + 3; // 3–8 degrees
      final sign = rng.nextBool() ? 1.0 : -1.0;
      final radians = magnitude * sign * math.pi / 180;
      return Tween<double>(begin: 0, end: radians).animate(
        CurvedAnimation(
          parent: _tagControllers[i],
          curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
        ),
      );
    });
  }

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

  // Tags appear one by one, 600ms apart.
  // Tag i starts at: i * 600 + 200 ms after this method is called.
  // Last tag (i=3) starts at 2000ms, runs 800ms → finishes at 2800ms.
  // Button fades in 300ms after all tags are done → 3100ms.
  // Login link fades in 500ms after button → 3600ms.
  void _startTagSequence() {
    const staggerMs = 600;
    const leadDelayMs = 200;

    for (var i = 0; i < _kTags.length; i++) {
      final delay = leadDelayMs + i * staggerMs;
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _tagControllers[i].forward();
      });
    }

    Future.delayed(const Duration(milliseconds: 3100), () {
      if (mounted) setState(() => _showButton = true);
    });

    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) setState(() => _showLoginLink = true);
    });
  }

  @override
  void dispose() {
    for (final ctrl in _tagControllers) {
      ctrl.dispose();
    }
    _sheetController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: dragPosition > 0.3
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
          if (showTitle)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: dragPosition < 0.3 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Center(
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
                    setState(() => dragPosition = notification.extent);
                    // Start tag sequence exactly once, when sheet is fully open
                    if (!_tagsSequenceStarted &&
                        notification.extent >= 0.75) {
                      _tagsSequenceStarted = true;
                      _startTagSequence();
                    }
                    return true;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: _showLoginScreen
                        ? RegisterScreen(startInLoginMode: _loginMode)
                        : _buildWelcomeContent(scrollController),
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
                child: const Text(
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

  Widget _buildWelcomeContent(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SizedBox(
            width: 326,
            height: 500,
            child: AnimatedOpacity(
              opacity: dragPosition > 0.1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Welcome headline (always visible once sheet is open)
                  const Text(
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

                  // Animated feature tags
                  for (var i = 0; i < _kTags.length; i++)
                    Positioned(
                      top: _kTags[i].top,
                      left: _kTags[i].left,
                      right: _kTags[i].right,
                      child: AnimatedBuilder(
                        animation: _tagControllers[i],
                        builder: (_, __) => Transform.scale(
                          scale: _tagScales[i].value,
                          child: Transform.rotate(
                            angle: _tagRotations[i].value,
                            child: _buildTagPill(
                              _kTags[i].label,
                              _kTags[i].color,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),

        // "Let's begin!" button — fades in after all tags are visible
        Center(
          child: AnimatedOpacity(
            opacity: _showButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: Container(
              width: 176,
              height: 53,
              decoration: BoxDecoration(
                color: const Color(0xFF8545E1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextButton(
                onPressed: _showButton
                    ? () => setState(() {
                          _loginMode = true;
                          _showLoginScreen = true;
                        })
                    : null,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
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
        const SizedBox(height: 16),

        // "Already a part of fly? Login Here" — fades in after button
        AnimatedOpacity(
          opacity: _showLoginLink ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          child: Center(
            child: GestureDetector(
              onTap: _showLoginLink
                  ? () => setState(() {
                        _loginMode = true;
                        _showLoginScreen = true;
                      })
                  : null,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already a part of fly? ',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: 'Login Here',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTagPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
