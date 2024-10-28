import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/user_service.dart';

//TEN EKRAN JEST OD PIERWSZEGO URUCHOMIENIA

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _accountTypeController = TextEditingController();
  final _ageController = TextEditingController();
  final UserService _userService = UserService(); // Instancja UserService

  // Funkcja zapisująca informacje o użytkowniku
  Future<void> _saveUserInfo() async {
    await _userService.saveUserInfo(
      bio: _bioController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      accountType: _accountTypeController.text,
      age: _ageController.text,
    );

    // Przekierowanie na ekran główny po zapisaniu danych
    Navigator.pushReplacementNamed(context, '/home',
        arguments: FirebaseAuth.instance.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzupełnij swoje dane'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź bio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Imię'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź imię';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Nazwisko'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź nazwisko';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _accountTypeController.text.isNotEmpty
                      ? _accountTypeController.text
                      : null,
                  decoration: const InputDecoration(labelText: 'Typ konta'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Pracownik', child: Text('Pracownik')),
                    DropdownMenuItem(
                        value: 'Pracodawca', child: Text('Pracodawca')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _accountTypeController.text = value ??
                          ''; // Przypisanie wybranej wartości do kontrolera
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wybierz typ konta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Wiek'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź wiek';
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
                  child: const Text('Zapisz dane'),
                ),
              ],
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
