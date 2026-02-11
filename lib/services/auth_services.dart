import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// REGISTER
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// LOGIN
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw "User data not found";
      }

      return userDoc.data() as Map<String, dynamic>;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    }
  }
}
