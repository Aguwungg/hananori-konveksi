import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'data_models.dart';
import 'mobile_views.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          Container(
            width: 260, color: Colors.black,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const CircleAvatar(backgroundColor: Colors.white, radius: 30, child: Text('H', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 24))),
                const SizedBox(height: 16),
                const Text('ADMIN PANEL', style: TextStyle(fontFamily: 'IntegralCF', color: Colors.white, fontSize: 18)),
                const Text('CV. Hananori Konveksi', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 40),
                
                _buildSidebarItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Order Dashboard'),
                _buildSidebarItem(1, Icons.people_outline, Icons.people, 'Customers'),
                _buildSidebarItem(2, Icons.inventory_2_outlined, Icons.inventory_2, 'Inventory / Products'),
                _buildSidebarItem(3, Icons.settings_outlined, Icons.settings, 'Profile Settings'),
                
                const Spacer(),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.phone_android, color: Colors.grey),
                  title: const Text('Lihat Versi Mobile', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(child: Padding(padding: const EdgeInsets.all(32.0), child: _buildCurrentView()))
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0: return _buildOrdersView();
      case 1: return _buildCustomersView();
      case 2: return _buildInventoryView();
      case 3: return _buildSettingsView();
      default: return _buildOrdersView();
    }
  }

  Widget _buildSidebarItem(int index, IconData icon, IconData activeIcon, String title) {
    bool isActive = _selectedIndex == index;
    return ListTile(
      leading: Icon(isActive ? activeIcon : icon, color: isActive ? Colors.white : Colors.grey),
      title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      tileColor: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildOrdersView() {
    return StreamBuilder<DatabaseEvent>(
      stream: ordersRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        List<OrderData> ordersList = [];
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          ordersList = dataMap.values.map((e) => OrderData.fromMap(e as Map<dynamic, dynamic>)).toList();
        }

        int totalOrders = ordersList.length;
        int inProduction = ordersList.where((o) => o.statusProduksi != 'Barang Siap').length;
        int readyToPickup = ordersList.where((o) => o.statusProduksi == 'Barang Siap').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ORDER MANAGEMENT', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 32)),
                ElevatedButton.icon(
                  onPressed: () => _showOrderFormDialog(),
                  icon: const Icon(Icons.add), label: const Text('Buat Pesanan Baru'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                )
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _buildSummaryCard('Total Pesanan', totalOrders.toString(), Icons.shopping_bag_outlined), const SizedBox(width: 24),
                _buildSummaryCard('Dalam Produksi', inProduction.toString(), Icons.cached), const SizedBox(width: 24),
                _buildSummaryCard('Siap Diambil', readyToPickup.toString(), Icons.check_circle_outline),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Klik pada baris pesanan untuk memperbarui tahapan SOP.', style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                child: SingleChildScrollView(
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                    columns: const [
                      DataColumn(label: Text('ID PESANAN', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('GAMBAR', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('PELANGGAN', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('PRODUK', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('STATUS PRODUKSI (SOP)', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: ordersList.map((order) => DataRow(
                      onSelectChanged: (_) => _showSOPUpdateDialog(order),
                      cells: [
                        DataCell(Text(order.idPesanan, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(order.imagePath, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey))),
                          )
                        ),
                        DataCell(Text(order.namaPelanggan)),
                        DataCell(Text('${order.qty} pcs - ${order.produk}')),
                        DataCell(_buildStatusBadge(order.statusProduksi)),
                      ]
                    )).toList(),
                  ),
                ),
              ),
            )
          ],
        );
      }
    );
  }

  void _showOrderFormDialog({OrderData? existingOrder}) {
    final TextEditingController idCtrl = TextEditingController(text: existingOrder?.idPesanan ?? 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    final TextEditingController nameCtrl = TextEditingController(text: existingOrder?.namaPelanggan ?? '');
    final TextEditingController waCtrl = TextEditingController(text: existingOrder?.nomorWa ?? '');
    final TextEditingController prodCtrl = TextEditingController(text: existingOrder?.produk ?? '');
    final TextEditingController qtyCtrl = TextEditingController(text: existingOrder?.qty.toString() ?? '');
    final TextEditingController dpCtrl = TextEditingController(text: existingOrder?.tglDp ?? '2026-05-15');
    final TextEditingController estCtrl = TextEditingController(text: existingOrder?.estimasiSelesai ?? '2026-06-15');
    
    String selectedStage = existingOrder?.statusProduksi ?? sopStages[0];
    String selectedImage = existingOrder?.imagePath ?? (hoodiesDataList.isNotEmpty ? hoodiesDataList[0].mainAssetPath : 'assets/images/products/1.jpeg');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(existingOrder == null ? 'BUAT PESANAN BARU' : 'EDIT PESANAN', style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 20)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAdminTextField('ID Pesanan', idCtrl, isEnabled: existingOrder == null),
                      _buildAdminTextField('Nama Pelanggan', nameCtrl),
                      _buildAdminTextField('Nomor WhatsApp', waCtrl),
                      _buildAdminTextField('Jenis Produk (Nama)', prodCtrl),
                      _buildAdminTextField('Jumlah (Qty)', qtyCtrl, isNumber: true),
                      
                      const SizedBox(height: 16),
                      const Text('Pilih Gambar Acuan Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true, value: selectedImage,
                            items: hoodiesDataList.map((p) => DropdownMenuItem(value: p.mainAssetPath, child: Text(p.name))).toList(),
                            onChanged: (val) { if(val != null) setDialogState(() => selectedImage = val); },
                          ),
                        ),
                      ),
                      
                      _buildAdminTextField('Tanggal DP (YYYY-MM-DD)', dpCtrl),
                      _buildAdminTextField('Estimasi Selesai (YYYY-MM-DD)', estCtrl),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () async {
                    if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
                    
                    OrderData newOrder = OrderData(
                      idPesanan: idCtrl.text, namaPelanggan: nameCtrl.text, nomorWa: waCtrl.text,
                      produk: prodCtrl.text, imagePath: selectedImage, qty: int.tryParse(qtyCtrl.text) ?? 0, 
                      tglDp: dpCtrl.text, estimasiSelesai: estCtrl.text, statusProduksi: selectedStage
                    );

                    await ordersRef.child(idCtrl.text).set(newOrder.toMap());
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil disimpan ke database!'), backgroundColor: Colors.green));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  child: const Text('Simpan Pesanan'),
                )
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildAdminTextField(String label, TextEditingController controller, {bool isNumber = false, bool isEnabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextField(
        controller: controller, enabled: isEnabled, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey, fontSize: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      ),
    );
  }

  void _showSOPUpdateDialog(OrderData order) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        int currentIdx = sopStages.indexOf(order.statusProduksi);
        bool isComplete = currentIdx == sopStages.length - 1;
        String nextStage = isComplete ? 'Sudah Selesai' : sopStages[currentIdx + 1];

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('UPDATE STATUS: ${order.idPesanan}', style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pelanggan: ${order.namaPelanggan}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              const Text('TAHAPAN SAAT INI:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(12), width: double.infinity, decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(order.statusProduksi, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 18))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: isComplete ? null : () async {
                    await ordersRef.child(order.idPesanan).update({'statusProduksi': nextStage});
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Progres dimajukan ke: $nextStage'), backgroundColor: Colors.green));
                    }
                  },
                  icon: const Icon(Icons.arrow_forward), label: Text('LANJUTKAN KE: $nextStage', style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () { 
              Navigator.pop(ctx);
              _showOrderFormDialog(existingOrder: order); 
            }, child: const Text('Edit Detail Pesanan', style: TextStyle(color: Colors.blue))),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup', style: TextStyle(color: Colors.black)))
          ],
        );
      }),
    );
  }

  Widget _buildCustomersView() {
    return StreamBuilder<DatabaseEvent>(
      stream: ordersRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        List<OrderData> ordersList = [];
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          ordersList = dataMap.values.map((e) => OrderData.fromMap(e as Map<dynamic, dynamic>)).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CUSTOMER DIRECTORY', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 32)),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                itemCount: ordersList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.8, crossAxisSpacing: 16, mainAxisSpacing: 16),
                itemBuilder: (context, i) => Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ordersList[i].namaPelanggan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text('WA: ${ordersList[i].nomorWa}', style: const TextStyle(color: Colors.grey)), const Spacer(), Text('ID: ${ordersList[i].idPesanan}', style: const TextStyle(fontSize: 10, color: Colors.blue)),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      }
    );
  }

  Widget _buildInventoryView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('INVENTORY / CATALOG', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 32)),
            ElevatedButton.icon(
              onPressed: () => _showProductFormDialog(),
              icon: const Icon(Icons.add), label: const Text('Add Display Product'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
            )
          ],
        ),
        const SizedBox(height: 32),
        const Text('Klik pada kartu produk untuk mengedit detail atau menghapusnya.', style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            itemCount: hoodiesDataList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 0.75, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemBuilder: (context, i) {
              final item = hoodiesDataList[i];
              return GestureDetector(
                onTap: () => _showProductFormDialog(existingProduct: item, index: i),
                child: Card(
                  color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.asset(item.mainAssetPath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey))),
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis), 
                                const SizedBox(height: 4),
                                Text('Min: ${item.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 11))
                              ]
                            ),
                          )
                        ],
                      ),
                      const Positioned(
                        top: 8, right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.white, radius: 14,
                          child: Icon(Icons.edit, size: 16, color: Colors.black),
                        )
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  void _showProductFormDialog({ProductItem? existingProduct, int? index}) {
    final TextEditingController nameCtrl = TextEditingController(text: existingProduct?.name ?? '');
    final TextEditingController minOrderCtrl = TextEditingController(text: existingProduct?.minOrder ?? '');
    
    List<String> availableImages = [
      'assets/images/products/1.jpeg',
      'assets/images/products/2.jpeg',
      'assets/images/products/3.jpeg',
      'assets/images/products/4.jpeg',
      'assets/images/products/5.jpeg',
      'assets/images/products/hodie 1(1).jpeg',
      'assets/images/products/hodie 2(1).jpeg',
      'assets/images/products/hodie 3(1).jpeg',
      'assets/images/products/hodie 4(1).jpeg',
      'assets/images/products/hodie 1(2).jpeg',
    ];

    String selectedImage = existingProduct?.mainAssetPath ?? availableImages[0];
    
    if (!availableImages.contains(selectedImage)) {
      availableImages.add(selectedImage);
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(existingProduct == null ? 'TAMBAH PRODUK KATALOG' : 'EDIT PRODUK', style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 18)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdminTextField('Nama Produk Display', nameCtrl),
                    _buildAdminTextField('Minimal Order (pcs)', minOrderCtrl, isNumber: true),
                    const SizedBox(height: 16),
                    const Text('Pilih Foto Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedImage,
                          items: availableImages.map((img) => DropdownMenuItem(
                            value: img,
                            child: Row(
                              children: [
                                Image.asset(img, width: 30, height: 30, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image, size: 30)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(img.split('/').last, overflow: TextOverflow.ellipsis)),
                              ],
                            )
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedImage = val);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ),
              actions: [
                if (existingProduct != null)
                  TextButton(
                    onPressed: () {
                      setState(() { hoodiesDataList.removeAt(index!); });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus!'), backgroundColor: Colors.red));
                    },
                    child: const Text('Hapus Produk', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                  ),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || minOrderCtrl.text.isEmpty) return;
                    
                    setState(() {
                      if (existingProduct == null) {
                        hoodiesDataList.insert(0, ProductItem(name: nameCtrl.text, mainAssetPath: selectedImage, minOrder: minOrderCtrl.text));
                      } else {
                        existingProduct.name = nameCtrl.text;
                        existingProduct.minOrder = minOrderCtrl.text;
                        existingProduct.mainAssetPath = selectedImage;
                      }
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Katalog berhasil diperbarui!'), backgroundColor: Colors.green));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  child: const Text('Simpan Data'),
                )
              ]
            );
          }
        );
      }
    );
  }

  Widget _buildSettingsView() {
    final TextEditingController aboutCtrl = TextEditingController(text: globalCompanyProfile.aboutText);
    final TextEditingController waCtrl = TextEditingController(text: globalCompanyProfile.waNumber);
    final TextEditingController igCtrl = TextEditingController(text: globalCompanyProfile.igUsername);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('COMPANY SETTINGS', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 32)), const Text('Edit informasi di bawah untuk mengubah tampilan Profile Page di aplikasi Mobile pelanggan.', style: TextStyle(color: Colors.grey)), const SizedBox(height: 40),
        Container(
          width: 700, padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deskripsi Perusahaan (About)', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), TextField(controller: aboutCtrl, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder())), const SizedBox(height: 24),
              const Text('Nomor WhatsApp Resmi', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), TextField(controller: waCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: 0895...')), const SizedBox(height: 24),
              const Text('Username Instagram', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), TextField(controller: igCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: @hananorikonveksi')), const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() { globalCompanyProfile.aboutText = aboutCtrl.text; globalCompanyProfile.waNumber = waCtrl.text; globalCompanyProfile.igUsername = igCtrl.text; });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informasi Perusahaan Berhasil Diperbarui!'), backgroundColor: Colors.green));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('SIMPAN PERUBAHAN PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      width: 250, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.black), const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(value, style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 24))])
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Barang Siap' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}