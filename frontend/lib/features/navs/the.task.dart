import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/tasks_cubit.dart';
import 'package:frontend/features/home/pages/add_new_task_page.dart';
import 'package:frontend/features/home/widgets/date_selector.dart';
import 'package:frontend/features/home/widgets/task_card.dart';
import 'package:frontend/models/task_model.dart';
import 'package:intl/intl.dart';

class TheTask extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
    builder: (context) => const TheTask(),
  );
  const TheTask({super.key});

  @override
  State<TheTask> createState() => _TheTaskState();
}

class _TheTaskState extends State<TheTask> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthLoggedIn) {
      final token = authState.user.token;
      context.read<TasksCubit>().getAllTasks(token: token);

      Connectivity().onConnectivityChanged.listen((data) async {
        if (data.contains(ConnectivityResult.wifi)) {
          if (!mounted) return;
          await context.read<TasksCubit>().syncTasks(token);
        }
      });
    }
  }

  void _deleteTask(String taskId) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthLoggedIn) {
      final token = authState.user.token;
      context.read<TasksCubit>().deleteTask(taskId, token);
      // context.read<TasksCubit>().deleteTask(token, taskId);
    }
  }

  void _editTask(TaskModel task) async {
    final updated = await Navigator.push(
      context,
      AddNewTaskPage.route(task: task),
    );

    if (updated == true) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthLoggedIn) {
        final token = authState.user.token;
        context.read<TasksCubit>().getAllTasks(token: token);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        actions: [
          IconButton(
            onPressed: () async {
              final added = await Navigator.push(
                context,
                AddNewTaskPage.route(),
              );
              if (added == true) {
                final authState = context.read<AuthCubit>().state;
                if (authState is AuthLoggedIn) {
                  final token = authState.user.token;
                  context.read<TasksCubit>().getAllTasks(token: token);
                }
              }
            },
            icon: const Icon(CupertinoIcons.add),
          )
        ],
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TasksError) {
            return Center(child: Text(state.error));
          }

          if (state is GetTasksSuccess) {
            final tasks = state.tasks.where((task) {
              final taskDate = task.dueAt;
              return taskDate.year == selectedDate.year &&
                  taskDate.month == selectedDate.month &&
                  taskDate.day == selectedDate.day;
            }).toList();

            return Column(
              children: [
                DateSelector(
                  selectedDate: selectedDate,
                  onTap: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(child: Text("No tasks for this day."))
                      : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: Key(task.id),
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          child:
                          const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            _editTask(task);
                            return false;
                          } else if (direction ==
                              DismissDirection.endToStart) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: const Text(
                                    "Are you sure you want to delete this task?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              _deleteTask(task.id);
                              return true;
                            }
                          }
                          return false;
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TaskCard(
                                color: task.color,
                                headerText: task.title,
                                descriptionText: task.description,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: strengthenColor(task.color, 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat.jm().format(task.dueAt),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
