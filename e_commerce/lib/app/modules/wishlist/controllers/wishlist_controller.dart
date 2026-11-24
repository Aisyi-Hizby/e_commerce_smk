import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/data/repository/product_repository.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:e_commerce/app/modules/home/controllers/home_controller.dart';

/// ViewModel untuk Manajemen Wishlist Favorit (Sesi 07: CRUD Offline Hive CE)
class WishlistController extends GetxController {
  // TUJUAN: Menghubungkan ViewModel ke lapisan Repository untuk membaca dan menghapus wishlist offline.
  final ProductRepository _productRepository;

  /// Constructor Injection menerima ProductRepository
  WishlistController([ProductRepository? productRepository])
    : _productRepository = productRepository ?? Get.find<ProductRepository>();

  // TUJUAN: Menyimpan daftar produk sepatu favorit yang tersimpan di Hive CE.
  // MENGAPA .obs: Agar saat item ditambah atau dihapus, GridView di WishlistView langsung memperbarui tampilan.
  // HUBUNGAN KE TAMPILAN: Merender kartu produk favorit atau menampilkan Empty State jika wishlist kosong.
  final RxList<ProductModel> wishlist = <ProductModel>[].obs;

  // PEMICU: Dipanggil otomatis oleh GetX saat halaman Wishlist dibuka.
  // ALUR: Memanggil loadWishlist() untuk mengambil data dari database lokal Hive CE.
  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  /// Memuat daftar produk favorit dari database lokal Hive CE
  // PEMICU: Dipanggil pada onInit() atau setelah penghapusan item dari wishlist.
  // ALUR: Mengambil List<ProductModel> dari repository dan memasukkannya ke state reaktif wishlist via assignAll.
  void loadWishlist() {
    wishlist.assignAll(_productRepository.getWishlist());
  }

  HomeController get homeController {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>();
    }
    return Get.put(HomeController());
  }

  CartController get cartController {
    if (Get.isRegistered<CartController>()) {
      return Get.find<CartController>();
    }
    return Get.put(CartController());
  }

  // Getter kompatibilitas untuk antarmuka View
  List<ProductModel> get wishlistItems => wishlist;

  int get totalCount => wishlist.length;

  int get cartCount => cartController.totalItemCount;

  /// Hapus produk dari wishlist secara offline persisten ke database Hive CE
  // PEMICU: Tombol ikon tong sampah (Delete) pada kartu produk di WishlistView diklik.
  // ALUR: Menghapus produk dari Hive via repository, memuat ulang wishlist, sinkronkan favoriteIds di HomeController, tampilkan snackbar feedback.
  Future<void> removeFromWishlist(String productId) async {
    final item = wishlist.firstWhereOrNull((e) => e.id == productId);
    if (item != null) {
      await _productRepository.toggleWishlist(item);
      loadWishlist();

      // Sinkronkan state HomeController jika sedang aktif
      if (Get.isRegistered<HomeController>()) {
        homeController.favoriteIds.remove(productId);
      }

      Get.snackbar(
        'Dihapus dari Wishlist',
        'Produk telah dikeluarkan dari daftar favorit.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF334155),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.favorite_border, color: Colors.white),
      );
    }
  }

  /// Pindahkan item wishlist langsung ke keranjang belanja
  // PEMICU: Tombol 'Pindah ke Keranjang' pada kartu produk diklik.
  // ALUR: Tambahkan produk ke CartController, lalu hapus produk dari database wishlist.
  Future<void> moveToCart(ProductModel product) async {
    cartController.addItem(product);
    await removeFromWishlist(product.id);
  }

  /// Buka detail produk
  // PEMICU: Kartu produk ditekan.
  // ALUR: Navigasi ke rute '/detail' membawa argumen Map produk.
  void openDetail(ProductModel product) {
    Get.toNamed('/detail', arguments: product.toMap());
  }
}
