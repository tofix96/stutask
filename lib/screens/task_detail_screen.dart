import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/screen_controller.dart';

class TaskDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String taskId = arguments['taskId'];
    final User? user = FirebaseAuth.instance.currentUser;
    final ScreenController _screenController = ScreenController();

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
                    if (assignedUserId != null) {
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
                          final assignedUserName =
                              '${assignedUserData['Imię']} ${assignedUserData['Nazwisko']}';

                          return Text('Przypisano do: $assignedUserName');
                        },
                      );
                    }

                    return accountType == 'Pracownik'
                        ? ElevatedButton(
                            onPressed: () => _applyForTask(taskId, userId),
                            child: const Text('Aplikuj'),
                          )
                        : accountType == 'Pracodawca' &&
                                taskData['userId'] == userId
                            ? ElevatedButton(
                                onPressed: () {
                                  _screenController
                                      .navigateToApplicationsScreen(
                                          context, taskId);
                                },
                                child: const Text('Zobacz aplikacje'),
                              )
                            : const SizedBox();
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
