import 'package:hive_ce/hive.dart';
import 'package:e_commerce/app/data/models/cart_item_model.dart';

/// Kontrak DataSource Lokal untuk data keranjang belanja (Sesi 08: Hive CE Cart Persistence)
// TUJUAN: Abstraksi penyimpanan lokal agar CartController independen dari pustaka database.
abstract class CartLocalDataSource {
  /// Menyimpan atau memperbarui item di keranjang belanja Hive
  Future<void> saveCartItem(CartItemModel item);

  /// Menghapus item dari keranjang belanja Hive
  Future<void> removeCartItem(String cartItemId);

  /// Mengambil semua item keranjang yang tersimpan di Hive
  List<CartItemModel> getCartItems();

  /// Mengosongkan seluruh keranjang belanja (setelah checkout selesai)
  Future<void> clearCart();

  /// Stream perubahan data keranjang untuk reaktivitas
  Stream<BoxEvent> watchCart();
}

/// Implementasi nyata CartLocalDataSource menggunakan Hive CE Box
class CartLocalDataSourceImpl implements CartLocalDataSource {
  // TUJUAN: Nama box fisik penyimpanan data keranjang belanja di memori perangkat.
  static const String cartBoxName = 'cart_box';

  // TUJUAN: Mengambil instance Box 'cart_box' bertipe CartItemModel yang sudah dibuka di StorageService.
  Box<CartItemModel> get _cartBox => Hive.box<CartItemModel>(cartBoxName);

  // PEMICU: Dipanggil setiap kali ada penambahan sepatu baru atau perubahan kuantitas (+/-).
  // ALUR: Menyimpan objek CartItemModel ke dalam box dengan kunci item.id.
  @override
  Future<void> saveCartItem(CartItemModel item) async {
    await _cartBox.put(item.id, item);
  }

  // PEMICU: Pengguna menekan ikon tong sampah pada baris item di halaman keranjang.
  // ALUR: Menghapus data dari box berdasarkan kunci cartItemId.
  @override
  Future<void> removeCartItem(String cartItemId) async {
    await _cartBox.delete(cartItemId);
  }

  // PEMICU: Dipanggil saat aplikasi pertama kali dibuka (onInit di CartController).
  // ALUR: Membaca seluruh item yang tersimpan di box dan mengembalikannya sebagai List<CartItemModel>.
  @override
  List<CartItemModel> getCartItems() {
    return _cartBox.values.toList();
  }

  // PEMICU: Dipanggil saat pesanan berhasil dibayar di halaman checkout.
  // ALUR: Mengosongkan seluruh isi box cart_box tanpa sisa.
  @override
  Future<void> clearCart() async {
    await _cartBox.clear();
  }

  // PEMICU: Mengamati event perubahan data di dalam box secara real-time.
  @override
  Stream<BoxEvent> watchCart() {
    return _cartBox.watch();
  }
}
