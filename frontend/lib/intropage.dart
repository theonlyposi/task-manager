import 'package:flutter/material.dart';

import 'buttom_nav.dart';
import 'features/auth/pages/login_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final bgGradient = isDarkMode
        ? const LinearGradient(
      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final headlineColor = Colors.white;
    final paragraphColor = Colors.white70;
    final buttonColor = isDarkMode ? Colors.tealAccent.shade700 : Colors.blueAccent;

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.8, maxHeight: 300),
                      child: Image.asset('assets/task3.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Get things done with TODs",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: 1.2,
                        color: headlineColor,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Stay organized, focused, and productive with our Task Management App. "
                          "Effortlessly create, track, and manage your daily tasks — all in one place. "
                          "Whether you're managing personal to-dos or professional goals, this app helps you stay on top of what matters most.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: paragraphColor,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black54,
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'buttom_nav.dart';
// import 'features/auth/pages/login_page.dart';
//
// class IntroPage extends StatefulWidget {
//   const IntroPage({super.key});
//
//   @override
//   State<IntroPage> createState() => _IntroPageState();
// }
//
// class _IntroPageState extends State<IntroPage> {
//   bool _isChecking = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthState();
//   }
//
//   Future<void> _checkAuthState() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');
//
//     if (token != null) {
//       try {
//         final response = await http.post(
//           Uri.parse('http://172.20.10.5:8000/auth/tokenIsValid'),
//           headers: {
//             'x-auth-token': token,
//             'Content-Type': 'application/json',
//           },
//         );
//
//         if (response.statusCode == 200) {
//           final isValid = jsonDecode(response.body) as bool;
//           if (isValid) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const TheNav()),
//             );
//             return;
//           }
//         }
//       } catch (e) {
//         debugPrint("Token validation error: $e");
//       }
//
//       await prefs.remove('auth_token');
//     }
//
//     // Show intro if not authenticated
//     setState(() {
//       _isChecking = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isChecking) {
//       return const Scaffold(
//         backgroundColor: Colors.black12,
//         body: Center(
//           child: CircularProgressIndicator(color: Colors.white),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SafeArea(
//             child: Image.asset(
//               'assets/task3.png',
//               width: 700,
//               height: 350,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
//             child: Text(
//               "Gets things with TODs",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 22,
//                 letterSpacing: 1,
//                 color: Colors.black,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black38,
//                     offset: Offset(2, 2),
//                     blurRadius: 4,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
//             child: Text(
//               "Stay organized, focused, and productive with our Task Management App. "
//                   "Effortlessly create, track, and manage your daily tasks—all in one place. "
//                   "Whether you're managing personal to-dos or professional goals, this app helps you stay on top of what matters most.",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           const SizedBox(height: 56),
//           GestureDetector(
//             onTap: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LoginPage()),
//               );
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(9),
//                 color: const Color(0xFF0C2C9F),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 20),
//               child: const Text(
//                 "Get Started",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;
// //
// // import 'buttom_nav.dart';
// // import 'features/auth/pages/login_page.dart';
// //
// //
// // class IntroPage extends StatefulWidget {
// //   const IntroPage({super.key});
// //
// //   @override
// //   State<IntroPage> createState() => _IntroPageState();
// // }
// //
// // class _IntroPageState extends State<IntroPage> {
// //   bool _isChecking = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkAuthState();
// //   }
// //
// //   Future<void> _checkAuthState() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('auth_token');
// //
// //     if (token != null) {
// //       final response = await http.post(
// //         Uri.parse('http://172.20.10.5:8000/auth/tokenIsValid'),
// //         headers: {
// //           'x-auth-token': token,
// //           'Content-Type': 'application/json',
// //         },
// //       );
// //
// //       if (response.statusCode == 200) {
// //         final isValid = jsonDecode(response.body) as bool;
// //         if (isValid) {
// //           Navigator.pushReplacement(
// //             context,
// //             MaterialPageRoute(builder: (context) => TheNav()),
// //           );
// //           return; // Don't show intro
// //         }
// //       }
// //
// //       await prefs.remove('auth_token');
// //     }
// //
// //     // Done checking, show intro
// //     setState(() {
// //       _isChecking = false;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (_isChecking) {
// //       return const Scaffold(
// //         backgroundColor: Colors.black12,
// //         body: Center(
// //           child: CircularProgressIndicator(color: Colors.white),
// //         ),
// //       );
// //     }
// //
// //     return Scaffold(
// //       backgroundColor: Colors.black12,
// //       body: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           SafeArea(
// //             child: Image.asset(
// //               'assets/task3.png',
// //               width: 700,
// //               height: 350,
// //             ),
// //           ),
// //           const SizedBox(height: 10),
// //           const Padding(
// //             padding: EdgeInsets.fromLTRB(30, 8, 30, 8),
// //             child: Text(
// //               "Gets things with TODs",
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 22,
// //                 letterSpacing: 1,
// //                 color: Colors.white,
// //                 shadows: [
// //                   Shadow(
// //                     color: Colors.black38,
// //                     offset: Offset(2, 2),
// //                     blurRadius: 4,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           const Padding(
// //             padding: EdgeInsets.fromLTRB(30, 14, 30, 8),
// //             child: Text(
// //               "Stay organized, focused, and productive with our Task Management App. "
// //                   "Effortlessly create, track, and manage your daily tasks—all in one place. "
// //                   "Whether you're managing personal to-dos or professional goals, this app helps you stay on top of what matters most.",
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 56),
// //           GestureDetector(
// //             onTap: () {
// //               Navigator.pushReplacement(
// //                 context,
// //                 MaterialPageRoute(builder: (context) => LoginPage()),
// //               );
// //             },
// //             child: Container(
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(9),
// //                 color: const Color(0xFF0C2C9F),
// //               ),
// //               padding: const EdgeInsets.fromLTRB(125, 20, 125, 20),
// //               child: const Text(
// //                 "Get Started",
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// //
// // // import 'package:flutter/material.dart';
// // //
// // // import 'features/auth/pages/login_page.dart';
// // // // import 'package:figma/pages/login_page.dart';
// // //
// // // class IntroPage extends StatelessWidget {
// // //   const IntroPage({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       // backgroundColor: Color(0xFFF0F4F3), // Direct hex value,
// // //       backgroundColor: Colors.black12,
// // //       body: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           SafeArea(
// // //             child: Image.asset(
// // //               'assets/task3.png',
// // //               width: 700,
// // //               height: 350,
// // //             ),
// // //           ),
// // //           SizedBox(height: 10),
// // //
// // //           // Text part with shadow
// // //           Padding(
// // //             padding: EdgeInsets.fromLTRB(30, 8, 30, 8),
// // //             child: Text(
// // //               "Gets things with TODs",
// // //               style: TextStyle(
// // //                 fontWeight: FontWeight.bold,
// // //                 fontSize: 22,
// // //                 letterSpacing: 1,
// // //                 color: Colors.white,
// // //                 shadows: [
// // //                   Shadow(
// // //                     color: Colors.black.withOpacity(0.3), // Shadow color
// // //                     offset: Offset(2, 2), // Shadow position (x, y)
// // //                     blurRadius: 4, // Blur radius for the shadow
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //
// // //           // Paragraph text
// // //           Padding(
// // //             padding: EdgeInsets.fromLTRB(30, 14, 30, 8),
// // //             child: Text(
// // //               "Stay organized, focused, and productive with our Task Management App. "
// // //                   "Effortlessly create, track, and manage your daily tasks—all in one place. "
// // //                   "Whether you're managing personal to-dos or professional goals, this app helps you stay on top of what matters most.",
// // //               textAlign: TextAlign.center,
// // //               style: TextStyle(
// // //                   fontSize: 14,
// // //                   color: Colors.white
// // //               ),
// // //             ),
// // //           ),
// // //
// // //           SizedBox(height: 56),
// // //
// // //           // GestureDetector wrapped around the Container
// // //           GestureDetector(
// // //             onTap: () => Navigator.pushReplacement(
// // //                 context,
// // //                 MaterialPageRoute(builder: (context) => LoginPage())
// // //             ),
// // //             child: Container(
// // //               decoration: BoxDecoration(
// // //                 borderRadius: BorderRadius.circular(9),
// // //                 color: Color(0xFFF50C2C9),  // Corrected color code
// // //               ),
// // //               padding: EdgeInsets.fromLTRB(125, 20, 125, 20),
// // //               child: Text(
// // //                 "Get Started",
// // //                 style: TextStyle(
// // //                   color: Colors.white,
// // //                   fontSize: 16,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
