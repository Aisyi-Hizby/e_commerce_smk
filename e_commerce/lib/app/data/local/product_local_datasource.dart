import 'package:hive_ce/hive.dart';
import 'package:e_commerce/app/data/models/product_model.dart';

/// Kontrak DataSource Lokal untuk data produk dan wishlist (Sesi 07: Hive CE CRUD)
// TUJUAN: Abstraksi akses basis data lokal agar repository independen dari pustaka Hive.
abstract class ProductLocalDataSource {
  /// Menyimpan daftar produk ke dalam cache offline Hive
  Future<void> cacheProducts(List<ProductModel> products);

  /// Mengambil daftar produk dari cache offline
  List<ProductModel> getCachedProducts();

  /// Menambahkan atau memperbarui item di wishlist favorit
  Future<void> saveToWishlist(ProductModel product);

  /// Menghapus item dari wishlist favorit
  Future<void> removeFromWishlist(String productId);

  /// Mengambil seluruh item wishlist yang tersimpan
  List<ProductModel> getWishlist();

  /// Memeriksa apakah sebuah produk merupakan favorit
  bool isFavorite(String productId);

  /// Stream perubahan data wishlist untuk update reaktif
  Stream<BoxEvent> watchWishlist();
}

/// Implementasi nyata ProductLocalDataSource menggunakan Hive CE Box
class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  // TUJUAN: Nama Box penyimpanan data katalog sepatu yang di-cache dari API.
  static const String productsBoxName = 'products_box';

  // TUJUAN: Nama Box penyimpanan data sepatu yang difavoritkan oleh pengguna.
  static const String wishlistBoxName = 'wishlist_box';

  // TUJUAN: Mengambil instance Box 'products_box' bertipe ProductModel yang sudah dibuka di StorageService.
  Box<ProductModel> get _productsBox => Hive.box<ProductModel>(productsBoxName);

  // TUJUAN: Mengambil instance Box 'wishlist_box' bertipe ProductModel yang sudah dibuka di StorageService.
  Box<ProductModel> get _wishlistBox => Hive.box<ProductModel>(wishlistBoxName);

  // PEMICU: Dipanggil saat katalog berhasil diambil dari server oleh ProductRepository.
  // ALUR: Mengonversi list produk menjadi Map id -> product lalu menyimpannya sekaligus ke Hive Box via putAll.
  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final Map<String, ProductModel> map = {for (final p in products) p.id: p};
    await _productsBox.putAll(map);
  }

  // PEMICU: Dipanggil saat perangkat offline atau server gagal merespons.
  // ALUR: Membaca seluruh nilai yang tersimpan di _productsBox dan mengembalikannya sebagai List<ProductModel>.
  @override
  List<ProductModel> getCachedProducts() {
    return _productsBox.values.toList();
  }

  // PEMICU: Dipanggil saat ikon hati di kartu produk ditekan dan belum difavoritkan.
  // ALUR: Menulis produk dengan isFavorite: true ke dalam _wishlistBox menggunakan id produk sebagai kuncinya.
  @override
  Future<void> saveToWishlist(ProductModel product) async {
    await _wishlistBox.put(product.id, product.copyWith(isFavorite: true));
  }

  // PEMICU: Dipanggil saat ikon hati ditekan ulang atau tombol hapus di WishlistView diklik.
  // ALUR: Menghapus data produk dari _wishlistBox berdasarkan productId.
  @override
  Future<void> removeFromWishlist(String productId) async {
    await _wishlistBox.delete(productId);
  }

  // PEMICU: Dipanggil saat WishlistController menginisialisasi daftar produk favorit.
  // ALUR: Mengambil seluruh objek ProductModel yang ada di dalam _wishlistBox.
  @override
  List<ProductModel> getWishlist() {
    return _wishlistBox.values.toList();
  }

  // PEMICU: Memeriksa apakah id sepatu tertentu sudah ada di dalam _wishlistBox.
  // ALUR: Mengecek apakah key productId terdaftar di dalam Hive Box.
  @override
  bool isFavorite(String productId) {
    return _wishlistBox.containsKey(productId);
  }

  // PEMICU: Mengamati perubahan data secara langsung di dalam box wishlist.
  // ALUR: Mengembalikan stream BoxEvent saat ada operasi put/delete.
  @override
  Stream<BoxEvent> watchWishlist() {
    return _wishlistBox.watch();
  }
}
