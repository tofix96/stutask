import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stutask/bloc/screen_controller.dart';
import 'package:stutask/widgets/widget_style.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:provider/provider.dart';

class ChatOverviewScreen extends StatelessWidget {
  ChatOverviewScreen({super.key});
  final screenController = ScreenController();

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context, listen: false);
    final chatStream = userService.getChatStream();

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

              return FutureBuilder<Map<String, dynamic>?>(
                future: UserService().getChatDetails(chat),
                builder: (context, chatDetailsSnapshot) {
                  if (chatDetailsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Ładowanie...'),
                    );
                  }

                  final chatDetails = chatDetailsSnapshot.data;
                  if (chatDetails == null) {
                    return const ListTile(
                      title: Text('Nie znaleziono szczegółów czatu'),
                    );
                  }

                  return ListTile(
                    title: Text(chatDetails['userName']),
                    subtitle: Text('Zadanie: ${chatDetails['taskName']}'),
                    trailing: const Icon(Icons.chat),
                    onTap: () {
                      screenController.navigateToChatScreen(
                          context, chatId, chatDetails['taskId']);
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
