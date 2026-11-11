import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  String selectedSize;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    this.selectedSize = '42',
    this.quantity = 1,
  });

  // Alias getter & setter untuk properti 'size'
  String get size => selectedSize;
  set size(String val) => selectedSize = val;

  // Hitung subtotal per baris item (mengembalikan int)
  int get subtotal => (product.price * quantity).round();
}
