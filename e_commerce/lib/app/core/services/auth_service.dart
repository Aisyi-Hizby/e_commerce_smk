import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service Autentikasi Pengguna Global (Sesi 09: Terintegrasi Firebase Authentication)
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserEmail = 'auth_user_email';

  late final SharedPreferences _prefs;
  FirebaseAuth? _auth;
  StreamSubscription<User?>? _authSubscription;

  // Status login reaktif
  final isLoggedIn = false.obs;
  final currentUserEmail = ''.obs;
  final currentUserId = ''.obs;

  // Route target redirect setelah login berhasil (misal: /checkout)
  String? redirectRoute;

  /// Inisialisasi awal membaca status sesi tersimpan dan stream Firebase Auth
  Future<AuthService> init({
    SharedPreferences? prefs,
    FirebaseAuth? auth,
  }) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();

    try {
      _auth = auth ?? FirebaseAuth.instance;
      _authSubscription = _auth!.authStateChanges().listen((User? user) {
        if (user != null) {
          isLoggedIn.value = true;
          currentUserEmail.value = user.email ?? '';
          currentUserId.value = user.uid;
        } else {
          isLoggedIn.value = false;
          currentUserEmail.value = '';
          currentUserId.value = '';
        }
      });

      // Sinkronisasi status awal
      if (_auth!.currentUser != null) {
        isLoggedIn.value = true;
        currentUserEmail.value = _auth!.currentUser?.email ?? '';
        currentUserId.value = _auth!.currentUser?.uid ?? '';
      } else {
        isLoggedIn.value = _prefs.getBool(_keyIsLoggedIn) ?? false;
        currentUserEmail.value = _prefs.getString(_keyUserEmail) ?? '';
      }
    } catch (_) {
      // Fallback aman untuk unit testing lingkungan lokal tanpa Firebase App
      isLoggedIn.value = _prefs.getBool(_keyIsLoggedIn) ?? false;
      currentUserEmail.value = _prefs.getString(_keyUserEmail) ?? '';
    }

    return this;
  }

  /// Login akun pembeli via Firebase Auth
  Future<void> login(String email, String password) async {
    if (_auth != null) {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      isLoggedIn.value = user != null;
      currentUserEmail.value = user?.email ?? email.trim();
      currentUserId.value = user?.uid ?? '';
    } else {
      isLoggedIn.value = true;
      currentUserEmail.value = email.trim();
    }

    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserEmail, currentUserEmail.value);
  }

  /// Registrasi akun pembeli baru via Firebase Auth
  Future<void> register(String email, String password) async {
    if (_auth != null) {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      isLoggedIn.value = user != null;
      currentUserEmail.value = user?.email ?? email.trim();
      currentUserId.value = user?.uid ?? '';
    } else {
      isLoggedIn.value = true;
      currentUserEmail.value = email.trim();
    }

    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserEmail, currentUserEmail.value);
  }

  /// Logout akun dan bersihkan sesi
  Future<void> logout() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
    isLoggedIn.value = false;
    currentUserEmail.value = '';
    currentUserId.value = '';
    redirectRoute = null;
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserEmail);
  }

  /// Helper edukatif penerjemah error Firebase Authentication ke bahasa Indonesia
  static String mapFirebaseAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Akun dengan email ini tidak ditemukan.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Kata sandi atau email yang Anda masukkan salah.';
        case 'email-already-in-use':
          return 'Email ini sudah terdaftar. Silakan gunakan email lain atau langsung login.';
        case 'invalid-email':
          return 'Format alamat email tidak valid.';
        case 'weak-password':
          return 'Kata sandi terlalu lemah. Minimal gunakan 6 karakter.';
        case 'network-request-failed':
          return 'Koneksi internet bermasalah. Periksa sambungan data perangkat Anda.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan gagal. Silakan tunggu beberapa saat lagi.';
        case 'operation-not-allowed':
          return 'Metode login Email/Password belum diaktifkan di Firebase Console.';
        default:
          return error.message ??
              'Terjadi kesalahan autentikasi (${error.code}).';
      }
    }
    return error.toString();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
