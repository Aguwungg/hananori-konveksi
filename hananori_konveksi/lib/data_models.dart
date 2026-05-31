import 'package:firebase_database/firebase_database.dart';

class ProductItem {
  String name;
  String mainAssetPath;
  String minOrder;
  ProductItem({required this.name, required this.mainAssetPath, required this.minOrder});
}

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
  String aboutText;
  String waNumber;
  String igUsername;
  CompanyProfileData({required this.aboutText, required this.waNumber, required this.igUsername});
}

final DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('orders');

CompanyProfileData globalCompanyProfile = CompanyProfileData(
  aboutText: 'Harga murah kualitas mewah, bukan yang lain! We are a leading fashion house specializing in streetwear and organization apparel.',
  waNumber: '089508178707',
  igUsername: '@hananorikonveksi',
);

List<ProductItem> hoodiesDataList = [
  ProductItem(name: 'Classic Knit Hoodie 1', mainAssetPath: 'assets/images/products/hodie 1(1).jpeg', minOrder: '200'),
  ProductItem(name: 'Comfort Fleece Hoodie 2', mainAssetPath: 'assets/images/products/hodie 2(1).jpeg', minOrder: '150'),
  ProductItem(name: 'Minimalist Hoodie 3', mainAssetPath: 'assets/images/products/hodie 3(1).jpeg', minOrder: '200'),
  ProductItem(name: 'Premium Streetwear Hoodie 4', mainAssetPath: 'assets/images/products/hodie 4(1).jpeg', minOrder: '100'),
  ProductItem(name: 'Basic Daily Hoodie 5', mainAssetPath: 'assets/images/products/hodie 1(2).jpeg', minOrder: '250'),
];

final List<String> sopStages = [
  'Redesain & Fiksasi', 'Pembelian Bahan', 'Potong', 'Bordir/Sablon', 'Jahit', 'Finishing', 'Barang Siap'
];