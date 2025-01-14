import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stutask/bloc/screen_controller.dart';
import 'package:stutask/main.dart';
import 'package:stutask/models/task.dart';

class TaskService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
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

  Future<void> assignUserToTask(String taskId, String userId) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'assignedUserId': userId,
    });
  }

  Future<bool> hasUserApplied(String taskId, String userId) async {
    final querySnapshot = await _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> applyForTask(String taskId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);
    await taskRef.collection('applications').doc(currentUser.uid).set({
      'userId': currentUser.uid,
      'appliedAt': Timestamp.now(),
    });
  }

  Future<void> startChat(
      String taskId, String userId, String employerId) async {
    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc('$taskId-$userId');

    final chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists) {
      await chatRef.set({
        'taskId': taskId,
        'workerId': userId,
        'employerId': employerId,
        'createdAt': Timestamp.now(),
      });
    }
    _screenController.navigateToChatScreen(
        navigatorKey.currentState!.context, chatRef.id, taskId);
  }

  Future<Task> getTaskDetails(String taskId) async {
    final taskSnapshot = await _firestore.collection('tasks').doc(taskId).get();
    if (!taskSnapshot.exists) throw Exception('Task not found');
    return Task.fromFirestore(taskSnapshot.id, taskSnapshot.data()!);
  }

  Future<void> submitReview({
    required String taskId,
    required String assignedUserId,
    required String reviewText,
    required int rating,
  }) async {
    final userRef = _firestore.collection('D_Users').doc(assignedUserId);

    await userRef.collection('reviews').add({
      'taskId': taskId,
      'review': reviewText,
      'rating': rating,
      'timestamp': Timestamp.now(),
    });

    await _firestore.collection('tasks').doc(taskId).update({
      'completed': true,
      'completionTimestamp': Timestamp.now(),
    });
  }

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
        'createdAt': Timestamp.now(),
        'admin_accept': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zadanie zostało utworzone')),
      );

      _screenController.navigateToHome(context, user);
    }
  }
}
