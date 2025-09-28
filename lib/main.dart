import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:get/get.dart';

import 'firebase_options.dart'; // Generated from flutterfire configure
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  // ✅ Always initialize bindings first for async setup
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load .env before anything that depends on it
  await dotenv.load(fileName: ".env");

  // ✅ Firebase initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
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
