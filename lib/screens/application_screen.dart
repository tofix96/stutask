import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/screens/chat_screen.dart';

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

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('D_Users')
                        .doc(
                            userId) // Pobieramy dokument użytkownika o odpowiednim userId
                        .collection(
                            'reviews') // Przechodzimy do podkolekcji reviews
                        .get(),
                    builder: (context, reviewSnapshot) {
                      if (reviewSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      double averageRating = 0.0;
                      String opinionText = 'Brak opinii';

                      if (reviewSnapshot.hasData &&
                          reviewSnapshot.data!.docs.isNotEmpty) {
                        final reviews = reviewSnapshot.data!.docs;
                        final totalRating = reviews.fold(
                          0.0,
                          (sum, review) =>
                              sum + (review['rating'] as num).toDouble(),
                        );
                        averageRating = totalRating / reviews.length;
                        opinionText =
                            'Średnia ocena: ${averageRating.toStringAsFixed(1)}';
                        print('Średnia ocena dla użytkownika: $averageRating');
                      } else {
                        print('Brak opinii dla użytkownika o ID: $userId');
                      }

                      return ListTile(
                        title: Text('$firstName $lastName'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wiek: $age'),
                            Text('Opinia: $opinionText'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  _assignUserToTask(context, taskId, userId),
                              child: const Text('Przypisz'),
                            ),
                            const SizedBox(
                                width: 8), // Odstęp między przyciskami
                            ElevatedButton(
                              onPressed: () =>
                                  _startChat(context, taskId, userId),
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

  void _assignUserToTask(
      BuildContext context, String taskId, String userId) async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);

    await taskRef.update({
      'assignedUserId': userId, // Przypisanie użytkownika do zadania
    });

    Navigator.pop(context); // Cofnięcie do poprzedniego ekranu po przypisaniu
  }

  Future<void> _startChat(
      BuildContext context, String taskId, String userId) async {
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc('$taskId-$userId');

    final chatSnapshot = await chatRef.get();

    // Jeśli chat jeszcze nie istnieje, zainicjujemy nowy
    if (!chatSnapshot.exists) {
      await chatRef.set({
        'taskId': taskId,
        'workerId': userId,
        'employerId': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': Timestamp.now(),
      });
    }

    // Przejdź do ekranu chatu (trzeba mieć już przygotowany ekran ChatScreen)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chatRef.id),
      ),
    );
  }
}
