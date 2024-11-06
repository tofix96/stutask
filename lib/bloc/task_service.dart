import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stutask/bloc/screen_controller.dart';

class TaskService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ScreenController _screenController =
      ScreenController(); // Dodaj instancję ScreenController

  // Pobranie imienia użytkownika z Firestore
  Future<String?> getUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData =
          await _firestore.collection('D_Users').doc(user.uid).get();
      return userData['Imię'];
    }
    return null;
  }

  // Funkcja do wybierania zdjęcia z galerii
  Future<File?> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Przesyłanie zdjęcia do Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    final ref =
        _storage.ref().child('task_images/${DateTime.now().toString()}');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Funkcja do tworzenia zadania, obsługująca walidację i przesyłanie zdjęcia
  Future<void> createTaskWithValidation({
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController priceController,
    required TextEditingController timeController,
    String? selectedCategory,
    String? creatorName,
    File? imageFile,
    required BuildContext context,
  }) async {
    if (formKey.currentState!.validate()) {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      final user = _auth.currentUser;
      await _firestore.collection('tasks').add({
        'Nazwa': nameController.text,
        'Opis': descriptionController.text,
        'Cena': double.parse(priceController.text),
        'Czas': timeController.text,
        'Kategoria': selectedCategory,
        'Creator': creatorName ?? 'Nieznany',
        'zdjecie': imageUrl,
        'userId': user?.uid,
        'completed': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zadanie zostało utworzone')),
      );

      _screenController.navigateToHome(
          context, user); // Użycie ScreenController do nawigacji
    }
  }
}
