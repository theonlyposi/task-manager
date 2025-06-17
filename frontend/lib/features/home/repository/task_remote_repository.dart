import 'dart:convert';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TaskRemoteRepository {
  final taskLocalRepository = TaskLocalRepository();

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String hexColor,
    required String token,
    required String uid,
    required DateTime dueAt,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/tasks"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'hexColor': hexColor,
          'dueAt': dueAt.toIso8601String(),
        }),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      final task = TaskModel.fromJson(res.body);
      await taskLocalRepository.insertTask(task);
      return task;
    } catch (e) {
      final task = TaskModel(
        id: const Uuid().v6(),
        uid: uid,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dueAt: dueAt,
        color: hexToRgb(hexColor),
        isSynced: 0,
      );
      await taskLocalRepository.insertTask(task);
      return task;
    }
  }

  Future<List<TaskModel>> getTasks({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("${Constants.backendUri}/tasks"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final data = jsonDecode(res.body) as List;
      final tasks = data.map((e) => TaskModel.fromMap(e)).toList();

      await taskLocalRepository.clearAllTasks();
      await taskLocalRepository.insertTasks(tasks);

      return tasks;
    } catch (e) {
      // Return from local DB as fallback
      final tasks = await taskLocalRepository.getTasks();
      return tasks;
    }
  }

  Future<List<TaskModel>> getTasksByDate({
    required String token,
    required DateTime date,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final res = await http.get(
        Uri.parse("${Constants.backendUri}/tasks/by-date?date=$dateStr"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final data = jsonDecode(res.body) as List;
      return data.map((e) => TaskModel.fromMap(e)).toList();
    } catch (e) {
      print('❌ Error in getTasksByDate: $e');
      return [];
    }
  }

  Future<bool> syncTasks({
    required String token,
    required List<TaskModel> tasks,
  }) async {
    try {
      final taskListInMap = tasks.map((task) => task.toMap()).toList();

      final res = await http.post(
        Uri.parse("${Constants.backendUri}/tasks/sync"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(taskListInMap),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return true;
    } catch (e) {
      print("❌ Error syncing tasks: $e");
      return false;
    }
  }

  Future<void> deleteTask(String taskId, String token) async {
    final res = await http.delete(
      Uri.parse("${Constants.backendUri}/tasks/$taskId"),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );

    if (res.statusCode != 200) {
      try {
        throw jsonDecode(res.body)['error'];
      } catch (_) {
        throw 'Failed to delete task. Status: ${res.statusCode}';
      }
    }

    // ✅ Always delete locally
    await taskLocalRepository.deleteTask(taskId);
  }

  Future<void> updateTask(TaskModel task, String token) async {
    final res = await http.put(
      Uri.parse("${Constants.backendUri}/tasks/${task.id}"),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'hexColor': rgbToHex(task.color),
        'dueAt': task.dueAt.toIso8601String(),
      }),
    );

    if (res.statusCode != 200) {
      throw jsonDecode(res.body)['error'];
    }

    // ✅ Update locally
    await taskLocalRepository.updateTask(task);
  }
}
