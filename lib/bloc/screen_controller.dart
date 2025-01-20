// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/auth_providers.dart' as custom_auth;
import 'package:provider/provider.dart';
import 'package:stutask/screens/home.dart';
import 'package:stutask/screens/auth/register_screen.dart';
import 'package:stutask/screens/profile/user_info_screen.dart';
import 'package:stutask/screens/tasks/application_screen.dart';
import 'package:stutask/screens/auth/forgot_password.dart';

class ScreenController {
  Future<User?> loginUser(
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
          final userType =
              userData.data()?['Typ_konta']; // Pobranie wartości Typ_konta

          if (userType == 'Administrator') {
            Navigator.pushReplacementNamed(
              context,
              '/admin',
              arguments: user,
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: user,
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserInfoScreen(),
            ),
          );
        }
      }

      return user;
    } catch (e) {
      return null;
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
          builder: (_) => HomePage(
            user: user,
          ),
        ),
      );
    } else if (accountType == 'Pracodawca') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HomePage(
            user: user,
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
        ),
      ),
    );
  }

  void navigatesToHome(BuildContext context, User? user,
      {bool showEmployerTasks = false, String? accountType}) {
    if (user == null) {
      print('Brak użytkownika');
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

  void navigateToForgotPasswordScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
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

  void navigateToChatScreen(
      BuildContext context, String chatId, String taskId) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'chatId': chatId,
        'taskId': taskId,
      },
    );
  }
}
