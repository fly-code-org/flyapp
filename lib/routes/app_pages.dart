import 'package:fly/features/create_community/presentation/views/community_guidelines.dart';
import 'package:fly/features/create_community/presentation/views/community_profile_screen.dart';
import 'package:fly/features/create_community/presentation/views/create_support_community.dart';
import 'package:fly/features/create_community/presentation/views/edit_community_details.dart';
import 'package:fly/features/explore/presentation/views/explore.dart';
import 'package:fly/features/home/presentation/views/home.dart';
import 'package:fly/features/mhp_profile/presentation/views/mhp_profile_screen.dart';
import 'package:fly/features/nira/screens/nira_chat_screen.dart';
import 'package:fly/features/profile_creation/presentation/views/add_session_form.dart';
import 'package:fly/features/profile_creation/presentation/views/mhp_more_info.dart';
import 'package:fly/features/profile_creation/presentation/views/mhp_profile_form.dart';
import 'package:fly/features/profile_creation/presentation/views/user_profile_form.dart';
import 'package:fly/features/start_quiz/views/get_interest.dart';
import 'package:fly/features/start_quiz/views/intro.dart';
import 'package:fly/features/start_quiz/views/mhp_first_question.dart';
import 'package:fly/features/start_quiz/views/mhp_fourth_question.dart';
import 'package:fly/features/start_quiz/views/mhp_second_question.dart';
import 'package:fly/features/start_quiz/views/mhp_third_question.dart';
import 'package:fly/features/start_quiz/views/user_first_question.dart';
import 'package:fly/features/start_quiz/views/user_fourth_ques.dart';
import 'package:fly/features/start_quiz/views/user_second_ques.dart';
import 'package:fly/features/start_quiz/views/user_third_ques.dart';
import 'package:fly/features/user_profile/presentation/views/create_journal_screen.dart';
import 'package:fly/features/user_profile/presentation/views/user_profile_screen.dart';
import 'package:fly/features/user_profile/presentation/views/user_settings.dart';
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
    // GetPage(
    //   name: AppRoutes.userProfile,
    //   page: () => const CreateUserProfileScreen(),
    // ),
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
      page: () => const CreateMhpProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.createUserProfile,
      page: () => const CreateUserProfileScreen(),
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
      name: AppRoutes.MHPQuestion1,
      page: () => const MhpQuestionOneScreen(),
    ),
    GetPage(
      name: AppRoutes.UserQuestion2,
      page: () => const UserQuestionSecondScreen(),
    ),
    GetPage(
      name: AppRoutes.MHPQuestion2,
      page: () => const MhpQuestionSecondScreen(),
    ),
    GetPage(
      name: AppRoutes.UserQuestion3,
      page: () => const UserQuestionThirdScreen(),
    ),
    GetPage(
      name: AppRoutes.MHPQuestion3,
      page: () => const MhpQuestionThirdScreen(),
    ),
    GetPage(
      name: AppRoutes.UserQuestion4,
      page: () => const UserQuestionFourthScreen(),
    ),
    GetPage(
      name: AppRoutes.MHPQuestion4,
      page: () => const MhpQuestionFourthScreen(),
    ),

    GetPage(
      name: AppRoutes.CreateSupportCommunity,
      page: () => const CreateSupportCommunityScreen(),
    ),
    GetPage(
      name: AppRoutes.CommunitySupportProfile,
      page: () => const CommunitySupportProfile(),
    ),
    GetPage(
      name: AppRoutes.EditCommunity,
      page: () => const EditCommunityScreen(),
    ),
    GetPage(
      name: AppRoutes.CommunityGuidelines,
      page: () => const CommunityGuidelineScreen(),
    ),

    // user profile flow
    GetPage(
      name: AppRoutes.CreateJournalScreen,
      page: () => const CreateJournalScreen(),
    ),
    GetPage(
      name: AppRoutes.UserSettingsScreen,
      page: () => const UserSettingsScreen(),
    ),

    GetPage(name: AppRoutes.mhpProfile, page: () => const MhpProfileScreen()),

    // Bottom Nav
    GetPage(name: AppRoutes.Home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.Explore, page: () => ExploreScreen()),
    GetPage(name: AppRoutes.Nira, page: () => NiraChatScreen()),
    // GetPage(name: AppRoutes.Notifications, page: () => const NotificationsScreen()),
    GetPage(name: AppRoutes.Profile, page: () => const UserProfileScreen()),
    // GetPage(name: AppRoutes.MhpStartQuiz, page: () => const MhpStartQuiz())
  ];
}
