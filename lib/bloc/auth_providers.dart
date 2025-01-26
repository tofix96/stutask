import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<User?> _signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;

      if (user != null) {
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
        if (!user.emailVerified) {
          await _auth.signOut();
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'E-mail nie został zweryfikowany.',
          );
        }

        // String? token = await user.getIdToken();
        // setToken(token);
        return user;
      } else {
        throw FirebaseAuthException(
          code: 'invalid-credentials',
          message: 'Nieprawidłowy email lub hasło.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw FirebaseAuthException(
          code: 'invalid-credentials',
          message: 'Nieprawidłowy email lub hasło.',
        );
      } else {
        rethrow;
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
