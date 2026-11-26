import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

/// Opsi Kurir Ekspedisi Pengiriman
class CourierOption {
  final String name;
  final String estimatedTime;
  final int cost;

  const CourierOption({
    required this.name,
    required this.estimatedTime,
    required this.cost,
  });
}

/// Controller Checkout & Pemesanan (Sesi 08: Form Handling, Shipping & Order Placement)
class CheckoutController extends GetxController {
  final CartController? _cartController;

  CheckoutController({CartController? cartController})
    : _cartController = cartController;

  CartController get cart {
    if (_cartController != null) return _cartController;
    return Get.find<CartController>();
  }

  // GlobalKey untuk validasi form pengiriman
  final formKey = GlobalKey<FormState>();

  // TextEditingController untuk form input pengiriman
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController notesController;

  // State reaktif pilihan kurir (0 = JNE, 1 = SiCepat, 2 = GoSend)
  final selectedCourierIndex = 0.obs;

  // State reaktif pilihan pembayaran (0 = COD, 1 = Virtual Account, 2 = QRIS)
  final selectedPaymentMethod = 0.obs;

  // Status proses transaksi checkout
  final isLoading = false.obs;

  // Daftar opsi kurir ekspedisi
  final List<CourierOption> courierOptions = const [
    CourierOption(
      name: 'JNE Reguler',
      estimatedTime: '2-3 hari kerja',
      cost: 25000,
    ),
    CourierOption(
      name: 'SiCepat BEST',
      estimatedTime: '1-2 hari kerja',
      cost: 22000,
    ),
    CourierOption(
      name: 'GoSend Instant',
      estimatedTime: 'Tiba hari ini (Instant 3-4 jam)',
      cost: 35000,
    ),
  ];

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    notesController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // Pemilihan kurir
  void selectCourier(int index) {
    if (index >= 0 && index < courierOptions.length) {
      selectedCourierIndex.value = index;
    }
  }

  // Pemilihan metode pembayaran
  void selectPaymentMethod(int index) {
    selectedPaymentMethod.value = index;
  }

  // Validasi Nama Penerima
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama penerima wajib diisi';
    }
    return null;
  }

  // Validasi Nomor Telepon
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final clean = value.trim();
    final digitsOnly = RegExp(r'^[0-9+]+$');
    if (!digitsOnly.hasMatch(clean)) {
      return 'Format nomor telepon tidak valid';
    }
    if (clean.replaceAll(RegExp(r'\D'), '').length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }
    return null;
  }

  // Validasi Alamat Pengiriman
  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat pengiriman wajib diisi';
    }
    if (value.trim().length < 10) {
      return 'Alamat lengkap minimal 10 karakter';
    }
    return null;
  }

  // Getter Finansial Rincian Biaya
  int get subtotal => cart.subtotal;
  int get tax => cart.tax;
  int get courierFee =>
      cart.items.isEmpty ? 0 : courierOptions[selectedCourierIndex.value].cost;
  int get promoDiscount => 0; // Dapat diperluas dengan kupon diskon
  int get grandTotal => subtotal + tax + courierFee - promoDiscount;

  String get formattedSubtotal => currencyFormatter.format(subtotal);
  String get formattedTax => currencyFormatter.format(tax);
  String get formattedCourierFee => currencyFormatter.format(courierFee);
  String get formattedGrandTotal => currencyFormatter.format(grandTotal);

  /// Eksekusi pemrosesan pesanan (Business Logic)
  Future<bool> processOrder() async {
    isLoading.value = true;
    try {
      // Simulasi latency pengolahan transaksi
      await Future.delayed(const Duration(milliseconds: 300));
      // Kosongkan keranjang belanja secara asinkron dari memori disk Hive
      await cart.clearCartAsync();
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Pemicu dari tombol UI "Bayar Sekarang"
  Future<void> placeOrder() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      Get.snackbar(
        'Data Belum Lengkap',
        'Silakan lengkapi formulir pengiriman sebelum melanjutkan.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final success = await processOrder();
    if (success) {
      Get.defaultDialog(
        title: 'Pesanan Berhasil! 🎉',
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        middleText:
            'Terima kasih! Pesanan sneakers impianmu sedang diproses dan tersimpan ke cloud.',
        textConfirm: 'Lihat Riwayat Pesanan',
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primary,
        onConfirm: () {
          Get.back();
          Get.offAllNamed(Routes.ORDERS);
        },
      );
    }
  }
}
