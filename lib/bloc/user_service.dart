import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stutask/models/review.dart';
import 'package:stutask/models/user.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final userSnapshot =
        await _firestore.collection('D_Users').doc(user.uid).get();
    if (!userSnapshot.exists) throw Exception('User data not found');

    return UserModel.fromFirestore(userSnapshot.data()!, user.uid);
  }

  Future<String?> getAccountType(String userId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('D_Users')
          .doc(userId)
          .get();

      return userSnapshot.data()?['Typ_konta'] as String?;
    } catch (e) {
      print('Błąd podczas pobierania typu konta: $e');
      return null;
    }
  }

  Stream<List<DocumentSnapshot>> getChatStream() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    final employerChats = _firestore
        .collection('chats')
        .where('employerId', isEqualTo: user.uid)
        .snapshots();

    final workerChatsFuture = _firestore
        .collection('chats')
        .where('workerId', isEqualTo: user.uid)
        .get();

    return employerChats.asyncMap((employerSnapshot) async {
      final workerChats = await workerChatsFuture;
      // ignore: prefer_collection_literals
      final allChats = [
        ...employerSnapshot.docs,
        ...workerChats.docs,
      ].toSet();

      return allChats.toList();
    });
  }

  static Future<List<Map<String, dynamic>>> fetchReviews() async {
    try {
      final userSnapshots =
          await FirebaseFirestore.instance.collection('D_Users').get();
      final reviews = <Map<String, dynamic>>[];

      for (var userDoc in userSnapshots.docs) {
        final reviewsSnapshot = await FirebaseFirestore.instance
            .collection('D_Users')
            .doc(userDoc.id)
            .collection('reviews')
            .orderBy('timestamp')
            .get();

        for (var reviewDoc in reviewsSnapshot.docs) {
          reviews.add(
              {'id': reviewDoc.id, 'userId': userDoc.id, ...reviewDoc.data()});
        }
      }

      return reviews;
    } catch (e) {
      throw Exception('Błąd podczas pobierania opinii: $e');
    }
  }

  static Future<void> deleteReview(String userId, String reviewId) async {
    try {
      await FirebaseFirestore.instance
          .collection('D_Users')
          .doc(userId)
          .collection('reviews')
          .doc(reviewId)
          .delete();
    } catch (e) {
      throw Exception('Błąd podczas usuwania opinii: $e');
    }
  }

  Future<Map<String, dynamic>?> getChatDetails(DocumentSnapshot chat) async {
    final chatData = chat.data() as Map<String, dynamic>;
    final taskId = chatData['taskId'];
    final workerId = chatData['workerId'];
    final employerId = chatData['employerId'];

    final User? user = _auth.currentUser;
    if (user == null) return null;

    final isEmployer = user.uid == employerId;
    final taskSnapshot = await _firestore.collection('tasks').doc(taskId).get();

    if (!taskSnapshot.exists) {
      return null;
    }

    final taskData = taskSnapshot.data() as Map<String, dynamic>;
    final taskName = taskData['Nazwa'];
    final userSnapshot = await _firestore
        .collection('D_Users')
        .doc(isEmployer ? workerId : employerId)
        .get();

    if (!userSnapshot.exists) {
      return null;
    }

    final userData = userSnapshot.data() as Map<String, dynamic>;
    final userName = '${userData['Imię']} ${userData['Nazwisko']}';

    return {
      'taskName': taskName,
      'userName': userName,
      'taskId': taskId,
    };
  }

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

  Future<UserModel> getUserDetails(String userId) async {
    final userSnapshot =
        await _firestore.collection('D_Users').doc(userId).get();
    if (!userSnapshot.exists) throw Exception('User not found');
    return UserModel.fromFirestore(userSnapshot.data()!, userSnapshot.id);
  }

  Future<List<Review>> getUserReviews(String userId) async {
    final reviewsSnapshot = await _firestore
        .collection('D_Users')
        .doc(userId)
        .collection('reviews')
        .get();

    return reviewsSnapshot.docs
        .map((doc) => Review.fromFirestore(doc.data()))
        .toList();
  }
}
