// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/auth_providers.dart'
    as custom_auth; // Alias dla AuthProvider
import 'package:provider/provider.dart';
import 'package:stutask/screens/home.dart';
import 'package:stutask/screens/auth/register_screen.dart';
import 'package:stutask/screens/profile/user_info_screen.dart';
import 'package:stutask/screens/tasks/application_screen.dart';
import 'package:stutask/screens/tasks/assigned_tasks_screen.dart';

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

  void navigateToAssignedTasks(
    BuildContext context,
    User user,
    String accountType,
  ) {
    if (accountType == 'Pracownik') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AssignedTasksScreen(
            user: user,
            accountType: 'Pracownik',
          ),
        ),
      );
    } else if (accountType == 'Pracodawca') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AssignedTasksScreen(
            user: user,
            accountType: 'Pracodawca',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nieznany typ konta')),
      );
    }
  }

  void navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void navigateToHome(
    BuildContext context,
    User? user, {
    bool showEmployerTasks = false,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          user: user,
          showEmployerTasks: showEmployerTasks,
          // Przekazanie accountType
        ),
      ),
    );
  }

  void navigatesToHome(BuildContext context, User? user,
      {bool showEmployerTasks = false, String? accountType}) {
    if (user == null) {
      print('Cannot navigate. User is null.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          user: user,
          showEmployerTasks: showEmployerTasks,
        ),
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
