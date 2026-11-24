import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Toda la lógica de autenticación vive aquí.
/// Firebase guarda la sesión en el dispositivo automáticamente:
/// al volver a abrir la app el usuario sigue dentro hasta que cierre sesión.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  // ---------- Validación de correo ----------
  static final RegExp _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$');

  static bool isValidEmail(String value) => _emailRegex.hasMatch(value.trim());

  // ---------- Correo y contraseña ----------
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    await cred.user?.updateDisplayName(name.trim());
    await cred.user?.reload();
    try {
      // El correo de verificación es informativo: no impide entrar al feed.
      await cred.user?.sendEmailVerification();
    } catch (_) {}
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  // ---------- Google y Facebook ----------
  Future<void> signInWithGoogle() => _signInWithProvider(GoogleAuthProvider());

  Future<void> signInWithFacebook() => _signInWithProvider(FacebookAuthProvider());

  Future<void> _signInWithProvider(AuthProvider provider) async {
    if (kIsWeb) {
      await _auth.signInWithPopup(provider);
    } else {
      await _auth.signInWithProvider(provider);
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Nombre del método con el que entró el usuario (para mostrarlo en el perfil).
  static String providerLabel(User user) {
    final ids = user.providerData.map((p) => p.providerId).toList();
    if (ids.contains('google.com')) return 'Google';
    if (ids.contains('facebook.com')) return 'Facebook';
    return 'Correo y contraseña';
  }

  // ---------- Mensajes de error en español ----------
  /// Devuelve null cuando el usuario solo canceló el inicio de sesión.
  static String? errorMessage(Object error) {
    if (error is! FirebaseAuthException) return 'Ocurrió un error inesperado.';
    switch (error.code) {
      case 'canceled':
      case 'web-context-canceled':
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return null;
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 8 caracteres).';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet.';
      case 'account-exists-with-different-credential':
        return 'Ese correo ya está registrado con otro método de acceso.';
      case 'operation-not-allowed':
        return 'Este método de acceso no está habilitado en Firebase.';
      default:
        return error.message ?? 'No se pudo completar la acción.';
    }
  }
}
