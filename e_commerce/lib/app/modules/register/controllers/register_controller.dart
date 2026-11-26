import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/services/auth_service.dart';
import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/modules/login/controllers/login_controller.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

/// Controller Manajemen Form Registrasi (Sesi 04 & 09: Form Handling, Validasi & Firebase Auth)
class RegisterController extends GetxController {
  // GlobalKey untuk validasi form pendaftaran akun
  final formKey = GlobalKey<FormState>();

  // TextEditingController untuk menangkap seluruh data input siswa
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  // State Reaktif GetX untuk visibilitas sandi dan indikator loading
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    // Edukasi SMK: Wajib dispose seluruh TextEditingController saat controller dimusnahkan
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle visibilitas kata sandi utama
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Toggle visibilitas konfirmasi kata sandi
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // Validasi Nama Lengkap (Minimal 3 karakter)
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  // Validasi Alamat Email dengan Regular Expression (Regex)
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat email wajib diisi';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid (contoh: nama@sekolah.sch.id)';
    }
    return null;
  }

  // Validasi Kata Sandi (Minimal 6 karakter)
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  // Validasi Konfirmasi Kata Sandi (Wajib identik dengan passwordController)
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }
    if (value != passwordController.text) {
      return 'Konfirmasi kata sandi tidak cocok dengan sandi di atas';
    }
    return null;
  }

  // Aksi Pendaftaran Akun Baru via Firebase Auth
  Future<void> register() async {
    // 1. Jalankan validasi seluruh field input
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }

    // 2. Aktifkan indikator loading
    isLoading.value = true;

    try {
      // Simpan nilai nama & email sebelum controller berpotensi ter-dispose saat navigasi
      final registeredName = nameController.text.trim();
      final registeredEmail = emailController.text.trim();

      // Sesi 09: Registrasi akun baru menggunakan Firebase Authentication
      if (Get.isRegistered<AuthService>()) {
        await AuthService.to.register(registeredEmail, passwordController.text);
      }

      // Sesi 08 & 09: Periksa apakah pendaftaran dipicu oleh rute terproteksi (misal: /checkout)
      String? returnRoute;
      if (Get.isRegistered<AuthService>()) {
        returnRoute = AuthService.to.redirectRoute;
        AuthService.to.redirectRoute = null;
      }

      if (returnRoute != null && returnRoute.isNotEmpty) {
        // KASUS 1: Pengguna mendaftar saat proses checkout (rute dicegat)
        // Pertahankan status login Firebase Auth, tutup form Login & Register, dan arahkan langsung ke checkout!
        Get.until(
          (route) =>
              route.isFirst ||
              (route.settings.name != Routes.LOGIN &&
                  route.settings.name != Routes.REGISTER),
        );
        Get.toNamed(returnRoute);

        // Munculkan snackbar sukses melanjutkan ke checkout
        if (!Get.testMode && Get.overlayContext != null) {
          Get.snackbar(
            'Pendaftaran Berhasil 🎉',
            'Akun untuk $registeredName berhasil dibuat! Melanjutkan ke proses pemesanan...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          );
        }
      } else {
        // KASUS 2: Pendaftaran biasa (bukan dari checkout)
        // Sesuai alur belajar SMK, kembalikan pengguna ke halaman Login.
        // Lakukan logout sementara agar pengguna mempraktikkan proses login mandiri.
        if (Get.isRegistered<AuthService>()) {
          await AuthService.to.logout();
        }

        // Isi otomatis field email di form Login jika LoginController aktif di memori
        if (Get.isRegistered<LoginController>()) {
          Get.find<LoginController>().emailController.text = registeredEmail;
        }

        // Kembali ke halaman Login terlebih dahulu sebelum memunculkan notifikasi
        if (Get.context != null && Navigator.canPop(Get.context!)) {
          Get.back();
        } else {
          Get.offNamed(Routes.LOGIN);
        }

        // Munculkan snackbar sukses di atas halaman Login
        if (!Get.testMode && Get.overlayContext != null) {
          Get.snackbar(
            'Pendaftaran Berhasil 🎉',
            'Akun untuk $registeredName berhasil dibuat! Silakan masuk dengan kata sandi Anda.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          );
        }
      }
    } catch (e) {
      if (!Get.testMode && Get.overlayContext != null) {
        final errorMessage = AuthService.mapFirebaseAuthError(e);
        Get.snackbar(
          'Gagal Mendaftar',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
