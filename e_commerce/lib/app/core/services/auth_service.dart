import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service Autentikasi Pengguna Global (Sesi 08: Mock Session, Persiapan Sesi 09 Firebase Auth)
// TUJUAN: Mengelola status sesi autentikasi pengguna secara permanen dan menyediakan rute kembali (return navigation).
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserEmail = 'auth_user_email';

  late final SharedPreferences _prefs;

  // TUJUAN: Status apakah pengguna saat ini sudah masuk akun atau masih sebagai tamu (guest).
  // MENGAPA .obs: Agar saat status berubah, widget profil atau tombol auth langsung bereaksi.
  final isLoggedIn = false.obs;

  // TUJUAN: Menyimpan alamat email pengguna yang sedang aktif masuk.
  final currentUserEmail = ''.obs;

  // TUJUAN: Menyimpan target rute tujuan pengguna sebelum dicegat oleh AuthMiddleware (misal: '/checkout').
  String? redirectRoute;

  /// Inisialisasi awal membaca status sesi tersimpan di SharedPreferences
  // PEMICU: Dipanggil di main.dart saat bootstrap aplikasi sebelum UI dirender.
  Future<AuthService> init({SharedPreferences? prefs}) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();
    isLoggedIn.value = _prefs.getBool(_keyIsLoggedIn) ?? false;
    currentUserEmail.value = _prefs.getString(_keyUserEmail) ?? '';
    return this;
  }

  /// Simulasi login akun pembeli
  // PEMICU: Pengguna menekan tombol "Masuk Sekarang" di halaman Login.
  // ALUR: Set status login true, tulis ke SharedPreferences, perbarui state reaktif.
  Future<void> login(String email, String password) async {
    isLoggedIn.value = true;
    currentUserEmail.value = email;
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserEmail, email);
  }

  /// Logout akun dan bersihkan sesi
  // PEMICU: Pengguna menekan tombol "Keluar Akun" di halaman Pengaturan/Profil.
  Future<void> logout() async {
    isLoggedIn.value = false;
    currentUserEmail.value = '';
    redirectRoute = null;
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserEmail);
  }
}
