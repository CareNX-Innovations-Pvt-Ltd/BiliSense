import 'package:bili_sense/core/constants/theme.dart';
import 'package:bili_sense/core/service/auth_service.dart';
import 'package:bili_sense/core/util.dart';
import 'package:bili_sense/presentation/all_mothers/all_mother_cubit.dart';
import 'package:bili_sense/presentation/test/test_cubit.dart';
import 'package:bili_sense/presentation/home/home_cubit.dart';
import 'package:bili_sense/presentation/login/login_cubit.dart';
import 'package:bili_sense/presentation/mother_details/mother_details_cubit.dart';
import 'package:bili_sense/presentation/test_history/test_history_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_router.dart';
import 'core/network/di.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 await setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Roboto", "Actor");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (context) => LoginCubit(getIt<AuthService>()),
        ),
        BlocProvider<HomeCubit>(
          create: (context) => HomeCubit(),
        ),
        BlocProvider<MotherDetailsCubit>(
          create: (context) => MotherDetailsCubit(),
        ),
        BlocProvider<TestCubit>(
          create: (context) => TestCubit(),
        ),
        BlocProvider<TestHistoryCubit>(
          create: (context) => TestHistoryCubit(),
        ),
        BlocProvider<AllMotherCubit>(
          create: (context) => AllMotherCubit(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        // theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        theme: theme.light(),
      ),
    );
  }
}
