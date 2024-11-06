import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instancja FirebaseAuth
  String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
    notifyListeners(); // Powiadamia o zmianie stanu
  }

  // Metoda rejestracji użytkownika
  Future<void> registerUser(
      BuildContext context, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      // Sprawdź, czy pola email i hasło są puste
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      User? user = await _signUpWithEmailAndPassword(email, password);
      if (user != null) {
        setToken(await user.getIdToken()); // Ustaw token po rejestracji
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context); // Powrót do ekranu logowania
      }
    } catch (e) {
      // Obsłuż błąd Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  // Rejestracja z email i hasłem
  Future<User?> _signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      String? token = await userCredential.user?.getIdToken();
      setToken(token); // Ustaw token po zalogowaniu
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }
}
