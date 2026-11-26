import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_commerce/app/data/local/cart_local_datasource.dart';
import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/models/cart_item_model.dart';
import 'package:e_commerce/app/data/models/product_model.dart';

/// Service penyimpanan data lokal terpusat (Sesi 06, 07 & 08: Local Storage & Hive CE CRUD)
class StorageService extends GetxService {
  static const String _themeKey = 'is_dark_mode';

  late final SharedPreferences _prefs;

  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  /// Inisialisasi asynchronous SharedPreferences dan Hive CE sebelum UI dirender
  Future<StorageService> init({bool initHive = true}) async {
    // 1. Muat preferensi primitif melalui SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = _prefs.getBool(_themeKey) ?? false;

    // 2. Inisialisasi NoSQL Object Database Hive CE untuk platform mobile/desktop/web
    if (initHive) {
      await Hive.initFlutter();

      // Sesi 07: Registrasi TypeAdapter Hive CE untuk serialisasi objek ProductModel (typeId 0)
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductModelAdapter());
      }

      // Sesi 08: Registrasi TypeAdapter Hive CE untuk serialisasi CartItemModel (typeId 1)
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CartItemModelAdapter());
      }

      // Membuka box penyimpanan produk, wishlist, dan keranjang belanja secara async
      await Hive.openBox<ProductModel>(
        ProductLocalDataSourceImpl.productsBoxName,
      );
      await Hive.openBox<ProductModel>(
        ProductLocalDataSourceImpl.wishlistBoxName,
      );
      await Hive.openBox<CartItemModel>(CartLocalDataSourceImpl.cartBoxName);
    }

    return this;
  }

  /// Mengubah mode tema dan menyimpannya secara persisten ke SharedPreferences
  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    await _prefs.setBool(_themeKey, _isDarkMode.value);

    // Perbarui mode tema secara dinamis di GetMaterialApp
    Get.changeThemeMode(themeMode);
  }

  /// Getter SharedPreferences jika modul lain memerlukan akses key-value
  SharedPreferences get prefs => _prefs;
}
