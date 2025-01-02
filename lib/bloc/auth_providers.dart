import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie pola')),
      );
      return;
    }

    try {
      User? user = await _signUpWithEmailAndPassword(email, password);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Rejestracja powiodła się! Zweryfikuj adres email')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejestracja nie powiodła się ${e.toString()}')),
      );
    }
  }

  // Rejestracja z email i hasłem oraz wysyłanie maila weryfikacyjnego
  Future<User?> _signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      // Tworzenie konta
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Pobranie użytkownika
      User? user = credential.user;

      if (user != null) {
        // Wysłanie e-maila weryfikacyjnego
        await user.sendEmailVerification();
        print("Wysłano e-mail weryfikacyjny.");
      }

      return user;
    } catch (e) {
      print("Błąd podczas rejestracji: $e");
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      // Logowanie użytkownika
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Sprawdzenie, czy e-mail został zweryfikowany
        if (!user.emailVerified) {
          // Wylogowanie i rzucenie wyjątku dla niezweryfikowanego e-maila
          await _auth.signOut();
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'E-mail nie został zweryfikowany.',
          );
        }

        // Pobranie tokena i zapisanie go
        String? token = await user.getIdToken();
        setToken(token);
        return user;
      } else {
        throw FirebaseAuthException(
          code: 'invalid-credentials',
          message: 'Nieprawidłowy email lub hasło.',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Obsługa błędów Firebase
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw FirebaseAuthException(
          code: 'invalid-credentials',
          message: 'Nieprawidłowy email lub hasło.',
        );
      } else {
        rethrow; // Rzucenie innych błędów
      }
    } catch (e) {
      // Rzucenie innych wyjątków
      throw Exception('Unexpected error: $e');
    }
  }
}
