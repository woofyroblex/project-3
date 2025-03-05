import 'package:flutter/material.dart';
import 'package:myapp/screens/main/subscription_screen.dart';
import 'package:myapp/screens/main/payment_screen.dart';
import 'package:myapp/screens/main/report_lost_item_screen.dart';
import 'package:myapp/screens/main/found_item_screen.dart';
import 'package:myapp/screens/main/notifications_screen.dart';
import 'package:myapp/screens/main/history_screen.dart';
import 'package:myapp/screens/main/my_reports_screen.dart';
import 'package:myapp/screens/main/search_items_screen.dart';
import 'package:myapp/screens/admin/admin_dashboard_screen.dart';
import 'package:myapp/screens/admin/report_management_screen.dart';
import 'package:myapp/screens/admin/transaction_management_screen.dart';
import 'package:myapp/screens/admin/user_management_screen.dart';
import 'package:myapp/screens/ai/ai_image_enhancement_screen.dart';
import 'package:myapp/screens/ai/ai_matching_screen.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/auth/signup_screen.dart';
import 'package:myapp/screens/business/business_partners_screen.dart';
import 'package:myapp/screens/community/community_watch_screen.dart';
import 'package:myapp/screens/law_enforcement/police_integration_screen.dart';
import 'package:myapp/screens/main/dashboard_screen.dart';
import 'package:myapp/screens/main/profile_screen.dart';
import 'package:myapp/screens/main/settings_screen.dart';
// Added missing import

class AppRoutes {
  static const String initialRoute = '/';
  static const String subscription = '/subscription';
  static const String payment = '/payment';
  static const String reportLostItem = '/report-lost-item';
  static const String reportFoundItem = '/report-found-item';
  static const String notifications = '/notifications';
  static const String history = '/history';
  static const String myReports = '/my-reports';
  static const String adminDashboard = '/admin-dashboard';
  static const String reportManagement = '/report-management';
  static const String transactionManagement = '/transaction-management';
  static const String userManagement = '/user-management';
  static const String aiEnhancement = '/ai-enhancement';
  static const String aiMatching = '/ai-matching';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String businessPartners = '/business-partners';
  static const String communityWatch = '/community-watch';
  static const String policeIntegration = '/police-integration';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String searchItems = '/search-items';

  static var routes; // Added missing route

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case subscription:
        return MaterialPageRoute(builder: (_) => SubscriptionScreen());
      case payment:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            videoUrl: args['videoUrl'],
            amount: args['amount'],
            contactInfo: args['contactInfo'],
          ),
        );
      case reportLostItem:
        return MaterialPageRoute(builder: (_) => ReportLostItemScreen());
      case reportFoundItem:
        return MaterialPageRoute(builder: (_) => ReportFoundItemScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => NotificationsScreen());
      case history:
        return MaterialPageRoute(builder: (_) => HistoryScreen());
      case myReports:
        return MaterialPageRoute(builder: (_) => MyReportsScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => AdminDashboardScreen());
      case reportManagement:
        return MaterialPageRoute(builder: (_) => ReportManagementScreen());
      case transactionManagement:
        return MaterialPageRoute(builder: (_) => TransactionManagementScreen());
      case userManagement:
        return MaterialPageRoute(builder: (_) => UserManagementScreen());
      case aiEnhancement:
        return MaterialPageRoute(builder: (_) => AIEnhancementScreen());
      case aiMatching:
        return MaterialPageRoute(builder: (_) => AIMatchingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case businessPartners:
        return MaterialPageRoute(builder: (_) => BusinessPartnersScreen());
      case communityWatch:
        return MaterialPageRoute(builder: (_) => CommunityWatchScreen());
      case policeIntegration:
        return MaterialPageRoute(builder: (_) => PoliceIntegrationScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case searchItems: // Added missing route case
        return MaterialPageRoute(builder: (_) => SearchItemsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
