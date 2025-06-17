import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/features/home/repository/task_remote_repository.dart';
import 'package:frontend/models/task_model.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/constants.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial());

  final taskRemoteRepository = TaskRemoteRepository();
  final taskLocalRepository = TaskLocalRepository();

  Future<void> createNewTask({
    required String title,
    required String description,
    required Color color,
    required String token,
    required String uid,
    required DateTime dueAt,
  }) async {
    try {
      emit(TasksLoading());

      final taskModel = await taskRemoteRepository.createTask(
        uid: uid,
        title: title,
        description: description,
        hexColor: rgbToHex(color),
        token: token,
        dueAt: dueAt,
      );

      await taskLocalRepository.insertTask(taskModel);
      emit(AddNewTaskSuccess(taskModel));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> getAllTasks({required String token}) async {
    try {
      emit(TasksLoading());
      final tasks = await taskRemoteRepository.getTasks(token: token);
      emit(GetTasksSuccess(tasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> syncTasks(String token) async {
    final unsyncedTasks = await taskLocalRepository.getUnsyncedTasks();
    if (unsyncedTasks.isEmpty) return;

    final isSynced = await taskRemoteRepository.syncTasks(
      token: token,
      tasks: unsyncedTasks,
    );

    if (isSynced) {
      for (final task in unsyncedTasks) {
        taskLocalRepository.updateRowValue(task.id, 1);
      }
    }
  }

// task_remote_repository.dart
  Future<void> deleteTask(String taskId, String token) async {
    final response = await http.delete(
      Uri.parse('${Constants.backendUri}/tasks/$taskId'), // ✅ Ensure the taskId is in the URL
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task: ${response.statusCode} - ${response.body}');
    }
  }


  Future<void> updateTask(TaskModel task, String token) async {
    try {
      emit(TasksLoading());
      await taskRemoteRepository.updateTask(task, token);
      await getAllTasks(token: token);
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> editTask({
    required String taskId,
    required String title,
    required String description,
    required Color color,
    required String token,
    required DateTime dueAt,
  }) async {
    try {
      emit(TasksLoading());

      final updatedTask = TaskModel(
        id: taskId,
        title: title,
        description: description,
        color: color,
        dueAt: dueAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        uid: "",
        isSynced: 1, // ✅ Add this if required (since it's a required field in your model)
      );


      await taskRemoteRepository.updateTask(updatedTask, token);
      emit(EditTaskSuccess(updatedTask));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
