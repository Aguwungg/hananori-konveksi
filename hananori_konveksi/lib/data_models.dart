import 'package:firebase_database/firebase_database.dart';

class ProductItem {
  String id;
  String name;
  String mainAssetPath;
  String minOrder;
  String description;
  String category;
  String displaySection;

  ProductItem({
    required this.id, 
    required this.name, 
    required this.mainAssetPath, 
    required this.minOrder, 
    this.description = 'A premium apparel piece.',
    this.category = 'Lainnya',
    this.displaySection = 'Standard',
  });

  factory ProductItem.fromMap(String key, Map<dynamic, dynamic> map) {
    return ProductItem(
      id: key,
      name: map['name']?.toString() ?? '',
      mainAssetPath: map['mainAssetPath']?.toString() ?? '',
      minOrder: map['minOrder']?.toString() ?? '',
      description: map['description']?.toString() ?? 'A premium apparel piece.',
      category: map['category']?.toString() ?? 'Lainnya',
      displaySection: map['displaySection']?.toString() ?? 'Standard',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mainAssetPath': mainAssetPath,
      'minOrder': minOrder,
      'description': description,
      'category': category,
      'displaySection': displaySection,
    };
  }
}

final DatabaseReference productsRef = FirebaseDatabase.instance.ref().child('products');

class OrderData {
  String idPesanan;
  String namaPelanggan;
  String nomorWa;
  String produk;
  String imagePath; 
  int qty;
  String tglDp;
  String estimasiSelesai;
  String statusProduksi;

  OrderData({
    required this.idPesanan, required this.namaPelanggan, required this.nomorWa,
    required this.produk, required this.imagePath, required this.qty,
    required this.tglDp, required this.estimasiSelesai, required this.statusProduksi
  });

  factory OrderData.fromMap(Map<dynamic, dynamic> map) {
    return OrderData(
      idPesanan: map['idPesanan']?.toString() ?? '',
      namaPelanggan: map['namaPelanggan']?.toString() ?? '',
      nomorWa: map['nomorWa']?.toString() ?? '',
      produk: map['produk']?.toString() ?? '',
      imagePath: map['imagePath']?.toString() ?? '',
      qty: map['qty'] != null ? int.tryParse(map['qty'].toString()) ?? 0 : 0,
      tglDp: map['tglDp']?.toString() ?? '',
      estimasiSelesai: map['estimasiSelesai']?.toString() ?? '',
      statusProduksi: map['statusProduksi']?.toString() ?? 'Redesain & Fiksasi',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idPesanan': idPesanan,
      'namaPelanggan': namaPelanggan,
      'nomorWa': nomorWa,
      'produk': produk,
      'imagePath': imagePath,
      'qty': qty,
      'tglDp': tglDp,
      'estimasiSelesai': estimasiSelesai,
      'statusProduksi': statusProduksi,
    };
  }
}

class CompanyProfileData {
  String? aboutText;
  String? waNumber;
  String? igUsername;
  String? slogan;
  String? foundedYear;
  String? totalClients;
  String? projectsDone;
  String? fiveStarReviews;
  String? testimonials;
  
  CompanyProfileData({
    this.aboutText, this.waNumber, this.igUsername,
    this.slogan, this.foundedYear, this.totalClients,
    this.projectsDone, this.fiveStarReviews, this.testimonials
  });
}

final DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('orders');

