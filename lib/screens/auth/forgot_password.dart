import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/widgets/widget_style.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _authService = FirebaseAuth.instance;

  void _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proszę podać adres e-mail')),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(
          email: email); // Poprawna metoda
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('E-mail z linkiem resetującym hasło został wysłany')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: ('Przypomnienie hasła')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Podaj swój adres e-mail, aby otrzymać link do resetu hasła.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendPasswordResetEmail,
              child: Text('Wyślij link resetujący'),
            ),
          ],
        ),
      ),
    );
  }
}
