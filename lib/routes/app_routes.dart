
abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const userProfile = '/user-profile';
  static const mhpProfile = '/mhp-profile';

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

  /// User books a session with an MHP (date, preference, duration, slot, "Let's connect").
  static const bookSession = '/book-session';

  /// Payment / checkout after booking choices (Razorpay).
  static const sessionPayment = '/session-payment';

  /// Shown after connect checkout payment succeeds (Razorpay + server confirm).
  static const connectPaymentSuccess = '/connect-payment-success';

  /// Explore "See All" — full Discover Mental Health Professionals grid.
  static const discoverMhps = '/discover-mhps';

  // bottom nav
  static const Home = '/home';
  static const Explore = '/explore';
  static const Nira = '/nira';
  static const NotificationScreen = '/notifications';
  static const Profile = '/profile';

  //User Profile Flow
  static const CreateJournalScreen = '/create-journal-screen';
  static const UserSettingsScreen = '/user-settings-screen';

  // User Settings Flow
  static const UserEditProfile = '/user-edit-profile';
  static const UserManagePreferences = '/user-manage-preferences';
  static const UserBlockedUsers = '/user-blocked-users';
  static const UserChangePassword = '/user-change-password';
  static const UserManageSessions = '/user-manage-sessions';
  static const UserPaymentHistory = '/user-payment-history';
  static const UserTermsConditions = '/user-terms-conditions';
  static const UserContactUs = '/user-contact-us';

  // MHP Settings Flow
  static const MhpEditProfile = '/mhp-edit-profile';
  static const MhpSettingsScreen = '/mhp-settings-screen';
  static const MhpChangePassword = '/mhp-change-password';
  static const MhpUpdateSpecializations = '/mhp-update-specializations';
  static const MhpAvailabilitySchedule = '/mhp-availability-schedule';
  static const MhpSessionPreferences = '/mhp-session-preferences';
  static const MhpSessionModes = '/mhp-session-modes';
  static const MhpPaymentManagement = '/mhp-payment-management';
  static const MhpInvoices = '/mhp-invoices';
  static const MhpContactUs = '/mhp-contact-us';

  /// Subscription
  static const subscriptionPlans = '/subscription-plans';

  /// Legal
  static const termsConditions = '/terms-conditions';
  static const privacyPolicy = '/privacy-policy';
}
