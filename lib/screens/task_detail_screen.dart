import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/screen_controller.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String taskId = arguments['taskId'];
    final User? user = FirebaseAuth.instance.currentUser;
    final ScreenController screenController = ScreenController();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('tasks').doc(taskId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Nie znaleziono zadania.'));
        }

        final taskData = snapshot.data!.data() as Map<String, dynamic>;
        final assignedUserId = taskData['assignedUserId'];
        final complated = taskData['completed'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Szczegóły zadania'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nazwa: ${taskData['Nazwa']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Opis: ${taskData['Opis']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Cena: ${taskData['Cena']} PLN',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kategoria: ${taskData['Kategoria']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Czas: ${taskData['Czas']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                taskData['zdjecie'] != null
                    ? Image.network(taskData['zdjecie'])
                    : const Text('Brak zdjęcia'),
                const SizedBox(height: 20),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('D_Users')
                      .doc(user?.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const Text('Brak danych użytkownika.');
                    }

                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    final String accountType = userData['Typ_konta'];
                    final String userId = user?.uid ?? '';

                    // Sprawdź, czy jest przypisany pracownik
                    if (assignedUserId != null && complated != true) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('D_Users')
                            .doc(assignedUserId)
                            .get(),
                        builder: (context, assignedUserSnapshot) {
                          if (assignedUserSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (!assignedUserSnapshot.hasData ||
                              !assignedUserSnapshot.data!.exists) {
                            return const Text('Brak przypisanego pracownika.');
                          }

                          final assignedUserData = assignedUserSnapshot.data!
                              .data() as Map<String, dynamic>;

                          return AssignedUserWidget(
                            assignedUserName:
                                '${assignedUserData['Imię']} ${assignedUserData['Nazwisko']}',
                            assignedUserId:
                                assignedUserId, // Przekaż ID użytkownika
                            taskId: taskId, // Przekaż ID zadania
                            onSubmitReview: (review, rating) {
                              print('Ocena: $rating, Opinia: $review');
                            },
                          );
                        },
                      );
                    }
                    if (complated != true) {
                      return accountType == 'Pracownik'
                          ? ElevatedButton(
                              onPressed: () => _applyForTask(taskId, userId),
                              child: const Text('Aplikuj'),
                            )
                          : accountType == 'Pracodawca' &&
                                  taskData['userId'] == userId
                              ? ElevatedButton(
                                  onPressed: () {
                                    screenController
                                        .navigateToApplicationsScreen(
                                            context, taskId);
                                  },
                                  child: const Text('Zobacz aplikacje'),
                                )
                              : const SizedBox();
                    } else {
                      return const Text('Zadanie zostało wykonane');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyForTask(String taskId, String userId) async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);
    await taskRef.collection('applications').doc(userId).set({
      'userId': userId,
      'appliedAt': Timestamp.now(),
    });
  }
}

class AssignedUserWidget extends StatelessWidget {
  final String assignedUserName;
  final Function(String, int) onSubmitReview;
  final String assignedUserId; // ID przypisanego użytkownika
  final String taskId; // ID zadania

  AssignedUserWidget({
    required this.assignedUserName,
    required this.onSubmitReview,
    required this.assignedUserId,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Przypisano do: $assignedUserName'),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _showReviewDialog(context);
          },
          child: const Text('Wystaw opinię i zakończ zadanie'),
        ),
      ],
    );
  }

  void _showReviewDialog(BuildContext context) {
    final TextEditingController reviewController = TextEditingController();
    int rating = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wystaw opinię'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ocena (od 1 do 5)'),
              DropdownButton<int>(
                value: rating,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    rating = newValue;
                  }
                },
                items: List<DropdownMenuItem<int>>.generate(
                  5,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  labelText: 'Opinia',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String review = reviewController.text;
                if (review.isNotEmpty) {
                  // Zapisz opinię do Firestore
                  await _saveReviewToFirestore(review, rating);

                  // Oznacz zadanie jako zakończone
                  await _markTaskAsCompleted();

                  // Wywołaj funkcję zwrotną
                  onSubmitReview(review, rating);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Zatwierdź'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveReviewToFirestore(String review, int rating) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('D_Users').doc(assignedUserId);

      // Dodaj opinię do danych użytkownika
      await userRef.collection('reviews').add({
        'review': review,
        'rating': rating,
        'timestamp': Timestamp.now(),
      });

      print("Opinia została zapisana pomyślnie!");
    } catch (e) {
      print("Błąd podczas zapisywania opinii: $e");
    }
  }

  Future<void> _markTaskAsCompleted() async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);

    // Oznacz zadanie jako zakończone
    await taskRef.update({
      'completed': true,
      'completionTimestamp': Timestamp.now(),
    });
  }
}
