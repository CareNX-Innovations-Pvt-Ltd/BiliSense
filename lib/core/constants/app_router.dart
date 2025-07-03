import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/presentation/all_mothers/all_mothers_view.dart';
import 'package:bili_sense/presentation/bluetooth_list/bluetooth_list_view.dart';
import 'package:bili_sense/presentation/home/home_view.dart';
import 'package:bili_sense/presentation/home/main_nav_view.dart';
import 'package:bili_sense/presentation/login/login_view.dart';
import 'package:bili_sense/presentation/mother_details/mother_details_view.dart';
import 'package:bili_sense/presentation/report/report_view.dart';
import 'package:bili_sense/presentation/splash/splash_view.dart';
import 'package:bili_sense/presentation/test/test_view.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String testHistory = '/test-history';
  static const String mainNav = '/main-nav';
  static const String bluetooth = '/bluetooth';
  static const String profile = '/profile';
  static const String motherDetails = '/mother-details';
  static const String report = '/report';
  static const String test = '/test';
  static const String allNewborns = '/all-newborns';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      name: '/',
      path: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      name: '/login',
      path: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      name: '/bluetooth',
      path: AppRoutes.bluetooth,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final motherModel = extra?['motherModel'] as MotherModel;
        final List<TestModel> tests = extra?['tests'] ?? [];
        return BluetoothListView(motherModel: motherModel, tests: tests,);
      },
    ),
    GoRoute(
      name: '/home',
      path: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      name: '/main-nav',
      path: AppRoutes.mainNav,
      builder: (context, state) => const MainNavigationView(),
    ),
    GoRoute(
      name: '/mother-details',
      path: AppRoutes.motherDetails,
      builder: (context, state) {
        final motherModel = state.extra as MotherModel;
        return MotherDetailsView(motherModel: motherModel);
      },
    ),
    GoRoute(
      name: '/report',
      path: AppRoutes.report,
      builder: (context, state) {
        final model = state.extra as Map<String, dynamic>;
        final List<TestModel> tests = model['tests'] ?? [];
        final MotherModel motherModel = model['motherModel'] as MotherModel;
        return ReportView(tests: tests, motherModel: motherModel);
      },
    ),
    GoRoute(
      name: '/test',
      path: AppRoutes.test,
      builder: (context, state) {
        final model = state.extra as Map<String, dynamic>;
        final BluetoothDevice device = model['device'] as BluetoothDevice;
        final MotherModel motherModel = model['motherModel'] as MotherModel;
        return TestView(motherModel: motherModel, device: device,);
      },
    ),
    GoRoute(
      name: '/all-newborns',
      path: AppRoutes.allNewborns,
      builder: (context, state) {
        return AllMothersView();
      },
    ),
  ],
);
