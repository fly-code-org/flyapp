import 'package:fly/features/create_profile/presentation/views/mhp_profile.dart';
import 'package:fly/features/create_profile/presentation/views/user_profile.dart';
import 'package:fly/features/profile_creation/presentation/views/add_session_form.dart';
import 'package:fly/features/profile_creation/presentation/views/mhp_more_info.dart';
import 'package:fly/features/profile_creation/presentation/views/mhp_profile_form.dart';
import 'package:fly/features/profile_creation/presentation/views/user_profile_form.dart';
import 'package:fly/features/start_quiz/views/get_interest.dart';
import 'package:fly/features/start_quiz/views/intro.dart';
import 'package:fly/features/start_quiz/views/user_first_question.dart';
import 'package:fly/features/start_quiz/views/user_fourth_ques.dart';
import 'package:fly/features/start_quiz/views/user_second_ques.dart';
import 'package:fly/features/start_quiz/views/user_third_ques.dart';
import 'package:fly/features/user_verification/presentation/views/email_verification.dart';
import 'package:fly/features/user_verification/presentation/views/phone_verification.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import '../features/splash/views/splash_screen.dart';
// import '../features/auth/presentation/login_screen.dart';
import '../features/splash/views/onboarding.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/splash', page: () => SplashScreen()),
    GetPage(name: '/onboarding', page: () => Onboarding()),
    GetPage(name: AppRoutes.userProfile, page: () => const UserProfileScreen()),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => const EmailVerification(),
    ),
    GetPage(
      name: AppRoutes.phoneVerification,
      page: () => const PhoneVerification(),
    ),
    GetPage(
      name: AppRoutes.createMhpProfile,
      page: () => const MhpProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.createUserProfile,
      page: () => const UserProfileScreen(),
    ),
    GetPage(name: AppRoutes.AddMoreInfo, page: () => const MoreInfoScreen()),
    GetPage(
      name: AppRoutes.AddSessionForm,
      page: () => const AddSessionScreen(),
    ),
    // GetPage(name: '/login', page: () => LoginScreen()),
    // Q&A Flow
    GetPage(name: AppRoutes.IntroScreen, page: () => const QuizIntroScreen()),
    GetPage(name: AppRoutes.GetInterest, page: () => const GetInterestScreen()),
    GetPage(
      name: AppRoutes.UserQuestion1,
      page: () => const UserQuestionOneScreen(),
    ),
    GetPage(
      name: AppRoutes.UserQuestion2,
      page: () => const UserQuestionSecondScreen(),
    ),
    GetPage(
      name: AppRoutes.UserQuestion3,
      page: () => const UserQuestionThirdScreen(),
    ),
    GetPage(
      name: AppRoutes.UserQuestion4,
      page: () => const UserQuestionFourthScreen(),
    ),
    // GetPage(name: AppRoutes.MhpStartQuiz, page: () => const MhpStartQuiz())
  ];
}
