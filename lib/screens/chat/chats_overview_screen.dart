import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/screen_controller.dart';
import 'package:stutask/main.dart';

class ChatOverviewScreen extends StatelessWidget {
  ChatOverviewScreen({super.key});
  final screenController = ScreenController();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Użytkownik niezalogowany.'));
    }

    final chatStream = FirebaseFirestore.instance
        .collection('chats')
        .where('employerId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((employerSnapshot) async {
      final workerChats = await FirebaseFirestore.instance
          .collection('chats')
          .where('workerId', isEqualTo: user.uid)
          .get();

      final allChats = [
        ...employerSnapshot.docs,
        ...workerChats.docs,
      ].toSet();

      return allChats.toList();
    });

    return Scaffold(
      appBar: GradientAppBar(title: 'Lista chatów'),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: chatStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak aktywnych czatów.'));
          }

          final chats = snapshot.data!;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat.id;
              final chatData = chat.data() as Map<String, dynamic>;
              final taskId = chatData['taskId'];
              final workerId = chatData['workerId'];
              final employerId = chatData['employerId'];
              final isEmployer = user.uid == employerId;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(taskId)
                    .get(),
                builder: (context, taskSnapshot) {
                  if (taskSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Ładowanie...'),
                    );
                  }

                  if (!taskSnapshot.hasData || !taskSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('Nie znaleziono zadania'),
                    );
                  }

                  final taskData =
                      taskSnapshot.data!.data() as Map<String, dynamic>;
                  final taskName = taskData['Nazwa'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('D_Users')
                        .doc(isEmployer ? workerId : employerId)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Ładowanie...'),
                        );
                      }

                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const ListTile(
                          title: Text('Nie znaleziono użytkownika'),
                        );
                      }

                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      final userName =
                          '${userData['Imię']} ${userData['Nazwisko']}';

                      return ListTile(
                        title: Text(userName),
                        subtitle: Text('Zadanie: $taskName'),
                        trailing: const Icon(Icons.chat),
                        onTap: () {
                          screenController.navigateToChatScreen(
                              context, chatId);
                        },
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
