import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/controllers/home_controller.dart';

class WishlistController extends GetxController {
  // Sesi 03: Mengakses HomeController dan CartController via Dependency Injection

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

  // Daftar produk yang sedang difavoritkan oleh pengguna
  List<ProductModel> get wishlistItems {
    final favIds = homeController.favoriteIds;
    return homeController.products
        .where((product) => favIds.contains(product.id))
        .toList();
  }

  int get totalCount => wishlistItems.length;

  // Jumlah total item di keranjang belanja
  int get cartCount => cartController.totalItemCount;

  // Hapus dari wishlist
  void removeFromWishlist(String productId) {
    homeController.favoriteIds.remove(productId);
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

  // Pindahkan item wishlist langsung ke keranjang belanja
  void moveToCart(ProductModel product) {
    cartController.addItem(product);
    homeController.favoriteIds.remove(product.id);
  }

  // Buka detail produk berargumen ProductModel
  void openDetail(ProductModel product) {
    Get.toNamed('/detail', arguments: product);
  }
}
