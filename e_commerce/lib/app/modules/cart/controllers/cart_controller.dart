import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:e_commerce/app/core/theme/app_colors.dart';
import 'package:e_commerce/app/data/local/cart_local_datasource.dart';
import 'package:e_commerce/app/data/models/cart_item_model.dart';
import 'package:e_commerce/app/data/models/product_model.dart';

/// ViewModel untuk Manajemen Keranjang Belanja (Sesi 03 & 08: Reaktivitas & Persistensi Hive CE)
class CartController extends GetxController {
  // TUJUAN: Sumber penyimpanan fisik data keranjang ke memori HP melalui Hive CE Box.
  final CartLocalDataSource? _localDataSource;

  CartController({CartLocalDataSource? localDataSource})
    : _localDataSource = localDataSource;

  CartLocalDataSource? get _dataSource {
    if (_localDataSource != null) return _localDataSource;
    if (Get.isRegistered<CartLocalDataSource>()) {
      return Get.find<CartLocalDataSource>();
    }
    return null;
  }

  // TUJUAN: State reaktif daftar seluruh sepatu di keranjang belanja.
  // MENGAPA .obs: Agar setiap penambahan, pengurangan, atau penghapusan item langsung merender ulang UI keranjang dan badge di AppBar.
  final items = <CartItemModel>[].obs;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // PEMICU: Dipanggil otomatis oleh GetX saat controller pertama kali diinisialisasi.
  // ALUR: Muat seluruh data keranjang yang tersimpan dari database Hive lokal.
  @override
  void onInit() {
    super.onInit();
    _loadCartFromStorage();
  }

  /// Memuat keranjang dari memori penyimpanan lokal Hive
  void _loadCartFromStorage() {
    final ds = _dataSource;
    if (ds != null) {
      final savedItems = ds.getCartItems();
      if (savedItems.isNotEmpty) {
        items.assignAll(savedItems);
        return;
      }
    }
    // Jika data lokal masih kosong, isi dengan item demo praktikum
    if (_localDataSource == null) {
      _seedInitialCartItems();
    }
  }

  void _seedInitialCartItems() {
    final defaultItems = [
      CartItemModel(
        id: 'shoe-01_42',
        product: const ProductModel(
          id: 'shoe-01',
          name: 'Nike Air Jordan 1 High OG',
          category: 'Basketball',
          price: 2499000,
          rating: 4.9,
          reviewCount: 312,
          imageUrl:
              'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=800&q=80',
          description: 'Sepatu legendaris dengan material kulit premium.',
        ),
        selectedSize: '42',
        quantity: 1,
      ),
      CartItemModel(
        id: 'shoe-02_41',
        product: const ProductModel(
          id: 'shoe-02',
          name: 'Adidas Ultraboost Light 23',
          category: 'Running',
          price: 3100000,
          rating: 4.8,
          reviewCount: 195,
          imageUrl:
              'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=800&q=80',
          description:
              'Sepatu lari paling responsif dengan bantalan Light BOOST.',
        ),
        selectedSize: '41',
        quantity: 1,
      ),
    ];
    items.assignAll(defaultItems);
    for (final item in defaultItems) {
      _dataSource?.saveCartItem(item);
    }
  }

  // Total jumlah pasang sepatu di keranjang
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  // Subtotal total belanja (sebelum pajak dan ongkir)
  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  // Pajak PPN 11%
  int get tax => (subtotal * 0.11).round();

  // Biaya kirim standar
  int get shippingFee => items.isEmpty ? 0 : 25000;

  // Total pembayaran akhir
  int get totalAmount => items.isEmpty ? 0 : subtotal + tax + shippingFee;

  String get formattedSubtotal => currencyFormatter.format(subtotal);
  String get formattedTax => currencyFormatter.format(tax);
  String get formattedShippingFee => currencyFormatter.format(shippingFee);
  String get formattedTotalAmount => currencyFormatter.format(totalAmount);

  /// Tambah item ke keranjang belanja (Async & Persistent)
  Future<void> addItemAsync(
    ProductModel product, {
    int quantity = 1,
    String size = '42',
    bool showSnackbar = true,
  }) async {
    final cartItemId = '${product.id}_$size';
    final existingIndex = items.indexWhere((item) => item.id == cartItemId);

    CartItemModel savedItem;
    if (existingIndex != -1) {
      items[existingIndex].quantity += quantity;
      savedItem = items[existingIndex];
      items.refresh();
    } else {
      savedItem = CartItemModel(
        id: cartItemId,
        product: product,
        selectedSize: size,
        quantity: quantity,
      );
      items.add(savedItem);
    }

    // Simpan permanen ke Hive Box
    await _dataSource?.saveCartItem(savedItem);

    if (showSnackbar && !Get.testMode && Get.overlayContext != null) {
      Get.snackbar(
        'Keranjang Diperbarui',
        '$quantity pasang ${product.name} (Ukuran $size) ditambahkan!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
      );
    }
  }

  void addItem(ProductModel product, {int quantity = 1, String size = '42'}) {
    addItemAsync(product, quantity: quantity, size: size);
  }

  /// Tambah kuantitas 1 item (Async)
  Future<void> increaseQuantityAsync(String cartItemId) async {
    final index = items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      items[index].quantity++;
      items.refresh();
      await _dataSource?.saveCartItem(items[index]);
    }
  }

  void increaseQuantity(String cartItemId) {
    increaseQuantityAsync(cartItemId);
  }

  /// Kurangi kuantitas 1 item (Async)
  Future<void> decreaseQuantityAsync(String cartItemId) async {
    final index = items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
        items.refresh();
        await _dataSource?.saveCartItem(items[index]);
      } else {
        await removeItemAsync(cartItemId);
      }
    }
  }

  void decreaseQuantity(String cartItemId) {
    decreaseQuantityAsync(cartItemId);
  }

  /// Hapus item dari keranjang (Async)
  Future<void> removeItemAsync(
    String cartItemId, {
    bool showSnackbar = true,
  }) async {
    final removedItem = items.firstWhereOrNull((item) => item.id == cartItemId);
    items.removeWhere((item) => item.id == cartItemId);
    await _dataSource?.removeCartItem(cartItemId);

    if (removedItem != null &&
        showSnackbar &&
        !Get.testMode &&
        Get.overlayContext != null) {
      Get.snackbar(
        'Item Dihapus',
        '${removedItem.product.name} dikeluarkan dari keranjang.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF334155),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.delete_outline, color: Colors.white),
      );
    }
  }

  void removeItem(String cartItemId) {
    removeItemAsync(cartItemId);
  }

  /// Kosongkan seluruh keranjang belanja (Async)
  Future<void> clearCartAsync() async {
    items.clear();
    await _dataSource?.clearCart();
  }

  void clearCart() {
    clearCartAsync();
  }
}
