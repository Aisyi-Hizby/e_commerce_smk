import 'package:get/get.dart';

import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';

/// Binding Modul Checkout (Sesi 08: Dependency Injection)
class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CartController>()) {
      Get.lazyPut<CartController>(() => CartController());
    }
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
