import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:get/get.dart';
import 'package:app_links/app_links.dart';

import 'core/di/service_locator.dart' as di;
import 'core/network/api_client.dart';
import 'firebase_options.dart'; // Generated from flutterfire configure
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  // Set up error handling to catch SVG parsing errors (must be before any widget code)
  FlutterError.onError = (FlutterErrorDetails details) {
    // Check if this is an SVG parsing error
    final exceptionString = details.exception.toString();
    if (exceptionString.contains('unhandled element') ||
        exceptionString.contains('Svg loader') ||
        exceptionString.contains('Picture key') ||
        exceptionString.contains('<Error/>')) {
      // Log the SVG error but don't crash the app
      debugPrint(
        '⚠️ [MAIN] SVG parsing error (suppressed): ${details.exception}',
      );
      // Don't present the error or throw - just suppress it
      return;
    }
    // For other errors, use Flutter's default error handler
    FlutterError.presentError(details);
  };

  try {
    print('🚀 [MAIN] Starting app initialization...');

    // ✅ Always initialize bindings first for async setup
    WidgetsFlutterBinding.ensureInitialized();
    print('✅ [MAIN] WidgetsFlutterBinding initialized');

    // ✅ Load .env before anything that depends on it (quick operation)
    try {
      await dotenv.load(fileName: ".env").timeout(const Duration(seconds: 5));
      print('✅ [MAIN] .env file loaded');
    } on TimeoutException {
      print('⚠️ [MAIN] .env file load timeout, continuing without it');
    } catch (e) {
      print('⚠️ [MAIN] Error loading .env file: $e (continuing anyway)');
    }

    // ✅ Start the app immediately to allow Dart VM Service to be discovered
    print(
      '✅ [MAIN] Starting app (initialization will continue in background)...',
    );
    runApp(const MyApp());
    print('✅ [MAIN] App started');

    // ✅ Initialize services in the background (non-blocking)
    _initializeServices();

    // ✅ Initialize deep link handling
    _initDeepLinks();
  } catch (e, stackTrace) {
    print('❌ [MAIN] Fatal error during initialization: $e');
    print('📚 [MAIN] Stack trace: $stackTrace');
    // In production, you might want to show an error screen instead
    rethrow;
  }
}

/// Initialize services in the background after the app has started
Future<void> _initializeServices() async {
  try {
    print('🔄 [MAIN] Starting background service initialization...');

    // ✅ Firebase initialization
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 15));
      print('✅ [MAIN] Firebase initialized');
    } on TimeoutException {
      print('❌ [MAIN] Firebase initialization timeout');
    } catch (e) {
      print('❌ [MAIN] Error initializing Firebase: $e');
    }

    // ✅ Initialize ApiClient
    try {
      await ApiClient.initialize().timeout(const Duration(seconds: 5));
      print('✅ [MAIN] ApiClient initialized');
    } on TimeoutException {
      print('❌ [MAIN] ApiClient initialization timeout');
    } catch (e) {
      print('❌ [MAIN] Error initializing ApiClient: $e');
    }

    // ✅ Initialize dependency injection
    try {
      await di.init().timeout(const Duration(seconds: 5));
      print('✅ [MAIN] Service locator initialized');
    } on TimeoutException {
      print('❌ [MAIN] Service locator initialization timeout');
    } catch (e) {
      print('❌ [MAIN] Error initializing service locator: $e');
    }

    print('✅ [MAIN] Background initialization complete');
  } catch (e, stackTrace) {
    print('❌ [MAIN] Error during background initialization: $e');
    print('📚 [MAIN] Stack trace: $stackTrace');
  }
}

/// Initialize deep link handling using app_links
void _initDeepLinks() {
  final appLinks = AppLinks();

  // Handle initial link (if app was opened via deep link)
  appLinks
      .getInitialLink()
      .then((Uri? uri) {
        if (uri != null) {
          print('🔗 [DEEP LINK] Initial link: $uri');
          _handleDeepLink(uri.toString());
        }
      })
      .catchError((e) {
        print('⚠️ [DEEP LINK] Error getting initial link: $e');
      });

  // Listen for incoming links while app is running
  appLinks.uriLinkStream.listen(
    (Uri uri) {
      print('🔗 [DEEP LINK] Incoming link: $uri');
      _handleDeepLink(uri.toString());
    },
    onError: (err) {
      print('❌ [DEEP LINK] Error listening to link stream: $err');
    },
  );

  print('✅ [DEEP LINK] Deep link handling initialized');
}

/// Handle deep link navigation
void _handleDeepLink(String link) {
  try {
    print('🔗 [DEEP LINK] Processing link: $link');

    // Parse the link to extract post ID
    // Supports both formats:
    // - https://flyapp.in/post/{postId}
    // - flyapp://post/{postId}
    String? postId;

    try {
      final uri = Uri.parse(link);

      // Handle Universal Link format: https://flyapp.in/post/{postId}
      if (uri.scheme == 'https' && uri.host == 'flyapp.in') {
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty &&
            pathSegments[0] == 'post' &&
            pathSegments.length > 1) {
          postId = pathSegments[1];
        }
      }
      // Handle custom URL scheme format: flyapp://post/{postId}
      else if (uri.scheme == 'flyapp') {
        // Format: flyapp://post/{postId}
        if (uri.host == 'post' && uri.pathSegments.isNotEmpty) {
          postId = uri.pathSegments[0];
        }
        // Format: flyapp://post/{postId} (alternative parsing)
        else if (uri.pathSegments.isNotEmpty &&
            uri.pathSegments[0] == 'post' &&
            uri.pathSegments.length > 1) {
          postId = uri.pathSegments[1];
        }
        // Try extracting from path if host is empty
        else if (uri.path.isNotEmpty) {
          final path = uri.path;
          if (path.startsWith('/post/')) {
            postId = path.substring('/post/'.length);
          }
        }
      }
    } catch (e) {
      print('⚠️ [DEEP LINK] Error parsing URI: $e');
      // Fallback: try simple string extraction
      final match = RegExp(
        r'post/([a-f0-9\-]+)',
        caseSensitive: false,
      ).firstMatch(link);
      if (match != null) {
        postId = match.group(1);
      }
    }

    if (postId != null && postId.isNotEmpty) {
      print('✅ [DEEP LINK] Extracted post ID: $postId');

      // Wait a bit for the app to be ready, then navigate
      Future.delayed(const Duration(milliseconds: 1000), () {
        try {
          // Navigate to home screen first (if not already there)
          if (Get.currentRoute != AppRoutes.Home) {
            Get.offNamedUntil(AppRoutes.Home, (route) => false);
            print('📱 [DEEP LINK] Navigated to home');
          }

          // TODO: Add logic to scroll to or highlight the specific post
          // This could be done by:
          // 1. Passing postId to HomeScreen via Get.arguments
          // 2. Using a controller to scroll to the post
          // 3. Navigating to a post detail screen (if one exists)

          print('📱 [DEEP LINK] Post ID ready for navigation: $postId');
        } catch (e) {
          print('❌ [DEEP LINK] Error during navigation: $e');
        }
      });
    } else {
      print('⚠️ [DEEP LINK] Could not extract post ID from link: $link');
    }
  } catch (e, stackTrace) {
    print('❌ [DEEP LINK] Error handling deep link: $e');
    print('📚 [DEEP LINK] Stack trace: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'fly',
      theme: ThemeData(primarySwatch: Colors.grey),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
