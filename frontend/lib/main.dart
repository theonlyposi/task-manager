import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/buttom_nav.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/tasks_cubit.dart';
import 'package:frontend/intropage.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/providers/theme_provider.dart';
import 'package:frontend/features/auth/pages/verify_otp_signup_page.dart'; // import your VerifyOtpSignupPage

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
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

      // ✅ Added this block to handle dynamic route to VerifyOtpSignupPage
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


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:frontend/buttom_nav.dart';
// import 'package:frontend/features/auth/cubit/auth_cubit.dart';
// import 'package:frontend/features/auth/pages/login_page.dart';
// import 'package:frontend/features/home/cubit/tasks_cubit.dart';
// import 'package:frontend/features/navs/notification.dart';
// import 'package:frontend/intropage.dart';
// import 'package:provider/provider.dart';
// import 'package:frontend/presentation/providers/theme_provider.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   final authCubit = AuthCubit();
//   await authCubit.getUserData();  // <-- WAIT here to load the user BEFORE UI loads
//
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider.value(value: authCubit),
//         BlocProvider(create: (_) => TasksCubit()),
//       ],
//       child: ChangeNotifierProvider(
//         create: (_) => ThemeProvider(),
//         child: const MyApp(),
//       ),
//     ),
//   );
// }
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//
//     return MaterialApp(
//       title: 'Task App',
//       debugShowCheckedModeBanner: false,
//       themeMode: themeProvider.currentTheme,
//       theme: ThemeData(
//         fontFamily: "Cera Pro",
//         brightness: Brightness.light,
//         useMaterial3: true,
//         inputDecorationTheme: _inputDecoration(),
//         elevatedButtonTheme: _elevatedButtonTheme(Colors.black),
//       ),
//       darkTheme: ThemeData(
//         fontFamily: "Cera Pro",
//         brightness: Brightness.dark,
//         useMaterial3: true,
//         inputDecorationTheme: _inputDecoration(),
//         elevatedButtonTheme: _elevatedButtonTheme(Colors.white),
//       ),
//       home: const   IntroPage(),
//     );
//   }
//
//   InputDecorationTheme _inputDecoration() {
//     return InputDecorationTheme(
//       contentPadding: const EdgeInsets.all(27),
//       enabledBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: Colors.grey.shade300, width: 3),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(width: 3),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       border: OutlineInputBorder(
//         borderSide: const BorderSide(width: 3),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Colors.red, width: 3),
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//   }
//
//   ElevatedButtonThemeData _elevatedButtonTheme(Color backgroundColor) {
//     return ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: backgroundColor,
//         minimumSize: const Size(double.infinity, 60),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:frontend/buttom_nav.dart';
// import 'package:frontend/features/auth/cubit/auth_cubit.dart';
// import 'package:frontend/features/home/cubit/tasks_cubit.dart';
// import 'package:frontend/features/navs/notification.dart';
// import 'package:frontend/intropage.dart';
// import 'package:provider/provider.dart';
// import 'package:frontend/presentation/providers/theme_provider.dart'; // ✅ new
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationService.initialize();
//
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => AuthCubit()),
//         BlocProvider(create: (_) => TasksCubit()),
//       ],
//       child: ChangeNotifierProvider(
//         create: (_) => ThemeProvider(),
//         child: const MyApp(),
//       ),
//     ),
//   );
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<AuthCubit>().getUserData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//
//     return MaterialApp(
//       title: 'Task App',
//       debugShowCheckedModeBanner: false,
//       themeMode: themeProvider.currentTheme,
//       theme: ThemeData(
//         fontFamily: "Cera Pro",
//         brightness: Brightness.light,
//         useMaterial3: true,
//         inputDecorationTheme: _inputDecoration(),
//         elevatedButtonTheme: _elevatedButtonTheme(Colors.black),
//       ),
//       darkTheme: ThemeData(
//         fontFamily: "Cera Pro",
//         brightness: Brightness.dark,
//         useMaterial3: true,
//         inputDecorationTheme: _inputDecoration(),
//         elevatedButtonTheme: _elevatedButtonTheme(Colors.white),
//       ),
//       home: IntroPage( ),
//     );
//   }
//
//   InputDecorationTheme _inputDecoration() {
//     return InputDecorationTheme(
//       contentPadding: const EdgeInsets.all(27),
//       enabledBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: Colors.grey.shade300, width: 3),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(width: 3),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       border: OutlineInputBorder(
//         borderSide: const BorderSide(width: 3),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: Colors.red, width: 3),
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//   }
//
//   ElevatedButtonThemeData _elevatedButtonTheme(Color backgroundColor) {
//     return ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: backgroundColor,
//         minimumSize: const Size(double.infinity, 60),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//       ),
//     );
//   }
// }
