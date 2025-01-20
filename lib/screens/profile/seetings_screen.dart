import 'package:flutter/material.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/screen_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _accountTypeController = TextEditingController();
  final _ageController = TextEditingController();

  final UserService _userService = UserService();
  final ScreenController _screenController = ScreenController();

  @override
  void initState() {
    super.initState();
    _userService
        .loadUserDataToControllers(
      bioController: _bioController,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      accountTypeController: _accountTypeController,
      ageController: _ageController,
    )
        .then((_) {
      setState(
          () {}); // Odśwież ekran, aby załadować wybraną wartość w liście rozwijanej
    });
  }

  Future<void> _saveUserInfo() async {
    await _userService.saveUserInfo(
      bio: _bioController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      accountType: _accountTypeController.text,
      age: _ageController.text,
    );

    _screenController.navigateToHome(
        context, FirebaseAuth.instance.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEF6C00),
              Color(0xFFFFA726),
              Color(0xFFFFC107),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Ustawienia',
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Imię',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Podaj imię';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nazwisko',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Podaj nazwisko';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _ageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Wiek',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Podaj swój wiek';
                      }
                      final age = int.tryParse(value);
                      if (age == null) {
                        return 'Podaj poprawny wiek';
                      }
                      if (age < 16) {
                        return 'Musisz mieć przynajmniej 16 lat';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _bioController,
                    style: const TextStyle(color: Colors.white),
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Powiedz coś o sobie';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveUserInfo();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Zapisz',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _accountTypeController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
