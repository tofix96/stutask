import 'package:flutter/material.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/screen_controller.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    _userService.loadUserDataToControllers(
      bioController: _bioController,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      accountTypeController: _accountTypeController,
      ageController: _ageController,
    );
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
      appBar: AppBar(
        title: const Text('Ustawienia'),
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
                TextFormField(
                  controller: _accountTypeController,
                  decoration: const InputDecoration(labelText: 'Typ konta'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź typ konta';
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
                  child: const Text('Zapisz zmiany'),
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
