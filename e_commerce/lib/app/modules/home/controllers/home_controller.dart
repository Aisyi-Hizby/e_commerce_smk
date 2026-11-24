import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/core/network/result.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/data/repository/product_repository.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';

/// ViewModel untuk Halaman Beranda (Sesi 05: Integrasi REST API & Clean Architecture)
class HomeController extends GetxController {
  // Sesi 05: Repository diinjeksi melalui Constructor Injection (IoC)
  // TUJUAN: Sumber tunggal data produk dan operasi wishlist.
  final ProductRepository _productRepository;

  HomeController([ProductRepository? productRepository])
    : _productRepository = productRepository ?? Get.find<ProductRepository>();

  // TUJUAN: Menyimpan nama kategori aktif untuk filter produk ('Semua', 'Running', dsb.).
  // MENGAPA .obs: Agar saat kategori diklik, GridView langsung terfilter secara reaktif.
  // HUBUNGAN KE TAMPILAN: Mengatur warna filter chip dan item yang tampil di katalog.
  final selectedCategory = 'Semua'.obs;

  // TUJUAN: Menyimpan himpunan ID produk yang difavoritkan pengguna secara offline.
  // MENGAPA .obs: Agar ikon hati di ProductCard otomatis berwarna merah jika id terdaftar.
  // HUBUNGAN KE TAMPILAN: Ikon favorit di ProductCard berubah antara Icons.favorite dan Icons.favorite_border.
  final favoriteIds = <String>{}.obs;

  // TUJUAN: Menandai apakah sedang berlangsung request data ke server API.
  // MENGAPA .obs: Untuk mengontrol rendering antara Shimmer Loading dan katalog produk asli.
  // HUBUNGAN KE TAMPILAN: Jika true, tampilkan ProductGridShimmer; jika false, tampilkan GridView produk.
  final isLoading = false.obs;

  // TUJUAN: Menyimpan pesan error jika pengambilan data gagal total.
  // MENGAPA .obs: Agar pesan error bisa ditampilkan ke pengguna jika tidak ada cache lokal.
  final errorMessage = ''.obs;

  // TUJUAN: Daftar filter kategori horizontal di bawah banner promo.
  final categories = <String>[
    'Semua',
    'Running',
    'Casual',
    'Basketball',
    'Lifestyle',
  ];

  // TUJUAN: Menyimpan seluruh katalog produk sepatu yang berhasil dimuat dari API atau cache Hive.
  // MENGAPA .obs: Agar antarmuka beranda ter-render ulang saat data produk tiba.
  final products = <ProductModel>[].obs;

  // Fallback data lokal jika perangkat offline saat pertama kali aplikasi dibuka
  static const List<ProductModel> _initialFallbackProducts = [
    ProductModel(
      id: 'shoe-01',
      name: 'Nike Air Jordan 1 High OG',
      category: 'Basketball',
      price: 2499000,
      rating: 4.9,
      reviewCount: 312,
      imageUrl:
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=800&q=80',
      description:
          'Sepatu legendaris dengan material kulit premium, bantalan Air-Sole klasik, dan sol traksi karet tangguh untuk gaya hidup dan performa maksimal.',
    ),
    ProductModel(
      id: 'shoe-02',
      name: 'Adidas Ultraboost Light 23',
      category: 'Running',
      price: 3100000,
      rating: 4.8,
      reviewCount: 195,
      imageUrl:
          'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?auto=format&fit=crop&w=800&q=80',
      description:
          'Sepatu lari paling responsif dengan teknologi bantalan Light BOOST 30% lebih ringan, memberikan dorongan energi tanpa henti di setiap kilometer.',
    ),
    ProductModel(
      id: 'shoe-03',
      name: 'Puma Slipstream Retro Bball',
      category: 'Casual',
      price: 1499000,
      rating: 4.7,
      reviewCount: 84,
      imageUrl:
          'https://images.unsplash.com/photo-1608231387042-66d1773070a5?auto=format&fit=crop&w=800&q=80',
      description:
          'Kembalinya siluet basket era 80-an dengan pembaruan modern. Sentuhan suede lembut dan sol karet tebal yang sangat pas untuk outfit harian.',
    ),
    ProductModel(
      id: 'shoe-04',
      name: 'New Balance 550 Vintage White',
      category: 'Casual',
      price: 2099000,
      rating: 4.9,
      reviewCount: 420,
      imageUrl:
          'https://images.unsplash.com/photo-1539185441755-769473a23570?auto=format&fit=crop&w=800&q=80',
      description:
          'Desain clean dan vintage yang mendominasi tren streetwear dunia. Tahan lama, nyaman, dan mudah dipadukan dengan berbagai celana.',
    ),
    ProductModel(
      id: 'shoe-05',
      name: 'Nike ZoomX Vaporfly Next% 3',
      category: 'Running',
      price: 3899000,
      rating: 5.0,
      reviewCount: 118,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
      description:
          'Sepatu marathon kompetisi tercepat dengan pelat serat karbon penuh dan busa ZoomX yang memberikan efisiensi tenaga superior di garis finis.',
    ),
    ProductModel(
      id: 'shoe-06',
      name: 'Converse Chuck 70 Canvas High',
      category: 'Lifestyle',
      price: 999000,
      rating: 4.8,
      reviewCount: 560,
      imageUrl:
          'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?auto=format&fit=crop&w=800&q=80',
      description:
          'Versi premium dari siluet Chuck Taylor klasik dengan kanvas 12oz lebih tebal, jahitan samping vintage, dan insole OrthoLite super empuk.',
    ),
  ];

