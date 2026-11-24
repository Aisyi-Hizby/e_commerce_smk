import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

part 'product_model.g.dart';

/// Model Data Produk Sepatu (Type-Safe Entity & Hive CE Object)
// TUJUAN: Anotasi @HiveType mendefinisikan class ini sebagai entitas yang bisa diserialisasi ke Hive CE.
// NILAI typeId: 0 adalah nomor registrasi unik di Hive (jangan tertukar dengan model lain).
@HiveType(typeId: 0)
class ProductModel {
  // TUJUAN: ID unik produk untuk primary key di Hive Box dan identifikasi navigasi.
  @HiveField(0)
  final String id;

  // TUJUAN: Nama model sepatu (contoh: 'Nike Air Jordan 1 High OG').
  @HiveField(1)
  final String name;

  // TUJUAN: Kategori produk untuk penyaringan/filter di HomeView (contoh: 'Basketball', 'Running').
  @HiveField(2)
  final String category;

  // TUJUAN: Harga produk dalam integer Rupiah (tanpa desimal).
  @HiveField(3)
  final int price;

  // TUJUAN: Nilai ulasan pembeli (skala 0.0 - 5.0) untuk badge bintang di kartu produk.
  @HiveField(4)
  final double rating;

  // TUJUAN: Total ulasan yang diterima produk untuk meyakinkan pembeli.
  @HiveField(5)
  final int reviewCount;

  // TUJUAN: URL foto sepatu di internet (Unsplash / CDN DummyJSON).
  @HiveField(6)
  final String imageUrl;

  // TUJUAN: Uraian spesifikasi material dan kenyamanan sepatu di halaman detail.
  @HiveField(7)
  final String description;

  // TUJUAN: Penanda status apakah produk difavoritkan oleh pengguna.
  @HiveField(8)
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    this.isFavorite = false,
  });

  /// Format harga ke mata uang Rupiah
  // PEMICU: Dipanggil saat widget Text ingin menampilkan harga format Indonesia (Rp 2.499.000).
  // ALUR: Menggunakan pustaka NumberFormat dari package intl dengan locale id_ID.
  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  /// Membuat salinan objek dengan modifikasi parsial (Immutable state update)
  // PEMICU: Dipanggil saat memperbarui status isFavorite tanpa mengubah properti lainnya.
  // ALUR: Mengembalikan instance ProductModel baru dengan nilai parameter yang ditimpa.
  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    int? price,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? description,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Konversi dari Map / JSON internal
  // PEMICU: Mengonversi data Map lokal ke objek ProductModel type-safe.
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      price: (map['price'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  /// Factory deserialisasi defensif dari JSON respons REST API (Sesi 05: DummyJSON atau API eksternal)
  // PEMICU: Dipanggil saat menerima payload JSON dari DioClient.
  // ALUR: Melakukan parsing nilai aman dengan fallback default untuk mencegah crash null-pointer.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId != null
        ? rawId.toString()
        : 'prod-${DateTime.now().millisecondsSinceEpoch}';

    final name = (json['title'] ?? json['name'] ?? 'Sepatu Sneakers')
        .toString();
    final rawCategory = (json['category'] ?? 'Lifestyle').toString();
    final category = rawCategory.isNotEmpty
        ? '${rawCategory[0].toUpperCase()}${rawCategory.substring(1)}'
        : 'General';

    // Konversi harga: jika nilai < 1000 (harga USD DummyJSON), konversi ke Rupiah (~15.000)
    final rawPrice = (json['price'] as num?)?.toInt() ?? 150000;
    final price = rawPrice < 1000 ? rawPrice * 15000 : rawPrice;

    final rating = (json['rating'] as num?)?.toDouble() ?? 4.8;

    int reviewCount = 0;
    if (json['reviews'] is List) {
      reviewCount = (json['reviews'] as List).length;
    } else if (json['reviewCount'] != null) {
      reviewCount = (json['reviewCount'] as num).toInt();
    } else {
      reviewCount = 50 + (price % 150);
    }

    final imageUrl =
        (json['thumbnail'] ??
                json['imageUrl'] ??
                'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80')
            .toString();

    final description =
        (json['description'] ??
                'Sepatu sneakers berkualitas tinggi dengan bantalan empuk dan daya tahan luar biasa untuk gaya kasual dan olahraga.')
            .toString();

    return ProductModel(
      id: id,
      name: name,
      category: category,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      imageUrl: imageUrl,
      description: description,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Konversi ke Map
  // PEMICU: Dipanggil saat mengirim argumen navigasi Get.toNamed('/detail', arguments: product.toMap()).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'description': description,
      'isFavorite': isFavorite,
    };
  }

  /// Konversi ke JSON
  Map<String, dynamic> toJson() => toMap();
}
