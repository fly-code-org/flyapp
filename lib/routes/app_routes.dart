import 'package:fly/features/create_community/presentation/views/community_guidelines.dart';
import 'package:fly/features/user_profile/presentation/views/create_journal_screen.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const userProfile = '/user-profile';

  static const emailVerification = '/email-verification';
  static const phoneVerification = '/phone-verification';

  static const createUserProfile = '/create-user-profile';
  static const createMhpProfile = '/create-mhp-profile';
  static const AddMoreInfo = '/add-more-info';
  static const AddSessionForm = '/add-session-form';
  // Q&A Flow
  static const IntroScreen = '/intro-quiz';
  static const UserStartQuiz = '/user-quiz';
  static const UserQuestion1 = '/question-one';
  static const MHPQuestion1 = '/mhp-question-one';
  static const UserQuestion2 = '/question-two';
  static const MHPQuestion2 = '/mhp-question-two';
  static const UserQuestion3 = '/question-three';
  static const MHPQuestion3 = '/mhp-question-three';
  static const UserQuestion4 = '/question-four';
  static const MHPQuestion4 = '/mhp-question-four';
  static const GetInterest = '/get-interest';

  // Community Flow
  static const CreateSocialCommunity = '/create-social-community';
  static const CreateSupportCommunity = '/create-support-community';
  static const CommunitySocialProfile = '/community-social-profile';
  static const CommunitySupportProfile = '/community-support-profile';
  static const EditCommunity = '/edit-community';
  static const CommunityGuidelines = '/community-guidelines';

  // bottom nav
  static const Home = '/home';
  static const Explore = '/explore';
  static const Nira = '/nira';
  static const Notifications = '/notifications';
  static const Profile = '/profile';

  //User Profile Flow
  static const CreateJournalScreen = '/create-journal-screen';
  static const UserSettingsScreen = '/user-settings-screen';
}
