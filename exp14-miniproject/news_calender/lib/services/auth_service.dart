import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Admins ---
  static const adminEmails = [
    "appdevkrishtari@gmail.com",
    "vpg@gmail.com",
  ];

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> ensureAnonymous() async {
    if (_auth.currentUser == null) {
      try {
        final cred = await _auth.signInAnonymously();
        return cred.user;
      } catch (_) {
        return null;
      }
    }
    return _auth.currentUser;
  }

  // ---------------- SIGN UP ----------------
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final u = cred.user;
      if (u != null) {
        final isAdmin = adminEmails.contains(email);

        // Fire-and-forget — DOES NOT BLOCK LOGIN
        _db.collection('users').doc(u.uid).set({
          'email': email,
          'role': isAdmin ? 'admin' : 'logged_in',
          'isVIP': isAdmin,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return u;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ---------------- SIGN IN ----------------
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final u = cred.user;
      if (u != null) {
        final isAdmin = adminEmails.contains(email);

        // Background update — no waiting
        _db.collection('users').doc(u.uid).set({
          'email': email,
          'role': isAdmin ? 'admin' : 'logged_in',
          'isVIP': isAdmin,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return u;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
