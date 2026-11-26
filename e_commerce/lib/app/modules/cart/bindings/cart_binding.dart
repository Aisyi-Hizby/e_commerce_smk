import 'package:get/get.dart';

import 'package:e_commerce/app/data/local/cart_local_datasource.dart';
import '../controllers/cart_controller.dart';

/// Binding Modul Keranjang Belanja (Sesi 03 & 08: Dependency Injection)
class CartBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Daftarkan DataSource lokal jika belum ada di GetX pool
    if (!Get.isRegistered<CartLocalDataSource>()) {
      Get.lazyPut<CartLocalDataSource>(() => CartLocalDataSourceImpl());
    }
    // 2. Suntikkan CartLocalDataSource ke dalam CartController
    Get.lazyPut<CartController>(
      () => CartController(localDataSource: Get.find<CartLocalDataSource>()),
    );
  }
}
