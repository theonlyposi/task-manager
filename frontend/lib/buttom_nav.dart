import 'package:flutter/material.dart';
import 'package:frontend/features/navs/calender.dart';
import 'package:frontend/features/navs/person.dart';
import 'package:frontend/features/navs/the.task.dart';
import 'package:frontend/features/navs/the_home.dart';

class TheNav extends StatefulWidget {
  const TheNav({super.key});

  @override
  State<TheNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<TheNav> {
  late final List<Widget> pages;
  late final TheHome home;
  late final TheTask task;
  late final TheCalender calender;
  late final Person profile;

  int myIndex = 0;

  @override
  void initState() {
    home = TheHome();
    task = TheTask();
    calender = TheCalender();
    profile = Person();
    pages = [home, task, calender, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.black : Colors.white, // 🔄 Dynamic background
        selectedItemColor: Color(0xFF50C2C9), // Looks good in both themes
        unselectedItemColor: isDark ? Colors.white60 : Colors.black54, // Dynamic text/icon
        iconSize: 30,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Person'),
        ],
      ),
      body: pages[myIndex],
    );
  }
}

//
//
// import 'package:flutter/material.dart';
// import 'package:frontend/features/navs/calender.dart';
// import 'package:frontend/features/navs/person.dart';
// import 'package:frontend/features/navs/the.task.dart';
// import 'package:frontend/features/navs/the_home.dart';
//
//
// class TheNav extends StatefulWidget {
//   const TheNav({super.key});
//
//   @override
//   State<TheNav> createState() => _BottomNavState();
// }
//
// class _BottomNavState extends State<TheNav> {
//
//   late List <Widget> pages;
//   late TheHome home;
//   late  TheTask task;
//   late TheCalender calender;
//   late  Person profile;
//   int myIndex = 0;
//
//
//   @override
//   void initState() {
//     home = TheHome();
//     task = TheTask();
//     calender = TheCalender();
//     profile = Person();
//     pages = [home,task, calender,profile];
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar:BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         backgroundColor: Colors.white,
//         iconSize: 32,
//         selectedItemColor: Colors.blueAccent,
//         onTap: (index) {
//           setState(() {
//             myIndex = index;  // Update selected index
//           });
//         },
//         currentIndex: myIndex,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home, color: Colors.black),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.task, color: Colors.black),
//             label: 'Tasks',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_month, color: Colors.black),
//             label: 'Calendar',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person, color: Colors.black),
//             label: 'Person',
//           ),
//         ],
//       ),
//       body: pages [myIndex],
//
//     );
//   }
// }
