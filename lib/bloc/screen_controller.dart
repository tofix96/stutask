// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/auth_providers.dart'
    as custom_auth; // Alias dla AuthProvider
import 'package:provider/provider.dart';
import 'package:stutask/screens/home.dart';
import 'package:stutask/screens/register_screen.dart';
import 'package:stutask/screens/user_info_screen.dart';
import 'package:stutask/screens/application_screen.dart';

class ScreenController {
  Future<void> loginUser(
      BuildContext context, String email, String password) async {
    try {
      final authProvider =
          Provider.of<custom_auth.AuthProvider>(context, listen: false);
      User? user = await authProvider.loginUser(email, password);

      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('D_Users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          // Użytkownik ma już dane, przejdź do ekranu głównego
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: user,
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserInfoScreen(),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  void navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void navigateToHome(BuildContext context, User? user,
      {bool showEmployerTasks = false}) {
    print('show: $showEmployerTasks');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HomePage(user: user, showEmployerTasks: showEmployerTasks),
      ),
    );
  }

  void navigateToTaskDetail(BuildContext context, String taskId) {
    Navigator.pushNamed(
      context,
      '/task-detail',
      arguments: {'taskId': taskId},
    );
  }

  void navigateToApplicationsScreen(BuildContext context, String taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationsScreen(taskId: taskId),
      ),
    );
  }

  void navigateToChatOverview(BuildContext context) {
    Navigator.pushNamed(context, '/chat-overview');
  }

  void navigateToChatScreen(BuildContext context, String chatId) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'chatId': chatId,
      },
    );
  }
}
