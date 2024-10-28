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

class ScreenController {
  // Funkcja logowania użytkownika
  Future<void> loginUser(
      BuildContext context, String email, String password) async {
    try {
      final authProvider =
          Provider.of<custom_auth.AuthProvider>(context, listen: false);
      User? user = await authProvider.loginUser(email, password);

      if (user != null) {
        // Sprawdź, czy użytkownik ma już zapisane dane
        final userData = await FirebaseFirestore.instance
            .collection('D_Users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          // Użytkownik ma już dane, przejdź do ekranu głównego
          Navigator.pushReplacementNamed(
            context,
            '/home', // Przekierowanie do HomePage
            arguments: user, // Przekazanie użytkownika jako argument
          );
        } else {
          // Użytkownik nie ma jeszcze danych, przejdź do ekranu wprowadzania informacji
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserInfoScreen(), // Ekran wprowadzania danych
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

  // Metoda do nawigacji do ekranu rejestracji
  void navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void navigateToHome(BuildContext context, User? user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(user: user),
      ),
    );
  }

  void navigateToTaskDetail(BuildContext context, String taskTitle,
      String taskDescription, String price, String? imageUrl) {
    Navigator.pushNamed(
      context,
      '/task-detail',
      arguments: {
        'taskTitle': taskTitle,
        'taskDescription': taskDescription,
        'price': price,
        'imageUrl': imageUrl,
      },
    );
  }
}
