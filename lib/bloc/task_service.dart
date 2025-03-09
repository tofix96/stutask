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
  final ScreenController _screenController = ScreenController();

  Future<List<Map<String, dynamic>>> fetchTasks({
    required String accountType,
    required String userId,
    bool filterByAssignedTasks = false,
    bool filterByCreatedTasks = false,
  }) async {
    QuerySnapshot snapshot;

    try {
      if (accountType == 'Administrator') {
        snapshot = await _firestore
            .collection('tasks')
            .orderBy('admin_accept', descending: false)
            .where('completed', isEqualTo: false)
            .get();
      } else if (filterByAssignedTasks) {
        snapshot = await _firestore
            .collection('tasks')
            .where('assignedUserId', isEqualTo: userId)
            .where('completed', isEqualTo: false)
            .where('admin_accept', isEqualTo: true)
            .get();
      } else if (filterByCreatedTasks) {
        snapshot = await _firestore
            .collection('tasks')
            .where('userId', isEqualTo: userId)
            .where('completed', isEqualTo: false)
            .get();
      } else {
        snapshot = await _firestore
            .collection('tasks')
            .where('completed', isEqualTo: false)
            .where('admin_accept', isEqualTo: true)
            .orderBy('createdAt')
            .get();
      }
      final tasks = snapshot.docs.map((doc) {
        return Task.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      // Konwersja obiektów `Task` na `Map<String, dynamic>`
      return tasks.map((task) {
        return {
          'id': task.id,
          'Nazwa': task.name,
          'Opis': task.description,
          'Cena': task.price,
          'Kategoria': task.category,
          'Czas': task.time,
          'zdjecie': task.imageUrl,
          'userId': task.creatorId,
          'completed': task.completed,
          'admin_accept': task.admin_accept,
          'assignedUserId': task.assignedUserId,
          'Miasto': task.city,
        };
      }).toList();
    } catch (e) {
      throw Exception('Błąd podczas pobierania zadań: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Błąd podczas usuwania zadania: $e');
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update(updates);
    } catch (e) {
      throw Exception('Błąd podczas aktualizacji zadania: $e');
    }
  }

  Future<String?> getUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData =
          await _firestore.collection('D_Users').doc(user.uid).get();
      return userData['Imię'];
    }
    return null;
  }

  Future<File?> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String?> uploadImage(File imageFile) async {
    final ref =
        _storage.ref().child('task_images/${DateTime.now().toString()}');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
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
    print(taskId);
    print(userId);
    print(employerId);
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

  Future<void> addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add({
        'Nazwa': task.name,
        'Opis': task.description,
        'Cena': task.price,
        'Czas': task.time,
        'Kategoria': task.category,
        'zdjecie': task.imageUrl,
        'userId': task.creatorId,
        'completed': task.completed,
        'createdAt': Timestamp.now(),
        'admin_accept': false,
        'Miasto': task.city,
      });
    } catch (e) {
      throw Exception('Błąd podczas dodawania zadania: $e');
    }
  }

  Stream<QuerySnapshot> getApplicationsStream(String taskId) {
    return _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('applications')
        .snapshots();
  }

  Future<void> assignUserToTask(String taskId, String userId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'assignedUserId': userId,
      });
    } catch (e) {
      throw Exception('Błąd podczas przypisywania użytkownika do zadania: $e');
    }
  }

  Future<void> submitReview({
    required String taskId,
    required String assignedUserId,
    required String reviewText,
    required int rating,
  }) async {
    try {
      print("Próba dodania recenzji...");
      print("Wysłane taskId: $taskId");
      print("Wysłane reviewedUserId: $assignedUserId");

      final userRef = _firestore.collection('D_Users').doc(assignedUserId);

      await userRef.collection('reviews').add({
        'taskId': taskId,
        'reviewedUserId': assignedUserId,
        'review': reviewText,
        'rating': rating,
        'timestamp': Timestamp.now(),
      });

      print("Dodano recenzję do Firestore!");

      await _firestore.collection('tasks').doc(taskId).update({
        'completed': true,
        'completionTimestamp': Timestamp.now(),
      });

      print("Zaktualizowano zadanie!");
    } catch (e) {
      print("Błąd w submitReview: $e");
    }
  }

  Future<void> createTaskWithValidation({
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController priceController,
    required TextEditingController timeController,
    required TextEditingController cityController,
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

      // Tworzenie obiektu Task
      final task = Task(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        price: double.parse(priceController.text),
        category: selectedCategory ?? 'Nieznana',
        time: timeController.text,
        imageUrl: imageUrl,
        creatorId: user?.uid ?? '',
        completed: false,
        admin_accept: false,
        assignedUserId: null,
        city: cityController.text,
      );

      try {
        await addTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zadanie zostało utworzone')),
        );
        _screenController.navigateToHome(context, user);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas tworzenia zadania: $e')),
        );
      }
    }
  }
}
