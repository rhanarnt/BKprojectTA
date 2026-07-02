import 'package:flutter/material.dart';
import 'package:finalproject/theme/app_theme.dart';
import 'package:finalproject/screens/splash_screen.dart';
import 'package:finalproject/screens/login/login_page.dart';
import 'package:finalproject/screens/dashboard/dashboard_page.dart';
import 'package:finalproject/screens/prediction/prediction_page.dart';
import 'package:finalproject/screens/transaction/transaction_page.dart';
import 'package:finalproject/screens/products/product_list_page.dart';
import 'package:finalproject/screens/reports/report_page.dart';
import 'package:finalproject/screens/settings/settings_page.dart';
import 'package:finalproject/screens/settings/recipe_list_page.dart';
import 'package:finalproject/screens/settings/recipe_form_page.dart';
import 'package:finalproject/utils/route_observer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tobaku Sulastri',
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/prediction': (context) => const PredictionScreen(),
        '/transaction': (context) => const TransactionScreen(),
        '/products': (context) => const ProductListScreen(),
        '/reports': (context) => const ReportScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/recipes-manage': (context) => const RecipeListPage(),
        '/recipe-form': (context) => const RecipeFormPage(),
      },
    );
  }
}
