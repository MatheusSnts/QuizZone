import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Instância partilhada do serviço de autenticação.
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

/// Encapsula as operações de Firebase Authentication usadas pela app.
class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

/// Inicia sessão com email e palavra-passe.
  Future<UserCredential> signIn({
    required String email,
    required String password
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Cria uma conta nova no Firebase Authentication.
  Future<UserCredential> createAccount({
    required String email,
    required String password
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

/// Termina a sessão atual.
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

/// Envia um email de recuperação de palavra-passe.
  Future<void> resetPassword({
    required String email,
  }) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Apaga a conta após reautenticar o utilizador.
  Future<void> deleteAccount({
    required String email,
    required String password
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  /// Atualiza a palavra-passe após confirmar a palavra-passe atual.
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}