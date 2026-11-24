import 'package:get/get.dart';

import 'package:e_commerce/app/core/network/dio_client.dart';
import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/remote/product_remote_datasource.dart';
import 'package:e_commerce/app/data/repository/product_repository.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import '../controllers/home_controller.dart';

/// Sesi 03, 05 & 07: Dependency Injection via Binding (Clean Architecture mobodrive)
// TUJUAN: Menyiapkan seluruh dependensi (Client, DataSource, Repository, Controller) secara modular sebelum HomeView dirender.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core Network: DioClient terpusat
    Get.lazyPut<DioClient>(() => DioClient());

    // 2. Data Sources: Remote & Local (Hive CE)
    Get.lazyPut<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(Get.find<DioClient>()),
    );
    Get.lazyPut<ProductLocalDataSource>(() => ProductLocalDataSourceImpl());

    // 3. Repository: Abstraksi Repository yang menerima Remote & Local DataSource
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(
        Get.find<ProductRemoteDataSource>(),
        Get.find<ProductLocalDataSource>(),
      ),
    );

    // 4. Cart Controller: State global keranjang belanja
    Get.lazyPut<CartController>(() => CartController());

    // 5. Home Controller: Menerima ProductRepository via Constructor Injection
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<ProductRepository>()),
    );
  }
}
