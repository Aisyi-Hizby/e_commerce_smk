import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/app/core/services/auth_service.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

/// Middleware Keamanan Rute GetX (Sesi 08: Route Guard & Redirection)
/// Mencegah akses ke halaman sensitif (misal: /checkout) jika pengguna belum login.
class AuthMiddleware extends GetMiddleware {
  final AuthService? _authService;

  AuthMiddleware({AuthService? authService}) : _authService = authService;

  AuthService get auth {
    if (_authService != null) return _authService;
    return AuthService.to;
  }

  // Prioritas eksekusi middleware (angka lebih kecil dijalankan lebih dulu)
  @override
  int? get priority => 1;

  // PEMICU: Dipanggil otomatis oleh GetX Navigator sesaat sebelum rute tujuan ditampilkan ke layar.
  // ALUR: Periksa status login; jika false, belokkan ke rute Login dan simpan rute tujuan.
  @override
  RouteSettings? redirect(String? route) {
    // 1. Periksa apakah pengguna saat ini sudah masuk akun
    if (!auth.isLoggedIn.value) {
      // 2. Simpan rute tujuan agar pengguna dapat dikembalikan setelah login berhasil
      auth.redirectRoute = route;

      // 3. Tampilkan notifikasi peringatan edukatif di bagian atas layar
      if (!Get.testMode && Get.overlayContext != null) {
        Get.snackbar(
          'Akses Dibatasi',
          'Silakan masuk akun terlebih dahulu untuk melanjutkan proses pemesanan.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1E293B),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          icon: const Icon(
            Icons.lock_outline_rounded,
            color: Colors.orangeAccent,
          ),
        );
      }

      // 4. Belokkan paksa navigasi ke halaman login
      return const RouteSettings(name: Routes.LOGIN);
    }

    // 5. Jika sudah login, kembalikan null untuk mengizinkan navigasi ke rute tujuan
    return null;
  }
}
