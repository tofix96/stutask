import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationsScreen extends StatelessWidget {
  final String taskId;

  const ApplicationsScreen({required this.taskId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista aplikujących'),
      ),
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
              final application = applications[index];
              final userId = application['userId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('D_Users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('Nie znaleziono użytkownika'),
                    );
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final String firstName = userData['Imię'] ?? 'Brak imienia';
                  final String lastName =
                      userData['Nazwisko'] ?? 'Brak nazwiska';
                  final String age = userData['Wiek'] ?? 'Nieznany wiek';
                  final String opinion = userData['opinia'] ?? 'Brak opinii';

                  return ListTile(
                    title: Text('$firstName $lastName'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wiek: $age'),
                        Text('Opinia: $opinion'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () =>
                          _assignUserToTask(context, taskId, userId),
                      child: const Text('Przypisz'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _assignUserToTask(
      BuildContext context, String taskId, String userId) async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);

    await taskRef.update({
      'assignedUserId': userId, // Przypisanie użytkownika do zadania
    });

    Navigator.pop(context); // Cofnięcie do poprzedniego ekranu po przypisaniu
  }
}
