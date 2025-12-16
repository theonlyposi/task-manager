import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/constants.dart';
import '../../models/task_model.dart';
import '../home/pages/add_new_task_page.dart';

class TheCalender extends StatefulWidget {
  const TheCalender({super.key});

  @override
  State<TheCalender> createState() => _TheCalenderState();
}

class _TheCalenderState extends State<TheCalender> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<TaskModel>> _events = {};
  String _token = "";

  DateTime _getDateKey(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchTasks();
  }

  Future<void> _loadTokenAndFetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token') ?? '';

    if (_token.isNotEmpty) {
      await _fetchTasksForMonth(_focusedDay);
    } else {
      print('Token not found.');
    }
  }

  Future<void> _fetchTasksForMonth(DateTime focusedDay) async {
    final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    final start = firstDay.toIso8601String().split('T').first;
    final end = lastDay.toIso8601String().split('T').first;

    try {
      final res = await http.get(
        Uri.parse('${Constants.backendUri}/tasks/by-range?start=$start&end=$end'),
        headers: {'x-auth-token': _token},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        final Map<DateTime, List<TaskModel>> taskMap = {};

        for (var json in data) {
          final task = TaskModel.fromMap(json);
          final dateKey = _getDateKey(task.dueAt);
          taskMap.putIfAbsent(dateKey, () => []).add(task);
        }

        setState(() {
          _events = taskMap;
        });
      } else {
        print('Fetch failed: ${res.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteTask(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('${Constants.backendUri}/tasks/$id'),
        headers: {'x-auth-token': _token},
      );

      if (res.statusCode == 200) {
        await _fetchTasksForMonth(_focusedDay);
      } else {
        print('Delete failed: ${res.statusCode}');
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasks = _events[_getDateKey(_selectedDay)] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (day, focus) {
              setState(() {
                _selectedDay = day;
                _focusedDay = focus;
              });
            },
            onPageChanged: (focus) {
              _focusedDay = focus;
              _fetchTasksForMonth(focus);
            },
            eventLoader: (day) => _events[_getDateKey(day)] ?? [],
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: selectedTasks.isEmpty
                ? const Center(child: Text("No tasks for this day"))
                : ListView.builder(
              itemCount: selectedTasks.length,
              itemBuilder: (context, index) {
                final task = selectedTasks[index];
                return Dismissible(
                  key: Key(task.id.toString()),
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.green,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await _deleteTask(task.id);
                      return true;
                    } else if (direction == DismissDirection.endToStart) {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNewTaskPage(task: task),
                        ),
                      );

                      if (updated == true) {
                        await _fetchTasksForMonth(_focusedDay);
                      }
                      return false;
                    }
                    return false;
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.task, color: task.color),
                      title: Text(task.title),
                      subtitle: Text(task.description),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewTaskPage()),
          );
          if (added == true) {
            await _fetchTasksForMonth(_focusedDay);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../core/constants/constants.dart';
// import '../../models/task_model.dart';
// import '../home/pages/add_new_task_page.dart';
//
// class TheCalender extends StatefulWidget {
//   const TheCalender({super.key});
//
//   @override
//   State<TheCalender> createState() => _TheCalenderState();
// }
//
// class _TheCalenderState extends State<TheCalender> {
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now();
//   Map<DateTime, List<Map<String, dynamic>>> _events = {};
//   String _token = "";
//
//   DateTime _getDateKey(DateTime date) => DateTime(date.year, date.month, date.day);
//
//   @override
//   void initState() {
//     super.initState();
//     _loadTokenAndFetchTasks();
//   }
//
//   Future<void> _loadTokenAndFetchTasks() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('auth_token') ?? '';
//
//     if (_token.isNotEmpty) {
//       await _fetchTasksForMonth(_focusedDay);
//     } else {
//       print('Token not found.');
//     }
//   }
//
//   Future<void> _fetchTasksForMonth(DateTime focusedDay) async {
//     final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
//     final lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);
//
//     final start = firstDay.toIso8601String().split('T').first;
//     final end = lastDay.toIso8601String().split('T').first;
//
//     try {
//       final res = await http.get(
//         Uri.parse('${Constants.backendUri}/tasks/by-range?start=$start&end=$end'),
//         headers: {'x-auth-token': _token},
//       );
//
//       if (res.statusCode == 200) {
//         final List<dynamic> tasks = json.decode(res.body);
//         final Map<DateTime, List<Map<String, dynamic>>> taskMap = {};
//
//         for (var task in tasks) {
//           DateTime due = DateTime.parse(task['dueAt']);
//           final key = _getDateKey(due);
//           taskMap.putIfAbsent(key, () => []).add(task);
//         }
//
//         setState(() {
//           _events = taskMap;
//         });
//       } else {
//         print('Fetch failed: ${res.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   Future<void> _deleteTask(String id) async {
//     try {
//       final res = await http.delete(
//         Uri.parse('${Constants.backendUri}/tasks/$id'),
//         headers: {'x-auth-token': _token},
//       );
//
//       if (res.statusCode == 200) {
//         await _fetchTasksForMonth(_focusedDay);
//       } else {
//         print('Delete failed: ${res.statusCode}');
//       }
//     } catch (e) {
//       print('Error deleting task: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final selectedTasks = _events[_getDateKey(_selectedDay)] ?? [];
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Calendar')),
//       body: Column(
//         children: [
//           TableCalendar(
//             firstDay: DateTime.utc(2020, 1, 1),
//             lastDay: DateTime.utc(2030, 12, 31),
//             focusedDay: _focusedDay,
//             selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
//             onDaySelected: (day, focus) {
//               setState(() {
//                 _selectedDay = day;
//                 _focusedDay = focus;
//               });
//             },
//             onPageChanged: (focus) {
//               _focusedDay = focus;
//               _fetchTasksForMonth(focus);
//             },
//             eventLoader: (day) => _events[_getDateKey(day)] ?? [],
//             calendarStyle: const CalendarStyle(
//               todayDecoration: BoxDecoration(
//                 color: Colors.blueAccent,
//                 shape: BoxShape.circle,
//               ),
//               selectedDecoration: BoxDecoration(
//                 color: Colors.deepPurple,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: selectedTasks.isEmpty
//                 ? const Center(child: Text("No tasks for this day"))
//                 : ListView.builder(
//               itemCount: selectedTasks.length,
//               itemBuilder: (context, index) {
//                 final task = selectedTasks[index];
//                 return Dismissible(
//                   key: Key(task['id'].toString()),
//                   background: Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.only(left: 20),
//                     color: Colors.red,
//                     child: const Icon(Icons.delete, color: Colors.white),
//                   ),
//                   secondaryBackground: Container(
//                     alignment: Alignment.centerRight,
//                     padding: const EdgeInsets.only(right: 20),
//                     color: Colors.green,
//                     child: const Icon(Icons.edit, color: Colors.white),
//                   ),
//                   confirmDismiss: (direction) async {
//                     if (direction == DismissDirection.startToEnd) {
//                       await _deleteTask(task['id']);
//                       return true;
//                     } else if (direction == DismissDirection.endToStart) {
//                       final updated = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddNewTaskPage(task: TaskModel.fromMap(task)),
//                         ),
//                       );
//
//                       if (updated == true) {
//                         await _fetchTasksForMonth(_focusedDay);
//                       }
//                       return false;
//                     }
//                     return false;
//                   },
//                   child: Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: ListTile(
//                       leading: const Icon(Icons.task),
//                       title: Text(task['title'] ?? 'Untitled'),
//                       subtitle: Text(task['description'] ?? ''),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final added = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddNewTaskPage()),
//           );
//           if (added == true) {
//             await _fetchTasksForMonth(_focusedDay);
//           }
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
