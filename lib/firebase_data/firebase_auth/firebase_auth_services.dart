// import 'package:firebase_auth/firebase_auth.dart';

// class FirebaseAuthServices {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<User?> signUpWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       UserCredential credential = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       return credential.user;
//     } catch (e) {
//       print("There is some error");
//     }
//     return null;
//   }
// }