  // PEMICU: Dipanggil otomatis oleh GetX saat controller pertama kali diinisialisasi.
  // ALUR: Sinkronkan data favorit awal dari database Hive, isi fallback data lokal, dan lakukan fetchProducts().
  @override
  void onInit() {
    super.onInit();
    // Sesi 07: Sinkronisasi data favorit dari database offline Hive CE
    favoriteIds.assignAll(_productRepository.getWishlist().map((e) => e.id));
    // Isi awal dengan data lokal agar UI langsung tampil cepat
    products.assignAll(_initialFallbackProducts);
    // Sesi 05 & 07: Fetch katalog terbaru (dengan fallback offline caching)
    fetchProducts();
  }

  /// Mengambil data katalog produk dari REST API dengan Result sealed class
  // PEMICU: Dipanggil saat onInit() atau saat pengguna melakukan pull-to-refresh.
  // ALUR: Mengaktifkan status loading, memanggil _productRepository.fetchProducts(), menangani Success/Failure.
  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _productRepository.fetchProducts();

    switch (result) {
      case Success(data: final remoteProducts):
        if (remoteProducts.isNotEmpty) {
          products.assignAll(remoteProducts);
        }
      case Failure(error: final error):
        errorMessage.value = error;
        // Tetap sediakan produk lokal jika server tidak dapat diakses
        if (products.isEmpty) {
          products.assignAll(_initialFallbackProducts);
        }
    }

    isLoading.value = false;
  }

  // Sesi 03: Mengambil CartController secara global melalui Dependency Injection
  CartController get cartController {
    if (Get.isRegistered<CartController>()) {
      return Get.find<CartController>();
    }
    return Get.put(CartController());
  }

  // Jumlah badge keranjang membaca langsung dari CartController
  int get cartCount => cartController.totalItemCount;

  // Daftar produk yang difilter sesuai kategori aktif
  List<ProductModel> get filteredProducts {
    if (selectedCategory.value == 'Semua') {
      return products;
    }
    return products
        .where(
          (item) =>
              item.category.toLowerCase() ==
              selectedCategory.value.toLowerCase(),
        )
        .toList();
  }

  // Ubah kategori filter
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  // Tambah item ke keranjang belanja (Memanggil ViewModel CartController)
  void addToCart(ProductModel product) {
    cartController.addItem(product);
  }

  // Sesi 07: Toggle status favorit dan simpan secara persisten ke database Hive CE
  // PEMICU: Ikon hati pada kartu produk diklik oleh pengguna.
  // ALUR: Cari produk berdasarkan id, panggil _productRepository.toggleWishlist, update state favoriteIds, tampilkan feedback snackbar.
  Future<void> toggleFavorite(String productId) async {
    final product = products.firstWhereOrNull((p) => p.id == productId);
    if (product == null) return;

    final isNowFav = await _productRepository.toggleWishlist(product);
    if (isNowFav) {
      favoriteIds.add(productId);
      Get.snackbar(
        'Disimpan ke Wishlist',
        'Sepatu berhasil ditambahkan ke daftar favorit!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.favorite, color: Colors.white),
      );
    } else {
      favoriteIds.remove(productId);
    }
  }

  bool isFavorite(String productId) => favoriteIds.contains(productId);

  // Navigasi ke halaman detail produk berargumen ProductModel
  void openDetail(ProductModel product) {
    Get.toNamed('/detail', arguments: product.toMap());
  }
}
