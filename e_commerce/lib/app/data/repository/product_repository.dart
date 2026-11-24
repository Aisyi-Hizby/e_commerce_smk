import 'package:e_commerce/app/core/network/dio_exception.dart';
import 'package:e_commerce/app/core/network/result.dart';
import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/data/remote/product_remote_datasource.dart';

/// Kontrak abstraksi repository data produk & wishlist (Sesi 05 & 07: Clean Architecture)
// TUJUAN: Menjadi Single Source of Truth (Satu-satunya sumber kebenaran) data produk bagi ViewModel/Controller.
abstract class ProductRepository {
  /// Mengambil data produk dengan strategi cache-first / fallback offline
  Future<Result<List<ProductModel>, String>> fetchProducts();

  /// Mengambil daftar item wishlist dari database offline
  List<ProductModel> getWishlist();

  /// Menambahkan atau menghapus produk dari wishlist (Toggle)
  Future<bool> toggleWishlist(ProductModel product);

  /// Memeriksa status favorit suatu produk
  bool isFavorite(String productId);
}

/// Implementasi nyata ProductRepository dengan Constructor Injection (Remote + Local DataSource)
class ProductRepositoryImpl implements ProductRepository {
  // TUJUAN: Sumber data dari internet melalui DioClient.
  final ProductRemoteDataSource _remoteDataSource;

  // TUJUAN: Sumber data dari disk lokal perangkat melalui Hive CE Box.
  final ProductLocalDataSource _localDataSource;

  /// Constructor Injection: menerima Remote & Local DataSource dari luar (Inversion of Control)
  ProductRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // PEMICU: Dipanggil saat HomeController meminta daftar produk terbaru.
  // ALUR:
  // 1. Coba request data ke server API melalui _remoteDataSource.
  // 2. Jika sukses, simpan salinan produk ke cache Hive via _localDataSource.cacheProducts().
  // 3. Jika gagal jaringan (NetworkFailure), ambil data offline dari _localDataSource.getCachedProducts().
  // 4. Jika offline cache tersedia, tetap return Success(cachedProducts) sehingga pengguna tidak melihat layar error!
  @override
  Future<Result<List<ProductModel>, String>> fetchProducts() async {
    try {
      // 1. Coba ambil data terbaru dari server remote
      final remoteProducts = await _remoteDataSource.fetchProducts();

      // 2. Jika sukses, simpan salinan ke dalam cache lokal Hive
      if (remoteProducts.isNotEmpty) {
        await _localDataSource.cacheProducts(remoteProducts);
      }

      return Success(remoteProducts);
    } on NetworkFailure catch (e) {
      // 3. Fallback Offline: jika server gagal atau offline, ambil dari cache lokal Hive
      final cachedProducts = _localDataSource.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return Success(cachedProducts);
      }
      return Failure(e.message);
    } catch (e) {
      final cachedProducts = _localDataSource.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return Success(cachedProducts);
      }
      return Failure('Gagal memuat katalog produk: ${e.toString()}');
    }
  }

  // PEMICU: Mengambil seluruh daftar produk yang ada di wishlist lokal.
  // ALUR: Diteruskan langsung ke _localDataSource.getWishlist().
  @override
  List<ProductModel> getWishlist() {
    return _localDataSource.getWishlist();
  }

  // PEMICU: Pengguna menekan ikon favorit (hati) pada kartu produk.
  // ALUR: Cek apakah produk sudah favorit; jika ya, hapus; jika belum, simpan. Mengembalikan boolean status baru.
  @override
  Future<bool> toggleWishlist(ProductModel product) async {
    final alreadyFav = _localDataSource.isFavorite(product.id);
    if (alreadyFav) {
      await _localDataSource.removeFromWishlist(product.id);
      return false;
    } else {
      await _localDataSource.saveToWishlist(product);
      return true;
    }
  }

  // PEMICU: Memeriksa apakah suatu produk sedang berstatus favorit di memori lokal.
  @override
  bool isFavorite(String productId) {
    return _localDataSource.isFavorite(productId);
  }
}
