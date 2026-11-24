import 'package:get/get.dart';

import 'package:e_commerce/app/core/network/dio_client.dart';
import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/remote/product_remote_datasource.dart';
import 'package:e_commerce/app/data/repository/product_repository.dart';
import '../controllers/wishlist_controller.dart';

/// Sesi 07: Dependency Injection untuk Wishlist (Hive CE Repository)
// TUJUAN: Memastikan dependensi DataSource dan Repository tersedia saat pengguna membuka rute '/wishlist'.
class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Pastikan DioClient tersedia
    if (!Get.isRegistered<DioClient>()) {
      Get.lazyPut<DioClient>(() => DioClient());
    }

    // 2. Pastikan ProductRemoteDataSource tersedia
    if (!Get.isRegistered<ProductRemoteDataSource>()) {
      Get.lazyPut<ProductRemoteDataSource>(
        () => ProductRemoteDataSourceImpl(Get.find<DioClient>()),
      );
    }

    // 3. Pastikan ProductLocalDataSource (Hive CE) terdaftar
    if (!Get.isRegistered<ProductLocalDataSource>()) {
      Get.lazyPut<ProductLocalDataSource>(() => ProductLocalDataSourceImpl());
    }

    // 4. Pastikan ProductRepository terdaftar dengan injeksi Remote & Local DataSource
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepositoryImpl(
          Get.find<ProductRemoteDataSource>(),
          Get.find<ProductLocalDataSource>(),
        ),
      );
    }

    // 5. Daftarkan WishlistController dengan menginjeksi ProductRepository
    Get.lazyPut<WishlistController>(
      () => WishlistController(Get.find<ProductRepository>()),
    );
  }
}
