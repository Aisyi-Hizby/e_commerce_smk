import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'product_model.dart';

part 'cart_item_model.g.dart';

/// Model Item Keranjang Belanja (Type-Safe Entity & Hive CE Object)
// TUJUAN: Anotasi @HiveType mendefinisikan CartItemModel sebagai entitas yang bisa diserialisasi ke basis data Hive CE.
// NILAI typeId: 1 adalah nomor registrasi unik di Hive (berbeda dari ProductModel yang bernomor 0).
@HiveType(typeId: 1)
class CartItemModel {
  // TUJUAN: Kunci identifikasi unik item keranjang (kombinasi id produk dan ukuran, misal: 'shoe-01_42').
  @HiveField(0)
  final String id;

  // TUJUAN: Objek lengkap sepatu yang dibeli (nama, kategori, harga, gambar).
  @HiveField(1)
  final ProductModel product;

  // TUJUAN: Ukuran sepatu yang dipilih oleh pembeli (misal: '40', '41', '42').
  @HiveField(2)
  final String selectedSize;

  // TUJUAN: Kuantitas pasang sepatu yang dipesan dalam item ini.
  // MENGAPA BUKAN final: Nilai quantity dapat bertambah atau berkurang saat pengguna menekan tombol (+) atau (-).
  @HiveField(3)
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    required this.selectedSize,
    this.quantity = 1,
  });

  /// Total harga untuk item ini (Harga Satuan x Jumlah)
  // PEMICU: Dipanggil saat kalkulasi rincian subtotal per baris sepatu di keranjang dan checkout.
  int get subtotal => product.price * quantity;

  /// Format harga total per item ke Rupiah
  // PEMICU: Menampilkan teks harga rupiah yang rapi di kartu item keranjang (contoh: 'Rp 4.998.000').
  String get formattedSubtotal {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(subtotal);
  }

  /// Membuat salinan objek dengan modifikasi parsial
  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    String? selectedSize,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Konversi dari Map / JSON internal
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as String? ?? '',
      product: ProductModel.fromMap(
        map['product'] as Map<String, dynamic>? ?? {},
      ),
      selectedSize: map['selectedSize'] as String? ?? '42',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  /// Konversi ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'selectedSize': selectedSize,
      'quantity': quantity,
    };
  }
}
