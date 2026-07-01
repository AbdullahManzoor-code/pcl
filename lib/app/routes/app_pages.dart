import 'package:get/get.dart';

// Bindings will be added as we create them
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/reset_email_sent_view.dart';
import '../modules/auth/views/reset_password_view.dart';
import '../modules/auth/views/email_verification_view.dart';
import '../modules/auth/views/verification_sent_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/language_selection/bindings/language_selection_binding.dart';
import '../modules/language_selection/views/language_selection_view.dart';

import '../modules/results/bindings/results_binding.dart';
import '../modules/results/views/results_view.dart';
import '../modules/results/views/result_history_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/learning/bindings/learning_binding.dart';
import '../modules/learning/views/learning_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/change_password_view.dart';
import '../modules/course_details/bindings/course_details_binding.dart';
import '../modules/course_details/views/course_details_view.dart';
import '../modules/quiz/bindings/quiz_binding.dart';
import '../modules/quiz/views/quiz_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/my_courses/bindings/my_courses_binding.dart';
import '../modules/my_courses/views/my_courses_view.dart';
import '../modules/landing/bindings/landing_binding.dart';
import '../modules/landing/views/landing_view.dart';
import '../modules/practice/bindings/practice_binding.dart';
import '../modules/practice/views/practice_view.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/analytics/views/analytics_view.dart';
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/courses/bindings/courses_binding.dart';
import '../modules/courses/views/courses_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static String get initial {
    return Routes.splash;
  }

  static final routes = [
    // We will populate this as we build modules
    GetPage(
      name: _Paths.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.auth,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.languageSelection,
      page: () => const LanguageSelectionView(),
      binding: LanguageSelectionBinding(),
    ),
    GetPage(
      name: _Paths.results,
      page: () => ResultsView(),
      binding: ResultsBinding(),
    ),
    GetPage(
      name: _Paths.resultHistory,
      page: () => const ResultHistoryView(),
      // We are just injecting the controller directly in the view
    ),

    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.learning,
      page: () => const LearningView(),
      binding: LearningBinding(),
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.courseDetails,
      page: () => const CourseDetailsView(),
      binding: CourseDetailsBinding(),
    ),
    GetPage(
      name: _Paths.quiz,
      page: () => const QuizView(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: _Paths.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: _Paths.courses,
      page: () => const CoursesView(),
      binding: CoursesBinding(),
    ),
    GetPage(
      name: _Paths.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.myCourses,
      page: () => const MyCoursesView(),
      binding: MyCoursesBinding(),
    ),
    // GetPage(
    //   name: _Paths.landing,
    //   page: () => const LandingView(),
    //   binding: LandingBinding(),
    // ),
    GetPage(
      name: _Paths.practice,
      page: () => const PracticeView(),
      binding: PracticeBinding(),
    ),
    GetPage(
      name: _Paths.analytics,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: _Paths.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: _Paths.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.resetEmailSent,
      page: () => const ResetEmailSentView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.changePassword,
      page: () => const ChangePasswordView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.emailVerification,
      page: () => const EmailVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.verificationSent,
      page: () => const VerificationSentView(),
      binding: AuthBinding(),
    ),
  ];
}
