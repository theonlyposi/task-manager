import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/tasks_cubit.dart';
import 'package:frontend/features/auth/pages/verify_otp_signup_page.dart';
import 'package:frontend/intropage.dart';
import 'package:frontend/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import 'features/home/pages/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize(); // ✅ Initialize notifications

  final authCubit = AuthCubit();
  await authCubit.getUserData(); // ✅ Load user info at launch

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(create: (_) => TasksCubit()),
      ],
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Task App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.currentTheme,
      theme: ThemeData(
        fontFamily: "Cera Pro",
        brightness: Brightness.light,
        useMaterial3: true,
        inputDecorationTheme: _inputDecoration(),
        elevatedButtonTheme: _elevatedButtonTheme(Colors.black),
      ),
      darkTheme: ThemeData(
        fontFamily: "Cera Pro",
        brightness: Brightness.dark,
        useMaterial3: true,
        inputDecorationTheme: _inputDecoration(),
        elevatedButtonTheme: _elevatedButtonTheme(Colors.white),
      ),
      home: const IntroPage(),

      // ✅ Handle dynamic routing (e.g., after signup redirect to VerifyOtp page)
      onGenerateRoute: (settings) {
        if (settings.name == '/verifyOtp') {
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => VerifyOtpSignupPage(email: email),
          );
        }
        return null;
      },
    );
  }

  InputDecorationTheme _inputDecoration() {
    return InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  ElevatedButtonThemeData _elevatedButtonTheme(Color backgroundColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

