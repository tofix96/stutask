import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/screen_controller.dart';

class ChatOverviewScreen extends StatelessWidget {
  ChatOverviewScreen({super.key});
  final screenController = ScreenController();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Użytkownik niezalogowany.'));
    }

    // Stream to fetch chats where user is either employer or worker
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
      ].toSet(); // Merge results and remove duplicates

      return allChats.toList();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista czatów'),
      ),
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
              final chatId = chat.id; // Pobierz ID dokumentu (chatId)
              final chatData = chat.data() as Map<String, dynamic>;
              final taskId = chatData['taskId'];
              final workerId = chatData['workerId'];
              final employerId = chatData['employerId'];

              // Determine if the user is the employer or worker
              final isEmployer = user.uid == employerId;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('D_Users')
                    .doc(isEmployer ? workerId : employerId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
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
                    subtitle: Text('ID zadania: $taskId'),
                    trailing: const Icon(Icons.chat),
                    onTap: () {
                      screenController.navigateToChatScreen(context, chatId);
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
