import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/constants.dart';
import '../home/pages/add_new_task_page.dart';

class TheCalender extends StatefulWidget {
  const TheCalender({super.key});

  @override
  State<TheCalender> createState() => _TheCalenderState();
}
class _TheCalenderState extends State<TheCalender> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
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
      print('Token not found. User might not be logged in.');
    }
  }

  Future<void> _fetchTasksForMonth(DateTime focusedDay) async {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    final startDate = firstDayOfMonth.toIso8601String().split('T').first;
    final endDate = lastDayOfMonth.toIso8601String().split('T').first;

    try {
      final response = await http.get(
        Uri.parse('${Constants.backendUri}/tasks/by-range?start=$startDate&end=$endDate'),
        headers: {'x-auth-token': _token},
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasks = json.decode(response.body);

        final Map<DateTime, List<Map<String, dynamic>>> newEvents = {};

        for (var task in tasks) {
          DateTime dueDate = DateTime.parse(task['dueAt']);
          DateTime key = _getDateKey(dueDate);
          newEvents.putIfAbsent(key, () => []);
          newEvents[key]!.add(task);
        }

        setState(() {
          _events = newEvents;
        });
      } else {
        print('Error fetching tasks: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception while fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayKey = _getDateKey(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _fetchTasksForMonth(focusedDay);
            },
            eventLoader: (day) {
              final dayKey = _getDateKey(day);
              return _events[dayKey] ?? [];
            },
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
          const SizedBox(height: 8),
          Expanded(
            child: _events[selectedDayKey] == null || _events[selectedDayKey]!.isEmpty
                ? const Center(child: Text('No tasks for this day.'))
                : ListView.builder(
              itemCount: _events[selectedDayKey]!.length,
              itemBuilder: (context, index) {
                final task = _events[selectedDayKey]![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.task_alt, color: Colors.deepPurple),
                    title: Text(task['title'] ?? 'No Title'),
                    subtitle: Text(task['description'] ?? 'No Description'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewTaskPage()),
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
