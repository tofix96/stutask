import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stutask/bloc/task_service.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:stutask/models/task.dart';
import 'package:stutask/models/user.dart';
import 'package:stutask/widgets/detail_row.dart';
import 'package:stutask/widgets/assigned_user_widget.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String taskId = arguments['taskId'];
    final taskService = Provider.of<TaskService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);

    return FutureBuilder<Task>(
      future: taskService.getTaskDetails(taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Nie znaleziono zadania.'));
        }

        final task = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text('Szczegóły zadania')),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nazwa zadania
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

                  // Szczegóły
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
                          DetailRow(label: 'Cena:', value: '${task.price} PLN'),
                          DetailRow(label: 'Kategoria:', value: task.category),
                          DetailRow(label: 'Czas:', value: task.time),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Zdjęcie
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

                  // Opis
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

                  // Przypisany użytkownik
                  if (task.assignedUserId != null)
                    FutureBuilder<UserModel?>(
                      future: userService.getUserDetails(task.assignedUserId!),
                      builder: (context, assignedUserSnapshot) {
                        if (assignedUserSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!assignedUserSnapshot.hasData) {
                          return const Text('Brak przypisanego pracownika.');
                        }

                        final assignedUser = assignedUserSnapshot.data!;
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
                      },
                    )
                  else
                    const Text('Brak przypisanego pracownika.'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
