import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Funkcja pobierająca informacje o użytkowniku z Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData =
          await _firestore.collection('D_Users').doc(user.uid).get();
      return userData.data();
    }
    return null;
  }

  Future<void> loadUserDataToControllers({
    required TextEditingController bioController,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController accountTypeController,
    required TextEditingController ageController,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData =
          await _firestore.collection('D_Users').doc(user.uid).get();
      final data = userData.data();
      if (data != null) {
        bioController.text = data['Bio'] ?? '';
        firstNameController.text = data['Imię'] ?? '';
        lastNameController.text = data['Nazwisko'] ?? '';
        accountTypeController.text = data['Typ_konta'] ?? '';
        ageController.text = data['Wiek'] ?? '';
      }
    }
  }

  // Istniejąca funkcja zapisująca informacje o użytkowniku
  Future<void> saveUserInfo({
    required String bio,
    required String firstName,
    required String lastName,
    required String accountType,
    required String age,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;

      await _firestore.collection('D_Users').doc(uid).set({
        'Bio': bio,
        'Imię': firstName,
        'Nazwisko': lastName,
        'Typ_konta': accountType,
        'Wiek': age,
      });
    }
  }
}
