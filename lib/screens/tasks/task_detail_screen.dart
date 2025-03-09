import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stutask/bloc/task_service.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:stutask/models/task.dart';
import 'package:stutask/models/user.dart';
import 'package:stutask/widgets/detail_row.dart';
import 'package:stutask/widgets/assigned_user_widget.dart';
import 'package:stutask/widgets/widget_style.dart';
import 'package:stutask/bloc/screen_controller.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  TaskDetailScreenState createState() => TaskDetailScreenState();
}

class TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<Task> taskDetails;
  late String taskId;
  final ScreenController screenController = ScreenController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    taskId = arguments['taskId'];
    final taskService = Provider.of<TaskService>(context, listen: false);
    taskDetails = taskService.getTaskDetails(taskId);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String taskId = arguments['taskId'];
    final taskService = Provider.of<TaskService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);

    return FutureBuilder<Task>(
      future: taskDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Nie znaleziono zadania.'));
        }

        final task = snapshot.data!;

        return FutureBuilder<UserModel>(
          future: userService.getCurrentUser(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!userSnapshot.hasData) {
              return const Center(
                  child: Text('Nie znaleziono danych użytkownika.'));
            }
            final currentUser = userSnapshot.data!;
            return Scaffold(
              appBar: GradientAppBar(title: ('Szczegóły zadania')),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          task.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DetailRow(
                                  label: 'Cena:', value: '${task.price} PLN'),
                              DetailRow(
                                  label: 'Kategoria:', value: task.category),
                              DetailRow(label: 'Czas:', value: task.time),
                              DetailRow(label: 'Miasto:', value: task.city),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (task.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            task.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Center(
                          child: Text(
                            'Brak zdjęcia',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Opis:',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      if (task.assignedUserId != null)
                        FutureBuilder<UserModel?>(
                          future:
                              userService.getUserDetails(task.assignedUserId!),
                          builder: (context, assignedUserSnapshot) {
                            if (assignedUserSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (!assignedUserSnapshot.hasData) {
                              return const Text(
                                  'Brak przypisanego pracownika.');
                            }

                            final assignedUser = assignedUserSnapshot.data!;

                            return FutureBuilder<UserModel>(
                              future: userService.getCurrentUser(),
                              builder: (context, currentUserSnapshot) {
                                if (currentUserSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (!currentUserSnapshot.hasData) {
                                  return const Text(
                                      'Nie można zweryfikować użytkownika.');
                                }

                                final currentUser = currentUserSnapshot.data!;

                                if (currentUser.id == task.creatorId) {
                                  return AssignedUserWidget(
                                    assignedUser: assignedUser,
                                    taskId: taskId,
                                    onSubmitReview: (reviewText, rating) {
                                      taskService.submitReview(
                                        taskId: taskId,
                                        assignedUserId: task.assignedUserId!,
                                        reviewText: reviewText,
                                        rating: rating,
                                      );
                                    },
                                  );
                                } else {
                                  return const Text(
                                    'Zadanie zostało już przypisane.',
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }
                              },
                            );
                          },
                        )
                      else
                        Column(
                          children: [
                            if (currentUser.accountType == 'Pracownik')
                              FutureBuilder(
                                future: taskService.hasUserApplied(
                                    taskId, currentUser.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  final hasApplied = snapshot.data ?? false;

                                  return ElevatedButton(
                                    onPressed: hasApplied
                                        ? null
                                        : () => _applyForTask(context, taskId),
                                    child: Text(hasApplied
                                        ? 'Już aplikowano'
                                        : 'Aplikuj'),
                                  );
                                },
                              ),
                            if (currentUser.accountType == 'Pracodawca' &&
                                task.creatorId == currentUser.id)
                              ElevatedButton(
                                onPressed: () {
                                  screenController.navigateToApplicationsScreen(
                                      context, taskId);
                                },
                                child: const Text('Zobacz aplikacje'),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _applyForTask(BuildContext context, String taskId) async {
    final taskService = Provider.of<TaskService>(context, listen: false);

    await taskService.applyForTask(taskId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zgłoszono aplikację do zadania.')),
    );

    setState(() {
      final taskService = Provider.of<TaskService>(context, listen: false);
      taskDetails = taskService.getTaskDetails(taskId);
    });
  }
}
