import 'package:flutter/material.dart';
import 'package:siankes/presentation/screens/home/health_article_screen.dart';
import 'package:siankes/presentation/screens/splash/splash_screen.dart';
import 'package:siankes/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:siankes/presentation/screens/auth/login_screen.dart';
import 'package:siankes/presentation/screens/auth/register_screen.dart';
import 'package:siankes/presentation/screens/auth/forgot_password_screen.dart';
import 'package:siankes/presentation/screens/home/home_screen.dart';
import 'package:siankes/presentation/screens/queue/take_queue_screen.dart';
import 'package:siankes/presentation/screens/queue/queue_status_screen.dart';
import 'package:siankes/presentation/screens/booking/booking_screen.dart';
import 'package:siankes/presentation/screens/doctor/doctor_detail_screen.dart';
import 'package:siankes/presentation/screens/polyclinic/polyclinic_list_screen.dart';
import 'package:siankes/presentation/screens/history/history_detail_screen.dart';
import 'package:siankes/presentation/screens/profile/edit_profile_screen.dart';
import 'package:siankes/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:siankes/presentation/screens/notifications/notifications_screen.dart';
import 'package:siankes/presentation/screens/qr/scan_qr_screen.dart';
import 'package:siankes/presentation/screens/doctor/doctor_list_screen.dart';
import 'package:siankes/data/models/queue_model.dart';
import 'package:siankes/data/models/booking_model.dart';
import 'package:siankes/data/models/doctor_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(const SplashScreen(), settings);
      case '/onboarding':
        return _buildRoute(const OnboardingScreen(), settings);
      case '/login':
        return _buildRoute(const LoginScreen(), settings);
      case '/register':
        return _buildRoute(const RegisterScreen(), settings);
      case '/forgot-password':
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case '/home':
        return _buildRoute(const HomeScreen(), settings);
      case '/take-queue':
        return _buildRoute(const TakeQueueScreen(), settings);
      case '/queue-status':
        final queue = settings.arguments as QueueModel;
        return _buildRoute(QueueStatusScreen(queue: queue), settings);
      case '/doctor-detail':
        final doctor = settings.arguments as DoctorModel;
        return _buildRoute(DoctorDetailScreen(doctor: doctor), settings);
      case '/booking':
        return _buildRoute(const BookingScreen(), settings);
      case '/doctors':
        return _buildRoute(const DoctorListScreen(), settings);
      case '/polyclinics':
        return _buildRoute(const PolyclinicListScreen(), settings);
      case '/history-detail-queue':
        final queue = settings.arguments as QueueModel;
        return _buildRoute(HistoryDetailScreen(queueHistory: queue), settings);
      case '/history-detail-booking':
        final booking = settings.arguments as BookingModel;
        return _buildRoute(HistoryDetailScreen(bookingHistory: booking), settings);
      case '/edit-profile':
        return _buildRoute(const EditProfileScreen(), settings);
      case '/admin':
        return _buildRoute(const AdminDashboardScreen(), settings);
      case '/notifications':
        return _buildRoute(const NotificationsScreen(), settings);
      case '/scan-qr':
        return _buildRoute(const ScanQRScreen(), settings);
      case '/health-article':
        final args = settings.arguments as HealthArticleArgs;
        return _buildRoute(HealthArticleScreen(args: args), settings);
      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
