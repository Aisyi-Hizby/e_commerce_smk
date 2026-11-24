import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/models/product_model.dart';

/// Service penyimpanan data lokal terpusat (Sesi 06 & 07: Local Storage & Hive CE CRUD)
// TUJUAN: Service permanen yang hidup selama siklus aplikasi untuk mengelola SharedPreferences dan Hive CE.
class StorageService extends GetxService {
  // TUJUAN: Kunci penyimpanan preferensi mode tema di SharedPreferences.
  static const String _themeKey = 'is_dark_mode';

  // TUJUAN: Instance SharedPreferences untuk data key-value primitif.
  late final SharedPreferences _prefs;

  // TUJUAN: Menyimpan status reaktif apakah tema gelap aktif atau tidak.
  // MENGAPA .obs: Agar perubahan tema langsung terpantau oleh GetX.
  // HUBUNGAN KE TAMPILAN: Mempengaruhi palet warna di seluruh layar aplikasi.
  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  /// Inisialisasi asynchronous SharedPreferences dan Hive CE sebelum UI dirender
  // PEMICU: Dipanggil via Get.putAsync(() => StorageService().init()) di main.dart sebelum runApp().
  // ALUR: Membaca pengaturan tema dari disk, lalu menginisialisasi Hive, mendaftarkan TypeAdapter, dan membuka box data.
  Future<StorageService> init({bool initHive = true}) async {
    // 1. Muat preferensi primitif melalui SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = _prefs.getBool(_themeKey) ?? false;

    // 2. Inisialisasi NoSQL Object Database Hive CE untuk platform mobile/desktop/web
    if (initHive) {
      await Hive.initFlutter();

      // Sesi 07: Registrasi TypeAdapter Hive CE untuk serialisasi objek ProductModel
      // CATATAN: Wajib didaftarkan sebelum memanggil Hive.openBox agar Hive tahu cara membaca dan menulis ProductModel.
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductModelAdapter());
      }

      // Membuka box penyimpanan produk dan wishlist secara async
      await Hive.openBox<ProductModel>(
        ProductLocalDataSourceImpl.productsBoxName,
      );
      await Hive.openBox<ProductModel>(
        ProductLocalDataSourceImpl.wishlistBoxName,
      );
    }

    return this;
  }

  /// Mengubah mode tema dan menyimpannya secara persisten ke SharedPreferences
  // PEMICU: Tombol ikon matahari/bulan di AppBar ditekan.
  // ALUR: Nilai boolean dibalik, disimpan ke SharedPreferences, dan Get.changeThemeMode dipanggil.
  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    await _prefs.setBool(_themeKey, _isDarkMode.value);

    // Perbarui mode tema secara dinamis di GetMaterialApp
    Get.changeThemeMode(themeMode);
  }

  /// Getter SharedPreferences jika modul lain memerlukan akses key-value
  SharedPreferences get prefs => _prefs;
}
