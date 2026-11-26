import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/services/auth_service.dart';
import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

/// Controller Manajemen Form Login (Sesi 04 & 08: Form Handling, Validasi & Route Return)
class LoginController extends GetxController {
  // GlobalKey untuk memvalidasi seluruh TextFormField dalam Form
  final formKey = GlobalKey<FormState>();

  // TextEditingController untuk menangkap input teks siswa
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  // State Reaktif GetX untuk visibilitas kata sandi, status loading, dan Remember Me
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle visibilitas kata sandi (Mata Terbuka / Tertutup)
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Toggle checkbox "Ingat Saya"
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
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

  // Aksi Masuk Akun
  Future<void> login() async {
    // 1. Jalankan validasi seluruh field form
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Sesi 08: Simpan status login ke AuthService
      if (Get.isRegistered<AuthService>()) {
        await AuthService.to.login(
          emailController.text.trim(),
          passwordController.text,
        );
      }

      if (!Get.testMode && Get.overlayContext != null) {
        Get.snackbar(
          'Berhasil Masuk 🎉',
          'Selamat datang kembali di KicksStore!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      }

      // Sesi 08: Periksa apakah ada return route (misal dari pencegatan /checkout)
      String? returnRoute;
      if (Get.isRegistered<AuthService>()) {
        returnRoute = AuthService.to.redirectRoute;
        AuthService.to.redirectRoute = null; // Reset rute setelah dibaca
      }

      if (returnRoute != null && returnRoute.isNotEmpty) {
        Get.offNamed(returnRoute);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
