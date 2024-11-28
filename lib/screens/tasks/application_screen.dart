import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/task_service.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:stutask/models/user.dart';
import 'package:stutask/models/review.dart';
import 'package:stutask/widgets/widget_style.dart';

class ApplicationsScreen extends StatelessWidget {
  final String taskId;

  const ApplicationsScreen({required this.taskId, super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context, listen: false);
    final taskService = Provider.of<TaskService>(context, listen: false);

    return Scaffold(
      appBar: GradientAppBar(title: 'Lista aplikujących'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .collection('applications')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Brak aplikacji do wyświetlenia.'));
          }

          final applications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final userId = applications[index]['userId'];

              return FutureBuilder<UserModel>(
                future: userService.getUserDetails(userId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Nie znaleziono użytkownika'),
                    );
                  }

                  final user = userSnapshot.data!;

                  return FutureBuilder<List<Review>>(
                    future: userService.getUserReviews(userId),
                    builder: (context, reviewSnapshot) {
                      double averageRating = 0.0;
                      if (reviewSnapshot.hasData &&
                          reviewSnapshot.data!.isNotEmpty) {
                        final reviews = reviewSnapshot.data!;
                        averageRating = reviews
                                .map((review) => review.rating)
                                .reduce((a, b) => a + b) /
                            reviews.length;
                      }

                      return ListTile(
                        title: Text('${user.firstName} ${user.lastName}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wiek: ${user.age}'),
                            Text(
                                'Średnia ocena: ${averageRating.toStringAsFixed(1)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => taskService
                                  .assignUserToTask(taskId, userId)
                                  .then((_) => Navigator.pop(context)),
                              child: const Text('Przypisz'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => taskService.startChat(
                                taskId,
                                userId,
                                FirebaseAuth.instance.currentUser!.uid,
                              ),
                              child: const Text('Chat'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