CompanyProfileData globalCompanyProfile = CompanyProfileData(
  aboutText: 'Harga murah kualitas mewah, bukan yang lain! We are a leading fashion house specializing in streetwear and organization apparel.',
  waNumber: '089508178707',
  igUsername: '@hananorikonveksi',
  slogan: 'Harga murah kualitas mewah, bukan yang lain',
  foundedYear: '2022',
  totalClients: '102',
  projectsDone: '140',
  fiveStarReviews: '102',
  testimonials: 'Budi Santoso - Kualitas baju dari Hananori luar biasa! Jahitannya sangat rapi dan bahannya nyaman dipakai seharian.|Siti Aminah - Sangat direkomendasikan untuk event organisasi. Pesan 100 pcs selesai tepat waktu dan ukurannya pas semua.|Andi Pratama - Pelayanan ramah, admin responsif, dan pesanan cepat selesai! Pasti akan pesan lagi untuk project kampus berikutnya.|Rina Wati - Warnanya sesuai ekspektasi dan sablonnya kuat tidak mudah pecah. Terima kasih Hananori Konveksi!|Dimas Anggara - Pesan jaket angkatan di sini hasilnya memuaskan banget. Keren, stylish, dan bahannya tebal.|Ayu Kinanti - Harganya sangat terjangkau tapi kualitasnya berani diadu dengan konveksi besar. Keren pol!|Tono Hermawan - Kemeja korsa BEM kami hasilnya elegan. Bordirannya presisi dan terlihat sangat profesional.|Maya Sari - Baru pertama kali pesan di sini dan tidak menyesal. Update progresnya jelas jadi tidak khawatir.|Fadil Hakim - Terbaik! Pengerjaan sangat cepat walau saya minta deadline yang cukup mepet.|Nisa Fadilah - Bahan kain yang direkomendasikan admin ternyata memang enak banget dipakai.|Kevin Julian - Pilihan vendor konveksi langganan kantor! Jaket seragam perusahaan selalu dipercayakan ke sini.|Lestari - Barang datang sesuai jumlah dan tidak ada cacat produksi sama sekali. QC-nya juara!|Hendra - Detail desain kustom kami dieksekusi dengan sangat sempurna. Benar-benar sesuai desain awal.|Putri Rahma - Transparan dan harganya ramah di kantong. Terima kasih untuk kerjasamanya!|Reza - Sablonnya merekat sempurna, sudah dicuci berkali-kali tidak mengelupas. Good job Hananori!',
);

List<ProductItem> hoodiesDataList = [
  ProductItem(id: 'prod_1', name: 'Classic Knit Hoodie 1', mainAssetPath: 'assets/images/products/hodie 1(1).jpeg', minOrder: '200', description: 'Hoodie klasik bahan rajut premium untuk cuaca dingin.', category: 'Hoodie'),
  ProductItem(id: 'prod_2', name: 'Comfort Fleece Hoodie 2', mainAssetPath: 'assets/images/products/hodie 2(1).jpeg', minOrder: '150', description: 'Hoodie fleece tebal namun sangat nyaman dan breathable.', category: 'Hoodie'),
  ProductItem(id: 'prod_3', name: 'Minimalist Hoodie 3', mainAssetPath: 'assets/images/products/hodie 3(1).jpeg', minOrder: '200', description: 'Desain minimalis tanpa saku kanguru untuk kesan modern.', category: 'Hoodie'),
  ProductItem(id: 'prod_4', name: 'Premium Streetwear Hoodie 4', mainAssetPath: 'assets/images/products/hodie 4(1).jpeg', minOrder: '100', description: 'Produk unggulan dengan potongan oversize streetwear.', category: 'Hoodie'),
  ProductItem(id: 'prod_5', name: 'Basic Daily Hoodie 5', mainAssetPath: 'assets/images/products/hodie 1(2).jpeg', minOrder: '250', description: 'Hoodie kasual sehari-hari dengan berbagai pilihan warna.', category: 'Hoodie'),
];

const List<String> productCategories = ['T-Shirt', 'Hoodie', 'Jaket', 'Kemeja', 'Seragam', 'Lainnya'];
const List<String> highlightSections = ['Best Seller', 'New Arrival', 'Promo'];

/// Mengubah data mentah Firebase menjadi daftar produk.
/// Jika database kosong, memakai data statis sebagai cadangan.
List<ProductItem> parseProducts(Object? raw) {
  final List<ProductItem> list = [];
  if (raw is Map) {
    raw.forEach((k, v) {
      if (v is Map) list.add(ProductItem.fromMap(k.toString(), v));
    });
    list.sort((a, b) => a.id.compareTo(b.id));
  }
  return list.isEmpty ? List<ProductItem>.of(hoodiesDataList) : list;
}

Stream<List<ProductItem>> productsStream() => productsRef.onValue.map((e) => parseProducts(e.snapshot.value));

Future<List<ProductItem>> fetchProductsOnce() async {
  try {
    final snap = await productsRef.get();
    return parseProducts(snap.value);
  } catch (_) {
    return List<ProductItem>.of(hoodiesDataList);
  }
}

/// Daftar kategori yang benar-benar dipakai produk (urutan mengikuti [productCategories]).
List<String> availableCategories(List<ProductItem> products) {
  final present = products.map((p) => p.category).toSet();
  return [
    ...productCategories.where(present.contains),
    ...present.where((c) => !productCategories.contains(c)),
  ];
}

final List<String> sopStages = [
  'Redesain & Fiksasi', 'Pembelian Bahan', 'Potong', 'Bordir/Sablon', 'Jahit', 'Finishing', 'Barang Siap'
];