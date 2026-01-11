import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:get/get.dart';

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
