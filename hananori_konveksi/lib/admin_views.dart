import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'data_models.dart';
import 'mobile_views.dart';
import 'main.dart';
import 'product_widgets.dart';
import 'feedback_utils.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      AppFeedback.showWarning(context, title: 'Lengkapi Data Login', message: 'Masukkan email dan password terlebih dahulu.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      if (mounted) {
        AppFeedback.showSuccess(context, title: 'Login Berhasil', message: 'Selamat datang. Anda berhasil masuk ke sistem.');
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
        });
      }
    } on FirebaseAuthException catch (e) {
      AppFeedback.showError(context, title: 'Login Gagal', message: 'Email atau password yang Anda masukkan tidak sesuai.');
    } catch (e) {
      AppFeedback.showError(context, title: 'Sistem Sedang Bermasalah', message: 'Permintaan login belum dapat diproses. Silakan coba kembali.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          width: 400, padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: isDark ? Colors.black45 : Colors.black12, blurRadius: 10)]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ADMIN LOGIN', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 32),
              TextField(controller: _emailCtrl, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54), border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _passCtrl, obscureText: true, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54), border: const OutlineInputBorder())),
              const SizedBox(height: 24),
              AppLoadingButton(
                onPressed: _login,
                text: 'LOGIN',
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: Text('Belum Punya Akun? Register di sini', style: TextStyle(color: isDark ? Colors.amber : Colors.black87)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
                child: const Text('Kembali ke Halaman Utama (Mobile)', style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      AppFeedback.showWarning(context, title: 'Lengkapi Data Registrasi', message: 'Masukkan email dan password terlebih dahulu.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      if (mounted) {
        AppFeedback.showSuccess(context, title: 'Admin Ditambahkan', message: 'Akun berhasil dibuat. Anda sekarang terdaftar sebagai admin.');
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()), (r) => false);
        });
      }
    } on FirebaseAuthException catch (e) {
      AppFeedback.showError(context, title: 'Gagal Menambahkan Admin', message: 'Pastikan email belum terdaftar dan format sudah sesuai.');
    } catch (e) {
      AppFeedback.showError(context, title: 'Sistem Sedang Bermasalah', message: 'Permintaan registrasi belum dapat diproses. Silakan coba kembali.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Register Admin', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 18))),
      body: Center(
        child: Container(
          width: 400, padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: isDark ? Colors.black45 : Colors.black12, blurRadius: 10)]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('REGISTER AKUN', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 32),
              TextField(controller: _emailCtrl, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: 'Email Baru', labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54), border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _passCtrl, obscureText: true, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: 'Password Baru', labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54), border: const OutlineInputBorder())),
              const SizedBox(height: 24),
              AppLoadingButton(
                onPressed: _register,
                text: 'BUAT AKUN',
                isLoading: _isLoading,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0; 

  Future<String> _generateOrderId() async {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final prefix = 'HNN-$year$month-';

    final snapshot = await ordersRef.once();
    int highestCount = 0;

    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> dataMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
      for (var key in dataMap.keys) {
        String id = key.toString();
        if (id.startsWith(prefix)) {
          final suffixStr = id.substring(prefix.length);
          final suffixInt = int.tryParse(suffixStr) ?? 0;
          if (suffixInt > highestCount) {
            highestCount = suffixInt;
          }
        }
      }
    }

    final newSuffix = (highestCount + 1).toString().padLeft(4, '0');
    return '$prefix$newSuffix';
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      });
      return const Scaffold(backgroundColor: Color(0xFF121212), body: Center(child: CircularProgressIndicator(color: Colors.amber)));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: isMobile ? AppBar(
        title: const Text('ADMIN PANEL', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 18)),
        actions: [
          IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode), onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark)
        ],
      ) : null,
      drawer: isMobile ? Drawer(child: _buildSidebar(isDark, isMobile)) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(isDark, isMobile),
          Expanded(child: Padding(padding: EdgeInsets.all(isMobile ? 16.0 : 40.0), child: _buildCurrentView(isDark)))
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 260, 
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.grey[100],
        border: Border(right: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300))
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.amber, width: 2)),
            child: CircleAvatar(backgroundColor: Colors.white, radius: 32, child: ClipOval(child: Image.asset('assets/images/products/logo hananori.jpg', width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (c, e, s) => Text('H', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 28)))))
          ),
          const SizedBox(height: 16),
          Text('ADMIN PANEL', style: TextStyle(fontFamily: 'IntegralCF', color: isDark ? Colors.white : Colors.black, fontSize: 20)),
          const Text('CV. Hananori Konveksi', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 40),
          
          _buildSidebarItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Order Dashboard', isDark),
          _buildSidebarItem(1, Icons.people_outline, Icons.people, 'Customers', isDark),
          _buildSidebarItem(2, Icons.inventory_2_outlined, Icons.inventory_2, 'Inventory / Catalog', isDark),
          _buildSidebarItem(3, Icons.settings_outlined, Icons.settings, 'Profile Settings', isDark),
          
          const Spacer(),
          const Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.phone_android, color: isDark ? Colors.white54 : Colors.black54),
            title: Text('Lihat Versi Mobile', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCurrentView(bool isDark) {
    switch (_selectedIndex) {
      case 0: return _buildOrdersView(isDark);
      case 1: return _buildCustomersView(isDark);
      case 2: return _buildInventoryView(isDark);
      case 3: return _buildSettingsView(isDark);
      default: return _buildOrdersView(isDark);
    }
  }

  Widget _buildSidebarItem(int index, IconData icon, IconData activeIcon, String title, bool isDark) {
    bool isActive = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.amber.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.amber.withValues(alpha: 0.5) : Colors.transparent)
      ),
      child: ListTile(
        leading: Icon(isActive ? activeIcon : icon, color: isActive ? Colors.amber : (isDark ? Colors.white54 : Colors.black54)),
        title: Text(title, style: TextStyle(color: isActive ? Colors.amber : (isDark ? Colors.white54 : Colors.black54), fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        onTap: () {
          setState(() => _selectedIndex = index);
          if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context); // close drawer on tap
        },
      ),
    );
  }

  Widget _buildOrdersView(bool isDark) {
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
                Expanded(child: Text('ORDER MANAGEMENT', style: TextStyle(fontFamily: 'IntegralCF', fontSize: MediaQuery.of(context).size.width < 800 ? 24 : 32, color: isDark ? Colors.white : Colors.black))),
                if (MediaQuery.of(context).size.width >= 800)
                  IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.white : Colors.black), onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                String newId = await _generateOrderId();
                if (context.mounted) _showOrderFormDialog(generatedId: newId, isDark: isDark);
              },
              icon: const Icon(Icons.add, color: Colors.black), label: const Text('Buat Pesanan Baru', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 32),
            MediaQuery.of(context).size.width < 800 ? Column(
              children: [
                _buildSummaryCard('Total Pesanan', totalOrders.toString(), Icons.shopping_bag_outlined, Colors.blue, isDark), const SizedBox(height: 16),
                _buildSummaryCard('Dalam Produksi', inProduction.toString(), Icons.cached, Colors.orange, isDark), const SizedBox(height: 16),
                _buildSummaryCard('Siap Diambil', readyToPickup.toString(), Icons.check_circle_outline, Colors.green, isDark),
              ],
            ) : Row(
              children: [
                _buildSummaryCard('Total Pesanan', totalOrders.toString(), Icons.shopping_bag_outlined, Colors.blue, isDark), const SizedBox(width: 24),
                _buildSummaryCard('Dalam Produksi', inProduction.toString(), Icons.cached, Colors.orange, isDark), const SizedBox(width: 24),
                _buildSummaryCard('Siap Diambil', readyToPickup.toString(), Icons.check_circle_outline, Colors.green, isDark),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Klik baris pesanan untuk edit SOP.', style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: SingleChildScrollView(
                            child: DataTable(
                              showCheckboxColumn: false,
                              columnSpacing: 32, horizontalMargin: 24, dataRowMaxHeight: 65,
                        headingRowColor: WidgetStateProperty.all(isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
                        dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) return isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
                          return null; // default
                        }),
                        columns: const [
                          DataColumn(label: Text('ID PESANAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
                          DataColumn(label: Text('GAMBAR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
                          DataColumn(label: Text('PELANGGAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
                          DataColumn(label: Text('PRODUK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
                          DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
                        ],
                        rows: ordersList.map((order) {
                          DateTime? deadline = DateTime.tryParse(order.estimasiSelesai);
                          bool nearDeadline = false;
                          bool pastDeadline = false;
                          if (deadline != null) {
                            final diff = deadline.difference(DateTime.now()).inDays;
                            if (diff < 0 && order.statusProduksi != 'Barang Siap' && order.statusProduksi != 'Sudah Selesai') pastDeadline = true;
                            else if (diff <= 3 && order.statusProduksi != 'Barang Siap' && order.statusProduksi != 'Sudah Selesai') nearDeadline = true;
                          }
                          Color? rowColor;
                          if (pastDeadline) {
                            rowColor = isDark ? Colors.red.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.15);
                          } else if (nearDeadline) {
                            rowColor = isDark ? Colors.orange.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.15);
                          }

                          return DataRow(
                          color: rowColor != null ? WidgetStateProperty.all(rowColor) : null,
                          onSelectChanged: (_) => _showSOPUpdateDialog(isDark, order),
                          cells: [
                            DataCell(Text(order.idPesanan, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: ClipRRect(borderRadius: BorderRadius.circular(8), child: order.imagePath.startsWith('http') ? Image.network(order.imagePath, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image, color: isDark ? Colors.white54 : Colors.black54)) : Image.asset(order.imagePath, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.image, color: isDark ? Colors.white54 : Colors.black54))),
                              )
                            ),
                            DataCell(Text(order.namaPelanggan, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                            DataCell(Text('${order.qty} pcs - ${order.produk}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                            DataCell(_buildStatusBadge(order.statusProduksi)),
                          ]
                        );
                        }).toList(),
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ),
            )
          ],
        );
      }
    );
  }

  Future<void> _showOrderFormDialog({OrderData? existingOrder, String? generatedId, bool isDark = false}) async {
    // Ambil katalog terbaru dari Firebase (bukan data statis)
    final List<ProductItem> catalog = await fetchProductsOnce();
    if (!mounted) return;
    // Hindari value duplikat di dropdown & pastikan gambar pesanan lama tetap ada di daftar
    final Map<String, ProductItem> uniqueByImage = {};
    for (final p in catalog) {
      if (p.mainAssetPath.isNotEmpty) uniqueByImage.putIfAbsent(p.mainAssetPath, () => p);
    }
    if (existingOrder != null && existingOrder.imagePath.isNotEmpty && !uniqueByImage.containsKey(existingOrder.imagePath)) {
      uniqueByImage[existingOrder.imagePath] = ProductItem(id: 'existing', name: existingOrder.produk, mainAssetPath: existingOrder.imagePath, minOrder: '');
    }
    final List<ProductItem> productOptions = uniqueByImage.values.toList();
    final TextEditingController idCtrl = TextEditingController(text: existingOrder?.idPesanan ?? generatedId ?? '');
    final TextEditingController nameCtrl = TextEditingController(text: existingOrder?.namaPelanggan ?? '');
    final TextEditingController waCtrl = TextEditingController(text: existingOrder?.nomorWa ?? '');
    final TextEditingController prodCtrl = TextEditingController(text: existingOrder?.produk ?? '');
    final TextEditingController qtyCtrl = TextEditingController(text: existingOrder?.qty.toString() ?? '');
    final TextEditingController dpCtrl = TextEditingController(text: existingOrder?.tglDp ?? '2026-05-15');
    final TextEditingController estCtrl = TextEditingController(text: existingOrder?.estimasiSelesai ?? '2026-06-15');
    
    String selectedStage = existingOrder?.statusProduksi ?? sopStages[0];
    String selectedImage = existingOrder?.imagePath ?? (productOptions.isNotEmpty ? productOptions[0].mainAssetPath : '');

    Map<String, String?> errors = {};
    bool _isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            bool validateForm() {
              errors.clear();
              bool valid = true;
              
              if (nameCtrl.text.trim().isEmpty) {
                errors['name'] = 'Nama tidak boleh kosong';
                valid = false;
              } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(nameCtrl.text.trim())) {
                errors['name'] = 'Hanya huruf dan spasi yang diperbolehkan';
                valid = false;
              }
              
              if (prodCtrl.text.trim().isEmpty) {
                errors['prod'] = 'Jenis produk tidak boleh kosong';
                valid = false;
              }
              
              if (dpCtrl.text.trim().isEmpty || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dpCtrl.text.trim())) {
                errors['dp'] = 'Format salah (YYYY-MM-DD)';
                valid = false;
              }
              
              if (estCtrl.text.trim().isEmpty || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(estCtrl.text.trim())) {
                errors['est'] = 'Format salah (YYYY-MM-DD)';
                valid = false;
              }
              
              if (!RegExp(r'^(08|62)\d{8,11}$').hasMatch(waCtrl.text.trim())) {
                errors['wa'] = 'Format WA tidak valid (awali 08/62)';
                valid = false;
              }
              
              if (!RegExp(r'^[1-9]\d*$').hasMatch(qtyCtrl.text.trim())) {
                errors['qty'] = 'Harus angka positif';
                valid = false;
              }
              
              setDialogState(() {});
              return valid;
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(existingOrder == null ? 'BUAT PESANAN BARU' : 'EDIT PESANAN', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 20, color: isDark ? Colors.white : Colors.black)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAdminTextField('ID Pesanan', idCtrl, isEnabled: false, isDark: isDark), // Disabled/Read-only
                      _buildAdminTextField('Nama Pelanggan', nameCtrl, onChanged: (_) => validateForm(), errorText: errors['name'], isDark: isDark),
                      _buildAdminTextField('Nomor WhatsApp', waCtrl, onChanged: (_) => validateForm(), errorText: errors['wa'], isDark: isDark),
                      _buildAdminTextField('Jenis Produk (Nama)', prodCtrl, onChanged: (_) => validateForm(), errorText: errors['prod'], isDark: isDark),
                      _buildAdminTextField('Jumlah (Qty)', qtyCtrl, isNumber: true, onChanged: (_) => validateForm(), errorText: errors['qty'], isDark: isDark),
                      
                      const SizedBox(height: 16),
                      Text('Pilih Gambar Acuan Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                        Widget productRow(ProductItem p, {double size = 40}) => Row(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(width: size, height: size, child: ProductImage(path: p.mainAssetPath, iconSize: 18))),
                          const SizedBox(width: 12),
                          Expanded(child: Text(p.name, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                        ]);
                        final ProductItem? selectedProduct = productOptions.cast<ProductItem?>().firstWhere((p) => p!.mainAssetPath == selectedImage, orElse: () => null);
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: isDark ? Colors.white24 : Colors.black26), borderRadius: BorderRadius.circular(8)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                dropdownColor: Theme.of(context).cardColor,
                                itemHeight: 60,
                                isExpanded: true, value: selectedProduct?.mainAssetPath,
                                hint: const Text('Belum ada produk di katalog'),
                                selectedItemBuilder: (context) => productOptions.map((p) => Align(alignment: Alignment.centerLeft, child: productRow(p))).toList(),
                                items: productOptions.map((p) => DropdownMenuItem(value: p.mainAssetPath, child: productRow(p, size: 44))).toList(),
                                onChanged: (val) {
                                  if (val == null) return;
                                  setDialogState(() {
                                    selectedImage = val;
                                    // Isi otomatis nama produk jika masih kosong atau masih berisi nama produk pilihan sebelumnya
                                    final ProductItem picked = productOptions.firstWhere((p) => p.mainAssetPath == val);
                                    if (prodCtrl.text.trim().isEmpty || productOptions.any((p) => p.name == prodCtrl.text)) prodCtrl.text = picked.name;
                                  });
                                  validateForm();
                                },
                              ),
                            ),
                          ),
                          if (selectedProduct != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white12 : Colors.black12)),
                              child: Row(children: [
                                ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 84, height: 105, child: FramedProductImage(path: selectedProduct.mainAssetPath, iconSize: 28))),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(selectedProduct.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                                  const SizedBox(height: 6),
                                  Text(selectedProduct.category, style: TextStyle(fontSize: 12, color: isDark ? Colors.amber : Colors.black54, fontWeight: FontWeight.w600)),
                                  if (selectedProduct.minOrder.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text('Min Order: ${selectedProduct.minOrder} pcs', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                                  ],
                                ])),
                              ]),
                            ),
                          ],
                        ]);
                      }),
                      
                      _buildAdminTextField('Tanggal DP (YYYY-MM-DD)', dpCtrl, onChanged: (_) => validateForm(), errorText: errors['dp'], isDark: isDark),
                      _buildAdminTextField('Estimasi Selesai (YYYY-MM-DD)', estCtrl, onChanged: (_) => validateForm(), errorText: errors['est'], isDark: isDark),
                    ],
                  ),
                ),
              ),
              actions: [
                if (existingOrder != null)
                  TextButton(
                    onPressed: _isSaving ? null : () async {
                      bool confirm = await AppFeedback.showConfirmDialog(
                        context,
                        title: 'Hapus Pesanan?',
                        message: 'Pesanan yang sudah dihapus tidak dapat dikembalikan.',
                        confirmText: 'Hapus Pesanan',
                        isDestructive: true,
                      ) ?? false;
                      
                      if (!confirm) return;
                      
                      try {
                        await ordersRef.child(existingOrder.idPesanan).remove();
                        if (context.mounted) {
                          Navigator.pop(context);
                          AppFeedback.showSuccess(context, title: 'Pesanan Dihapus', message: 'Data pesanan berhasil dihapus dari sistem.');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppFeedback.showError(context, title: 'Gagal Menghapus Pesanan', message: 'Pesanan belum dapat dihapus. Silakan coba kembali.');
                        }
                      }
                    },
                    child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.white54))),
                SizedBox(
                  width: 140,
                  child: AppLoadingButton(
                    onPressed: () async {
                      if (!validateForm()) {
                        AppFeedback.showWarning(context, title: 'Data Tidak Valid', message: 'Mohon lengkapi atau perbaiki isian yang ditandai merah.');
                        return;
                      }
                      if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
                      
                      setDialogState(() => _isSaving = true);
                      bool isCreate = existingOrder == null;
                      
                      try {
                        String sanitizedName = nameCtrl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
                        sanitizedName = sanitizedName.split(' ').map((word) {
                          if (word.isEmpty) return '';
                          return word[0].toUpperCase() + word.substring(1).toLowerCase();
                        }).join(' ');
                        
                        OrderData newOrder = OrderData(
                          idPesanan: idCtrl.text, namaPelanggan: sanitizedName, nomorWa: waCtrl.text,
                          produk: prodCtrl.text, imagePath: selectedImage, qty: int.tryParse(qtyCtrl.text) ?? 0, 
                          tglDp: dpCtrl.text, estimasiSelesai: estCtrl.text, statusProduksi: selectedStage
                        );

                        await ordersRef.child(idCtrl.text).set(newOrder.toMap());
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (isCreate) {
                            AppFeedback.showSuccess(context, title: 'Pesanan Ditambahkan', message: 'Data pesanan baru berhasil disimpan.');
                          } else {
                            AppFeedback.showSuccess(context, title: 'Pesanan Diperbarui', message: 'Perubahan pada data pesanan berhasil disimpan.');
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          if (isCreate) {
                            AppFeedback.showError(context, title: 'Gagal Menambahkan Pesanan', message: 'Data pesanan belum dapat disimpan. Silakan coba kembali.');
                          } else {
                            AppFeedback.showError(context, title: 'Gagal Memperbarui Pesanan', message: 'Perubahan pada data pesanan belum dapat disimpan.');
                          }
                        }
                      } finally {
                        if (context.mounted) setDialogState(() => _isSaving = false);
                      }
                    },
                    text: 'Simpan',
                    isLoading: _isSaving,
                  ),
                )
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildAdminTextField(String label, TextEditingController controller, {bool isNumber = false, bool isEnabled = true, Function(String)? onChanged, String? errorText, bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextField(
        controller: controller, enabled: isEnabled, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: label, 
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14), 
          errorText: errorText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26)), 
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26)), 
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.amber, width: 2)), 
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.red.shade400)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        ),
      ),
    );
  }

  void _showSOPUpdateDialog(bool isDark, OrderData order) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        int currentIdx = sopStages.indexOf(order.statusProduksi);
        bool _isSaving = false;
        bool isComplete = currentIdx == sopStages.length - 1;
        String nextStage = isComplete ? 'Sudah Selesai' : sopStages[currentIdx + 1];

        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('UPDATE STATUS: ${order.idPesanan}', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 18, color: isDark ? Colors.white : Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pelanggan: ${order.namaPelanggan}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              Divider(height: 32, color: isDark ? Colors.white24 : Colors.black26),
              Text('TAHAPAN SAAT INI:', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(12), width: double.infinity, decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(order.statusProduksi, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 18))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: AppLoadingButton(
                  isLoading: _isSaving,
                  onPressed: isComplete ? null : () async {
                    setDialogState(() => _isSaving = true);
                    try {
                      await ordersRef.child(order.idPesanan).update({'statusProduksi': nextStage});

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        String title = nextStage == 'Barang Siap' ? 'Produksi Selesai' : 'Status Produksi Diperbarui';
                        String baseMsg = nextStage == 'Barang Siap' 
                           ? 'Pesanan telah selesai diproduksi dan masuk ke tahap Barang Siap.' 
                           : 'Pesanan telah masuk ke tahap $nextStage.';
                        
                        AppFeedback.showSuccess(context, title: title, message: baseMsg);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppFeedback.showError(context, title: 'Gagal Memperbarui Status', message: 'Status produksi belum dapat diperbarui. Silakan coba kembali.');
                      }
                    } finally {
                      if (mounted) setDialogState(() => _isSaving = false);
                    }
                  },
                  text: 'LANJUTKAN KE: $nextStage',
                ),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () { 
              Navigator.pop(ctx);
              _showOrderFormDialog(existingOrder: order, isDark: Theme.of(context).brightness == Brightness.dark); 
            }, child: const Text('Edit Detail Pesanan', style: TextStyle(color: Colors.blueAccent))),
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Tutup', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)))
          ],
        );
      }),
    );
  }

  Widget _buildCustomersView(bool isDark) {
    return StreamBuilder<DatabaseEvent>(
      stream: ordersRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: isDark ? Colors.amber : Colors.black));
        }

        List<OrderData> ordersList = [];
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          ordersList = dataMap.values.map((e) => OrderData.fromMap(e as Map<dynamic, dynamic>)).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CUSTOMER DIRECTORY', style: TextStyle(fontFamily: 'IntegralCF', fontSize: MediaQuery.of(context).size.width < 800 ? 24 : 32, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                itemCount: ordersList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.of(context).size.width < 800 ? 1 : 4, childAspectRatio: 1.8, crossAxisSpacing: 16, mainAxisSpacing: 16),
                itemBuilder: (context, i) => Container(
                  padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundColor: isDark ? Colors.amber.withValues(alpha: 0.2) : Colors.black12, child: Text(ordersList[i].namaPelanggan[0].toUpperCase(), style: TextStyle(color: isDark ? Colors.amber : Colors.black, fontWeight: FontWeight.bold, fontSize: 20))),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(ordersList[i].namaPelanggan, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis), 
                            const SizedBox(height: 4), 
                            Text('WA: ${ordersList[i].nomorWa}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)), 
                            const SizedBox(height: 8), 
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text('ID: ${ordersList[i].idPesanan}', style: const TextStyle(fontSize: 10, color: Colors.blueAccent))),
                          ],
                        ),
                      ),
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

  Widget _buildInventoryView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('INVENTORY / CATALOG', style: TextStyle(fontFamily: 'IntegralCF', fontSize: MediaQuery.of(context).size.width < 800 ? 24 : 32, color: isDark ? Colors.white : Colors.black))),
            ElevatedButton.icon(
              onPressed: () => _showProductFormDialog(isDark: isDark),
              icon: Icon(Icons.add, color: isDark ? Colors.black : Colors.white), label: Text('Add Product', style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.amber : Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )
          ],
        ),
        const SizedBox(height: 32),
        Text('Klik pada kartu produk untuk mengedit detail atau menghapusnya. Data tersimpan real-time di Firebase.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13, fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<DatabaseEvent>(
            stream: productsRef.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: isDark ? Colors.amber : Colors.black));
              
              List<ProductItem> productList = [];
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                productList = dataMap.entries.map((e) => ProductItem.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
              } else {
                productList = hoodiesDataList; // fallback
              }

              return GridView.builder(
                itemCount: productList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.of(context).size.width < 800 ? 2 : 5, childAspectRatio: 0.75, crossAxisSpacing: 20, mainAxisSpacing: 20),
                itemBuilder: (context, i) {
                  final item = productList[i];
                  return GestureDetector(
                    onTap: () => _showProductFormDialog(existingProduct: item, isDark: isDark),
                    child: Container(
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0,4))]),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), 
                                  child: item.mainAssetPath.isEmpty
                                    ? Icon(Icons.image, color: isDark ? Colors.white24 : Colors.black26, size: 40)
                                    : (item.mainAssetPath.startsWith('http') 
                                        ? Image.network(item.mainAssetPath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image, color: isDark ? Colors.white24 : Colors.black26, size: 40))
                                        : Image.asset(item.mainAssetPath, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.image, color: isDark ? Colors.white24 : Colors.black26, size: 40)))
                                )
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, 
                                  children: [
                                    Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis), 
                                    const SizedBox(height: 6),
                                    Text('Min: ${item.minOrder} pcs', style: TextStyle(color: isDark ? Colors.amber : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(item.description, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ]
                                ),
                              )
                            ],
                          ),
                          Positioned(
                            top: 10, right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                              child: const Icon(Icons.edit, size: 14, color: Colors.white),
                            )
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          ),
        )
      ],
    );
  }

  void _showProductFormDialog({ProductItem? existingProduct, bool isDark = false}) {
    final TextEditingController nameCtrl = TextEditingController(text: existingProduct?.name ?? '');
    final TextEditingController minOrderCtrl = TextEditingController(text: existingProduct?.minOrder ?? '');
    final TextEditingController descCtrl = TextEditingController(text: existingProduct?.description ?? '');
    
    String selectedCategory = existingProduct?.category ?? 'T-Shirt';
    String selectedSection = existingProduct?.displaySection ?? 'Standard';
    
    Uint8List? uploadedImageBytes;
    String selectedImage = existingProduct?.mainAssetPath ?? '';
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Theme.of(context).cardColor,
              title: Text(existingProduct == null ? 'TAMBAH PRODUK KATALOG' : 'EDIT PRODUK', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 18, color: isDark ? Colors.white : Colors.black)),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAdminTextField('Nama Produk Display', nameCtrl, isDark: isDark),
                      _buildAdminTextField('Minimal Order (pcs)', minOrderCtrl, isNumber: true, isDark: isDark),
                      _buildAdminTextField('Deskripsi Detail', descCtrl, isDark: isDark),
                      
                      const SizedBox(height: 16),
                      Text('Kategori Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: ['T-Shirt', 'Hoodie', 'Jaket', 'Kemeja', 'Seragam', 'Lainnya'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setDialogState(() => selectedCategory = val!),
                      ),
                      
                      const SizedBox(height: 16),
                      Text('Tampilkan di Section Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedSection,
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: ['Best Seller', 'New Arrival', 'Promo', 'Standard'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setDialogState(() => selectedSection = val!),
                      ),

                      const SizedBox(height: 24),
                      Text('Foto Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setDialogState(() {
                              uploadedImageBytes = bytes;
                            });
                          }
                        },
                        child: Container(
                          height: 150, width: double.infinity,
                          decoration: BoxDecoration(color: isDark ? Colors.black45 : Colors.black12, border: Border.all(color: isDark ? Colors.white10 : Colors.black12), borderRadius: BorderRadius.circular(12)),
                          child: uploadedImageBytes != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(uploadedImageBytes!, fit: BoxFit.cover))
                              : (selectedImage.isNotEmpty
                                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: selectedImage.startsWith('http') ? Image.network(selectedImage, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.image, color: isDark ? Colors.white54 : Colors.black54, size: 40)) : Image.asset(selectedImage, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.image, color: isDark ? Colors.white54 : Colors.black54, size: 40)))
                                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.upload_file, color: isDark ? Colors.white54 : Colors.black54, size: 40), const SizedBox(height: 8), Text('Klik untuk upload foto', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))])
                                ),
                        ),
                      ),
                    ],
                  )
                )
              ),
              actions: [
                if (existingProduct != null)
                  TextButton(
                    onPressed: () async {
                      bool confirm = await AppFeedback.showConfirmDialog(
                        context,
                        title: 'Hapus Katalog?',
                        message: 'Data produk yang sudah dihapus tidak dapat dikembalikan.',
                        confirmText: 'Hapus Produk',
                        isDestructive: true,
                      ) ?? false;
                      
                      if (!confirm) return;
                      
                      try {
                        await productsRef.child(existingProduct.id).remove();
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          AppFeedback.showSuccess(context, title: 'Katalog Dihapus', message: 'Data produk berhasil dihapus dari sistem.');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppFeedback.showError(context, title: 'Gagal Menghapus Katalog', message: 'Data produk belum dapat dihapus. Silakan coba kembali.');
                        }
                      }
                    },
                    child: const Text('Hapus Produk', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                  ),
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
                SizedBox(
                  width: 140,
                  child: AppLoadingButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty || minOrderCtrl.text.isEmpty) {
                        AppFeedback.showWarning(context, title: 'Data Tidak Lengkap', message: 'Mohon masukkan nama produk dan minimal order.');
                        return;
                      }
                      
                      setDialogState(() => isUploading = true);
                      bool isCreate = existingProduct == null;
                      
                      try {
                        if (uploadedImageBytes != null) {
                          // Menggunakan ImgBB API
                          String base64Image = base64Encode(uploadedImageBytes!);
                          var response = await http.post(
                            Uri.parse("https://api.imgbb.com/1/upload"),
                            body: {
                              "key": "6403d282b7a8ecac7bf0012921749c99",
                              "image": base64Image,
                            }
                          );
                          
                          if (response.statusCode == 200) {
                            var jsonMap = jsonDecode(response.body);
                            selectedImage = jsonMap['data']['url'];
                          } else {
                            throw Exception("ImgBB Error: ${response.statusCode}");
                          }
                        }

                        String id = existingProduct?.id ?? productsRef.push().key!;
                        ProductItem newItem = ProductItem(id: id, name: nameCtrl.text, mainAssetPath: selectedImage, minOrder: minOrderCtrl.text, description: descCtrl.text, category: selectedCategory, displaySection: selectedSection);
                        await productsRef.child(id).set(newItem.toMap());
                        
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          if (isCreate) {
                            AppFeedback.showSuccess(context, title: 'Katalog Ditambahkan', message: 'Data produk baru berhasil disimpan.');
                          } else {
                            AppFeedback.showSuccess(context, title: 'Katalog Diperbarui', message: 'Perubahan pada data produk berhasil disimpan.');
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          if (isCreate) {
                            AppFeedback.showError(context, title: 'Gagal Menambahkan Katalog', message: 'Data produk belum dapat disimpan. Silakan coba kembali.');
                          } else {
                            AppFeedback.showError(context, title: 'Gagal Memperbarui Katalog', message: 'Perubahan pada data produk belum dapat disimpan.');
                          }
                        }
                      } finally {
                        if (ctx.mounted) setDialogState(() => isUploading = false);
                      }
                    },
                    text: 'Simpan',
                    isLoading: isUploading,
                  ),
                )
              ]
            );
          }
        );
      }
    );
  }

  Widget _buildSettingsView(bool isDark) {
    final TextEditingController aboutCtrl = TextEditingController(text: globalCompanyProfile.aboutText ?? '');
    final TextEditingController waCtrl = TextEditingController(text: globalCompanyProfile.waNumber ?? '');
    final TextEditingController igCtrl = TextEditingController(text: globalCompanyProfile.igUsername ?? '');
    final TextEditingController sloganCtrl = TextEditingController(text: globalCompanyProfile.slogan ?? '');
    final TextEditingController foundedCtrl = TextEditingController(text: globalCompanyProfile.foundedYear ?? '');
    final TextEditingController clientsCtrl = TextEditingController(text: globalCompanyProfile.totalClients ?? '');
    final TextEditingController projectsCtrl = TextEditingController(text: globalCompanyProfile.projectsDone ?? '');
    final TextEditingController reviewsCtrl = TextEditingController(text: globalCompanyProfile.fiveStarReviews ?? '');
    final TextEditingController testimonialsCtrl = TextEditingController(text: globalCompanyProfile.testimonials ?? '');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMPANY SETTINGS', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 32, color: isDark ? Colors.white : Colors.black)), Text('Edit informasi di bawah untuk mengubah tampilan Profile Page di aplikasi Mobile pelanggan.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)), const SizedBox(height: 40),
        Container(
          width: MediaQuery.of(context).size.width < 800 ? double.infinity : 700, padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deskripsi Perusahaan (About)', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 8), TextField(controller: aboutCtrl, maxLines: 4, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26)))), const SizedBox(height: 24),
              Text('Slogan / Tagline', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 8), TextField(controller: sloganCtrl, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26)))), const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tahun Berdiri', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 8), TextField(controller: foundedCtrl, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26))))])), const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total Client', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 8), TextField(controller: clientsCtrl, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26))))])),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Projects Selesai', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 8), TextField(controller: projectsCtrl, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26))))])), const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Review 5 Bintang', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 8), TextField(controller: reviewsCtrl, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26))))])),
                ],
              ),
              const SizedBox(height: 24),
              Text('Nomor WhatsApp Resmi', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 8), TextField(controller: waCtrl, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26)), hintText: 'Contoh: 0895...', hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38))), const SizedBox(height: 24),
              Text('Username Instagram', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 8), TextField(controller: igCtrl, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26)), hintText: 'Contoh: @hananorikonveksi', hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38))), const SizedBox(height: 24),
              Text('Testimoni Pelanggan (pisahkan dengan "|")', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 8), TextField(controller: testimonialsCtrl, maxLines: 3, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26)), hintText: 'Nama - Ulasan|Nama 2 - Ulasan 2', hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38))), const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() { globalCompanyProfile.aboutText = aboutCtrl.text; globalCompanyProfile.waNumber = waCtrl.text; globalCompanyProfile.igUsername = igCtrl.text; globalCompanyProfile.slogan = sloganCtrl.text; globalCompanyProfile.foundedYear = foundedCtrl.text; globalCompanyProfile.totalClients = clientsCtrl.text; globalCompanyProfile.projectsDone = projectsCtrl.text; globalCompanyProfile.fiveStarReviews = reviewsCtrl.text; globalCompanyProfile.testimonials = testimonialsCtrl.text; });
                    AppFeedback.showSuccess(context, title: 'Profil Diperbarui', message: 'Informasi perusahaan berhasil disimpan.');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.amber : Colors.black, foregroundColor: isDark ? Colors.black : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('SIMPAN PERUBAHAN PROFIL', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        )
      ],
    )
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color accentColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, size: 32, color: accentColor)), const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(value, style: TextStyle(fontFamily: 'IntegralCF', fontSize: 28, color: isDark ? Colors.white : Colors.black))])
          ],
        ),
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