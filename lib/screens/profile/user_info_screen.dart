import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stutask/bloc/user_service.dart';
import 'package:stutask/widgets/widget_style.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  UserInfoScreenState createState() => UserInfoScreenState();
}

class UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _accountTypeController = TextEditingController();
  final _ageController = TextEditingController();
  final UserService _userService = UserService();

  Future<void> _saveUserInfo() async {
    await _userService.saveUserInfo(
      bio: _bioController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      accountType: _accountTypeController.text,
      age: _ageController.text,
    );
    Navigator.pushReplacementNamed(context, '/home',
        arguments: FirebaseAuth.instance.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBody(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Uzpełnij szczegóły o sobie',
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
                const SizedBox(height: 30),
                TextFormField(
                  controller: _bioController,
                  style: const TextStyle(color: Colors.white),
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
                      return 'Enter your bio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'First Name',
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
                      return 'Enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Last Name',
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
                      return 'Enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _accountTypeController.text.isNotEmpty
                      ? _accountTypeController.text
                      : null,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.black54,
                  decoration: InputDecoration(
                    labelText: 'Account Type',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Pracownik', child: Text('Pracownik')),
                    DropdownMenuItem(
                        value: 'Pracodawca', child: Text('Pracodawca')),
                    DropdownMenuItem(
                        value: 'Administrator', child: Text('Administrator')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _accountTypeController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Select account type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Age',
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
                      return 'Enter your age';
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
                      horizontal: 80,
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
