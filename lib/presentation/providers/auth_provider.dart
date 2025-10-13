import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkAuthStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _loadUserData(user.uid);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
    } catch (e) {
      _error = 'Error inesperado: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        userType: userType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        childrenIds: [],
        professionalIds: [],
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      _currentUser = newUser;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
    } catch (e) {
      _error = 'Error inesperado: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      _error = 'Error cargando datos del usuario: $e';
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El email ya está en uso';
      case 'weak-password':
        return 'La contraseña es muy débil';
      default:
        return 'Error de autenticación: $code';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error cerrando sesión: $e';
    }
  }
}
