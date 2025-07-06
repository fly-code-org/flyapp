import 'package:get/get.dart';
import '../features/splash/views/splash_screen.dart';
// import '../features/auth/presentation/login_screen.dart';
import '../features/splash/views/onboarding.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/splash', page: () => SplashScreen()),
    GetPage(name: '/onboarding', page: () => Onboarding()),
    // GetPage(name: '/login', page: () => LoginScreen()),
  ];
}
