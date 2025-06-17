import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:frontend/features/navs/the.task.dart';
import '../auth/cubit/auth_cubit.dart';
import '../home/pages/add_new_task_page.dart';
import 'package:frontend/features/home/cubit/tasks_cubit.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/features/auth/repository/auth_local_repository.dart';

class TheHome extends StatefulWidget {
  const TheHome({super.key});

  @override
  State<TheHome> createState() => _TheHomeState();
}

class _TheHomeState extends State<TheHome> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final savedUser = await AuthLocalRepository().getUser();
    setState(() {
      user = savedUser;
    });

    if (user?.token != null) {
      context.read<TasksCubit>().getAllTasks(token: user!.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF50C2C9),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewTaskPage()),
          );
          if (result == true) {
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthLoggedIn) {
              context.read<TasksCubit>().getAllTasks(token: authState.user.token);
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Top greeting + avatar + notification
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset('assets/mom.jpg', width: 55, height: 55),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, ${user?.name ?? 'User'}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: Theme.of(context).iconTheme.color),
                      onPressed: () {
                        print('Notification icon clicked');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                // Daily Tasks Card
                Card(
                  color: const Color(0xFF50C2C9),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Your daily tasks",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "almost done!",
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TheTask()),
                                  );
                                },
                                icon: const Icon(Icons.visibility, size: 18, color: Colors.white),
                                label: const Text("View Tasks", style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 30, color: Colors.white),
                          onPressed: () => print('More icon clicked'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Today's Tasks header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Tasks",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        // TODO: Implement See All Tasks page or functionality
                      },
                      child: Text(
                        "See all",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                BlocBuilder<TasksCubit, TasksState>(
                  builder: (context, state) {
                    if (state is TasksLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetTasksSuccess) {
                      final today = DateTime.now();
                      final todayTasks = state.tasks.where((task) {
                        final dueDate = task.dueAt;
                        return dueDate.year == today.year &&
                            dueDate.month == today.month &&
                            dueDate.day == today.day;
                      }).toList();

                      if (todayTasks.isEmpty) {
                        return const Center(child: Text("You have no tasks for today."));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayTasks.length,
                        itemBuilder: (context, index) {
                          final task = todayTasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: task.color,
                                child: const Icon(Icons.task, color: Colors.white),
                              ),
                              title: Text(task.title),
                              subtitle: Text(task.description),
                              trailing: Text(DateFormat('hh:mm a').format(task.dueAt)),
                            ),
                          );
                        },
                      );
                    } else if (state is TasksError) {
                      return Center(child: Text("Error: ${state.error}"));
                    } else {
                      return const Center(child: Text("No tasks found."));
                    }
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
