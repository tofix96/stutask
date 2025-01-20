import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/widgets/widget_style.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _authService = FirebaseAuth.instance;

  void _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę podać adres e-mail')),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('E-mail z linkiem resetującym hasło został wysłany')),
      );
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBody(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  iconSize: 36,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  'Przypomnienie hasła',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Podaj swój adres e-mail, aby otrzymać link do resetu hasła.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email, color: Colors.white),
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Wyślij link resetujący',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
