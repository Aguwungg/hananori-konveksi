import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'data_models.dart';
import 'admin_views.dart';
import 'main.dart';
import 'product_widgets.dart';
import 'feedback_utils.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(decoration: BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade200, width: 1))), child: child),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final String activePage;
  const AppDrawer({super.key, required this.activePage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24, bottom: 24, left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/images/products/logo hananori.jpg', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.business, color: Colors.black)))
                ),
                const SizedBox(height: 16),
                const Text('CV. HANANORI', style: TextStyle(fontFamily: 'IntegralCF', color: Colors.white, fontSize: 20)),
                const SizedBox(height: 4),
                const Text('Harga murah kualitas mewah, bukan yang lain', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.only(top: 16),
                children: [
                  _buildDrawerItem(context, 'Home (Track Order)', Icons.home_outlined, Icons.home, activePage == 'Home', const HomePage()),
                  _buildDrawerItem(context, 'Our Product', Icons.shopping_bag_outlined, Icons.shopping_bag, activePage == 'Product', const OurProductPage()),
                  _buildDrawerItem(context, 'Youth & Society', Icons.group_outlined, Icons.group, activePage == 'Youth', const YouthSocietyPage()),
                  _buildDrawerItem(context, 'Company Profile', Icons.business_outlined, Icons.business, activePage == 'Profile', const ProfilePage()),
                  const Divider(),
                  _buildDrawerItem(context, 'Admin Panel (Web View)', Icons.admin_panel_settings_outlined, Icons.admin_panel_settings, activePage == 'Admin', const AdminDashboardPage()),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, mode, child) {
                        bool isDark = mode == ThemeMode.dark;
                        return SwitchListTile(
                          title: const Text('Dark Mode'),
                          secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                          value: isDark,
                          onChanged: (val) {
                            themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                          },
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, IconData activeIcon, bool isActive, Widget targetPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive ? Colors.grey.shade100 : Colors.transparent,
        leading: Icon(isActive ? activeIcon : icon, color: isActive ? Colors.black : Colors.grey.shade600),
        title: Text(title, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey.shade800)),
        onTap: () { if (!isActive) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => targetPage)); },
      ),
    );
  }
}

AppBar _buildCustomAppBar(BuildContext context) {
  return AppBar(
    title: const Text('CV.HANANORI', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 20)),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
          child: CircleAvatar(backgroundColor: Colors.black, radius: 16, child: ClipOval(child: Image.asset('assets/images/products/logo hananori.jpg', width: 32, height: 32, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Text('H', style: TextStyle(color: Colors.amber))))),
        ),
      )
    ],
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _trackingController = TextEditingController();
  final TextEditingController _waController = TextEditingController();
  final ScrollController _testimonialScrollController = ScrollController();
  String _selectedCategory = 'All';
  bool _isTracking = false;


  void _handleTracking() async {
    String input = _trackingController.text.trim();
    String waInput = _waController.text.trim();
    if (input.isEmpty || waInput.isEmpty) {
      AppFeedback.showWarning(context, title: 'Lengkapi Data Tracking', message: 'Masukkan ID Pesanan dan Nomor WA terlebih dahulu.');
      return;
    }
    
    setState(() => _isTracking = true);
    try {
      final snapshot = await ordersRef.once();
      bool found = false;
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> dataMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        List<OrderData> ordersList = dataMap.values.map((e) => OrderData.fromMap(e as Map<dynamic, dynamic>)).toList();
        found = ordersList.any((o) => o.idPesanan.toLowerCase() == input.toLowerCase() && o.nomorWa == waInput);
      }
      
      if (found) {
        if (mounted) {
          AppFeedback.showSuccess(context, title: 'Pesanan Ditemukan', message: 'Informasi dan perkembangan produksi berhasil dimuat.');
          Navigator.push(context, MaterialPageRoute(builder: (context) => TimelinePage(orderId: input, waNumber: waInput)));
        }
      } else {
        if (mounted) {
          AppFeedback.showError(context, title: 'Pesanan Tidak Ditemukan', message: 'Periksa kembali ID Pesanan dan Nomor WA Anda.');
        }
      }
    } catch (e) {
      if (mounted) AppFeedback.showError(context, title: 'Koneksi Bermasalah', message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } finally {
      if (mounted) setState(() => _isTracking = false);
    }
  }

  void _scrollTestimonial(bool isRight) {
    double offset = isRight ? _testimonialScrollController.offset + 296 : _testimonialScrollController.offset - 296;
    _testimonialScrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  void dispose() { 
    _trackingController.dispose(); 
    _waController.dispose();
    _testimonialScrollController.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        drawer: const AppDrawer(activePage: 'Home'), appBar: _buildCustomAppBar(context),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8), const Text('Home', style: TextStyle(color: Colors.grey, fontSize: 14)), const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.black, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TRACK YOUR\nORDER', style: TextStyle(fontFamily: 'IntegralCF', color: Colors.white, fontSize: 28, height: 1.1)), const SizedBox(height: 24),
                          TextField(controller: _trackingController, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), decoration: InputDecoration(filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.white, hintText: 'Enter Order ID', hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey, fontSize: 12), prefixIcon: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 0))), const SizedBox(height: 16),
                          TextField(controller: _waController, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), decoration: InputDecoration(filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.white, hintText: 'Enter WA Number', hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey, fontSize: 12), prefixIcon: Icon(Icons.phone, color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 0))), const SizedBox(height: 16),
                          AppLoadingButton(
                            onPressed: _handleTracking,
                            text: 'Find Your Order',
                            isLoading: _isTracking,
                            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.amber : Colors.white,
                            textColor: Colors.black,
                          ),
                          const SizedBox(height: 12),
                          const Text('*Disclaimer: Status pesanan bersifat publik bagi yang memiliki akses ke Nomor WhatsApp ini.', style: TextStyle(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32), const Text('OUR PRODUCT', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24)), const SizedBox(height: 16),
                  ],
                ),
              ),
              ProductsBuilder(builder: (context, products) => _buildProductSections(context, products)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('OUR HAPPY\nCUSTOMERS', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24, height: 1.1)),
                        Row(children: [GestureDetector(onTap: () => _scrollTestimonial(false), child: const Icon(Icons.arrow_back, size: 24)), const SizedBox(width: 16), GestureDetector(onTap: () => _scrollTestimonial(true), child: const Icon(Icons.arrow_forward, size: 24))]),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  List<String> rawTests = (globalCompanyProfile.testimonials ?? '').split('|');
                  if (rawTests.isEmpty || rawTests.first.isEmpty) rawTests = ['Pelanggan - Kualitas baju dari Hananori luar biasa!'];
                  return SizedBox(
                    height: 180, 
                    child: ListView.separated(
                      controller: _testimonialScrollController, 
                      padding: const EdgeInsets.symmetric(horizontal: 16), 
                      scrollDirection: Axis.horizontal, 
                      itemCount: rawTests.length, 
                      separatorBuilder: (context, index) => const SizedBox(width: 16), 
                      itemBuilder: (context, index) {
                        final parts = rawTests[index].split('-');
                        final name = parts.isNotEmpty ? parts[0].trim() : 'Customer';
                        final review = parts.length > 1 ? parts.sublist(1).join('-').trim() : 'Sangat direkomendasikan!';
                        return _buildTestimonialCard(name, review);
                      }
                    )
                  );
                }
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSections(BuildContext context, List<ProductItem> products) {
    final List<String> categories = ['All', ...availableCategories(products)];
    final String activeCategory = categories.contains(_selectedCategory) ? _selectedCategory : 'All';
    final List<ProductItem> filtered = activeCategory == 'All' ? products : products.where((p) => p.category == activeCategory).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryChips(categories: categories, selected: activeCategory, onSelected: (c) => setState(() => _selectedCategory = c)),
        const SizedBox(height: 16),
        _buildHorizontalProductList(filtered, 'home'),
        Padding(padding: const EdgeInsets.all(16.0), child: _buildViewAllButton(context, const OurProductPage())),
        for (final section in highlightSections)
          if (products.any((p) => p.displaySection == section)) ...[
            _buildSectionTitle(section.toUpperCase()),
            _buildHorizontalProductList(products.where((p) => p.displaySection == section).toList(), 'sec_$section'),
            const SizedBox(height: 16),
          ],
        _buildSectionTitle('YOUTH & SOCIETY'),
        _buildHorizontalProductList(products.reversed.toList(), 'youthhome'),
        Padding(padding: const EdgeInsets.all(16.0), child: _buildViewAllButton(context, const YouthSocietyPage())),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Text(title, style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 24)));
  }

  Widget _buildHorizontalProductList(List<ProductItem> items, String prefix) {
    if (items.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: Text('Belum ada produk di kategori ini.', style: TextStyle(color: Colors.grey))));
    }
    return SizedBox(
      height: 290,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _buildProductCard(context, items[index], '${prefix}_${items[index].id}_$index'),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductItem item, String heroTag) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: item, heroTag: heroTag))),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: heroTag,
              child: Container(height: 188, width: 150, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: ThumbImage(path: item.mainAssetPath))),
            ),
            const SizedBox(height: 12), Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text('Min Order: ${item.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(String name, String review) {
    return Container(
      width: 280, padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16))), const SizedBox(height: 8),
          Row(children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 4), const Icon(Icons.check_circle, color: Colors.green, size: 16)]), const SizedBox(height: 8),
          Text('"$review"', style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5), maxLines: 4, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context, Widget targetPage) {
    return SizedBox(width: double.infinity, height: 40, child: OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage)), style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold))));
  }
}
class TimelinePage extends StatelessWidget {
  final String orderId;
  final String waNumber;
  const TimelinePage({super.key, required this.orderId, required this.waNumber});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: _buildCustomAppBar(context),
        body: StreamBuilder<DatabaseEvent>(
          stream: ordersRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }

            List<OrderData> matchedOrders = [];

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              List<OrderData> ordersList = dataMap.values.map((e) => OrderData.fromMap(e as Map<dynamic, dynamic>)).toList();
              
              // Filter pesanan berdasarkan ID Pesanan DAN Nomor WA (Logika &&)
              matchedOrders = ordersList.where((o) => 
                o.idPesanan.toLowerCase() == orderId.toLowerCase() && 
                o.nomorWa == waNumber
              ).toList();
            }

            if (matchedOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red), const SizedBox(height: 16),
                    const Text('Pesanan Tidak Ditemukan', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 18)), const SizedBox(height: 8),
                    const Text('Pastikan ID Pesanan atau Nomor WA benar.', style: TextStyle(color: Colors.grey)), const SizedBox(height: 24),
                    ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: const Text('Kembali'))
                  ],
                ),
              );
            }

            // LOGIKA BARU: Jika ada lebih dari 1 pesanan untuk nomor WA ini
            if (matchedOrders.length > 1) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context), 
                          child: const Text('Home', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold))
                        ), 
                        const Text(' > Pilih Pesanan', style: TextStyle(color: Colors.grey, fontSize: 14))
                      ]
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Ditemukan Beberapa Pesanan', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 20)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Nomor WA $orderId memiliki ${matchedOrders.length} pesanan aktif.', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: matchedOrders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final o = matchedOrders[index];
                        return InkWell(
                          onTap: () {
                            // Mengarahkan ke halaman Timeline menggunakan ID Pesanan uniknya
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TimelinePage(orderId: o.idPesanan, waNumber: o.nomorWa)));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50, 
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), 
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8), 
                                    child: ProductImage(path: o.imagePath, iconData: Icons.inventory)
                                  )
                                ), 
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text(o.produk, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), 
                                      const SizedBox(height: 4), 
                                      Text('ID: ${o.idPesanan.toUpperCase()}', style: const TextStyle(fontSize: 12, color: Colors.black54)), 
                                    ]
                                  )
                                ),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            // Jika hanya 1 pesanan, tampilkan timeline seperti biasa
            final order = matchedOrders.first;
            int activeStageIndex = sopStages.indexOf(order.statusProduksi);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Home', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold))), const Text(' > Production Timeline', style: TextStyle(color: Colors.grey, fontSize: 14))]),
                        Text(order.idPesanan.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pemesan: ${order.namaPelanggan}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), 
                                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: ProductImage(path: order.imagePath, iconData: Icons.inventory))
                                ), 
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(order.produk, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text('Quantity: ${order.qty} pcs', style: const TextStyle(color: Colors.grey, fontSize: 12)), const Text('Material: Custom by Request', style: TextStyle(color: Colors.grey, fontSize: 12))]))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(child: Text('Estimated Completion - ${order.estimasiSelesai}', style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 32),
                    ...List.generate(sopStages.length, (index) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + (index * 150)), 
                        builder: (context, value, child) {
                          return Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child));
                        },
                        child: _buildTimelineStep('Stage ${index + 1}', sopStages[index], index <= activeStageIndex, index == sopStages.length - 1),
                      );
                    }),
                    const SizedBox(height: 24),
                    const SizedBox(height: 16),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String stage, String title, bool isActive, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, color: isActive ? Colors.black : Colors.grey.shade300, size: 28),
            if (!isLast) Container(width: 2, height: 30, color: isActive ? Colors.black : Colors.grey.shade200, margin: const EdgeInsets.symmetric(vertical: 4)),
          ],
        ),
        const SizedBox(width: 16),
        Padding(padding: const EdgeInsets.only(top: 4.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(stage, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)), Text(title, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontSize: 16, fontWeight: isActive ? FontWeight.bold : FontWeight.normal))]))
      ],
    );
  }
}
class ProductDetailPage extends StatefulWidget {
  final ProductItem product;
  final String heroTag;
  const ProductDetailPage({super.key, required this.product, required this.heroTag});
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late String _currentMainImage;
  @override
  void initState() { super.initState(); _currentMainImage = widget.product.mainAssetPath; }

  @override
  Widget build(BuildContext context) {
    // Galeri: produk asset lokal punya 3 varian foto "(1) (2) (3)"; produk dari admin (URL) hanya 1 foto.
    final String mainPath = widget.product.mainAssetPath;
    final int parenthesisIndex = mainPath.lastIndexOf('(');
    final List<String> gallery = (!mainPath.startsWith('http') && parenthesisIndex > 0)
        ? List.generate(3, (i) => '${mainPath.substring(0, parenthesisIndex)}(${i + 1}).jpeg')
        : [mainPath];
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: _buildCustomAppBar(context),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        GestureDetector(onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false), child: const Text('Home', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold))), const Text(' > ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OurProductPage())), child: const Text('Our Product', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold))), const Text(' > Detail', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Hero(
                      tag: widget.heroTag,
                      child: OriginalRatioImage(path: _currentMainImage, radius: 16, onTap: _openZoom),
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(offset: Offset(0, 40 * (1 - value)), child: child),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (gallery.length > 1) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: gallery.map(_thumb).toList()),
                          const SizedBox(height: 24),
                          Text(widget.product.name.toUpperCase(), style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 28)),
                          const SizedBox(height: 8), Text('${widget.product.category} • Min Order: ${widget.product.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 14)), const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity, height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final String phone = globalCompanyProfile.waNumber ?? '';
                                final String message = "Halo Hananori Konveksi! Saya ingin konsultasi dan memesan produk *${widget.product.name}*.";
                                final Uri waUrl = Uri.parse("https://wa.me/62${phone.substring(1)}?text=${Uri.encodeComponent(message)}");
                                try {
                                  if (await launchUrl(waUrl, mode: LaunchMode.externalApplication)) {
                                    if (context.mounted) AppFeedback.showSuccess(context, title: 'Aplikasi WhatsApp Dibuka', message: 'Melanjutkan ke WhatsApp untuk mengirim pesan.');
                                  } else {
                                    if (context.mounted) AppFeedback.showError(context, title: 'Gagal Membuka WhatsApp', message: 'Pastikan aplikasi WhatsApp sudah terinstall.');
                                  }
                                } catch (e) {
                                  if (context.mounted) AppFeedback.showError(context, title: 'Gagal Membuka WhatsApp', message: 'Terjadi kesalahan sistem.');
                                }
                              },
                              icon: const Icon(Icons.chat_bubble_outline), label: const Text('Konsultasi & Pesan via WA', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            ),
                          ),
                          const SizedBox(height: 24), Text(widget.product.description, style: const TextStyle(color: Colors.grey, height: 1.5)), const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Center(child: Text('YOU MIGHT\nALSO LIKE', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'IntegralCF', fontSize: 28, height: 1.1))),
              const SizedBox(height: 24),
              ProductsBuilder(builder: (context, all) {
                final List<ProductItem> others = all.where((p) => p.id != widget.product.id).toList();
                final List<ProductItem> same = others.where((p) => p.category == widget.product.category).toList();
                final List<ProductItem> rest = others.where((p) => p.category != widget.product.category).toList();
                final List<ProductItem> similar = [...same, ...rest].take(3).toList();
                if (similar.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 290,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: similar.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final ProductItem item = similar[index];
                      return _buildRelatedProductCard(context, item, 'related_${widget.product.id}_${item.id}_$index');
                    },
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _openZoom() {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(children: [
          Positioned.fill(child: InteractiveViewer(minScale: 1, maxScale: 5, child: Center(child: ProductImage(path: _currentMainImage, fit: BoxFit.contain, iconSize: 60)))),
          Positioned(top: 8, right: 8, child: SafeArea(child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 28), onPressed: () => Navigator.pop(ctx)))),
        ]),
      ),
    );
  }

  Widget _thumb(String path) {
    return GestureDetector(
      onTap: () => setState(() => _currentMainImage = path),
      child: Container(height: 80, width: 100, decoration: BoxDecoration(border: Border.all(color: _currentMainImage == path ? Colors.black : Colors.grey.shade300, width: 2), borderRadius: BorderRadius.circular(8)), child: ClipRRect(borderRadius: BorderRadius.circular(6), child: ProductImage(path: path, iconData: Icons.image))),
    );
  }

  Widget _buildRelatedProductCard(BuildContext context, ProductItem item, String heroTag) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: item, heroTag: heroTag))),
      child: SizedBox(
        width: 150, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Hero(
              tag: heroTag,
              child: Container(height: 188, width: 150, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: ThumbImage(path: item.mainAssetPath))), 
            ),
            const SizedBox(height: 12), Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text('Min Order: ${item.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 12))
          ]
        )
      ),
    );
  }
}

Widget _buildCatalogGrid(BuildContext context, List<ProductItem> items, String prefix) {
  if (items.isEmpty) {
    return Container(
      key: const ValueKey('empty_state'),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16), 
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Yah, produk tidak ditemukan.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            const Text('Coba ubah kata kunci atau pilih kategori lain.', style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
          ],
        )
      )
    );
  }
  return GridView.builder(
    key: ValueKey('grid_${items.length}_$prefix'),
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.55, crossAxisSpacing: 16, mainAxisSpacing: 16),
    itemBuilder: (context, index) {
      final ProductItem item = items[index];
      final String heroTag = '${prefix}_${item.id}_$index';
      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: item, heroTag: heroTag))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Hero(tag: heroTag, child: Container(width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: ThumbImage(path: item.mainAssetPath, iconSize: 40))))),
          const SizedBox(height: 12),
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('Min Order: ${item.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      );
    },
  );
}

class OurProductPage extends StatefulWidget {
  const OurProductPage({super.key});
  @override
  State<OurProductPage> createState() => _OurProductPageState();
}

class _OurProductPageState extends State<OurProductPage> {
  String _selectedCategory = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        drawer: const AppDrawer(activePage: 'Product'), appBar: _buildCustomAppBar(context),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [GestureDetector(onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false), child: const Text('Home', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold))), const Text(' > Our Product', style: TextStyle(color: Colors.grey, fontSize: 14))]), const SizedBox(height: 16),
                const Text('Our Product', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 28)), const SizedBox(height: 16),
                ProductsBuilder(builder: (context, products) {
                  final List<String> categories = ['All', ...availableCategories(products)];
                  final String active = categories.contains(_selectedCategory) ? _selectedCategory : 'All';
                  
                  // Filter by category
                  List<ProductItem> filtered = active == 'All' ? products : products.where((p) => p.category == active).toList();
                  
                  // Filter by search query (Live Search)
                  final String query = _searchCtrl.text.toLowerCase();
                  if (query.isNotEmpty) {
                    filtered = filtered.where((p) => p.name.toLowerCase().contains(query) || p.description.toLowerCase().contains(query)).toList();
                  }

                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() {}),
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Cari produk (contoh: Oversize, Rajut)...',
                        hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0)
                      ),
                    ),
                    const SizedBox(height: 16),
                    CategoryChips(categories: categories, selected: active, padding: EdgeInsets.zero, onSelected: (c) => setState(() => _selectedCategory = c)),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _buildCatalogGrid(context, filtered, 'catalog_${active}_$query'),
                    ),
                  ]);
                }),
              ],
            ),
          ),
        )
      )
    );
  }
}

class YouthSocietyPage extends StatelessWidget {
  const YouthSocietyPage({super.key});
  @override Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        drawer: const AppDrawer(activePage: 'Youth'), appBar: _buildCustomAppBar(context),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [GestureDetector(onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false), child: const Text('Home', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold))), const Text(' > Youth & Society', style: TextStyle(color: Colors.grey, fontSize: 14))]), const SizedBox(height: 16),
                const Text('Youth & Society', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 28)), const SizedBox(height: 24),
                ProductsBuilder(builder: (context, products) => _buildCatalogGrid(context, products.reversed.toList(), 'youth')),
              ],
            ),
          ),
        )
      )
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> services = [
      {'title': 'FASHION DESIGN & CONCEPT', 'image': 'assets/images/products/1.jpeg'}, {'title': 'PREMIUM STREETWEAR PROD.', 'image': 'assets/images/products/2.jpeg'}, {'title': 'ACADEMIC & ORG. APPAREL', 'image': 'assets/images/products/3.jpeg'}, {'title': 'TECHNICAL FABRIC ENGINEER', 'image': 'assets/images/products/4.jpeg'}, {'title': 'VISUAL BRANDING & MERCH.', 'image': 'assets/images/products/5.jpeg'},
    ];

    return ResponsiveWrapper(
      child: Scaffold(
        drawer: const AppDrawer(activePage: 'Profile'), appBar: _buildCustomAppBar(context),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Text('Home', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)), Text(' > Profile', style: TextStyle(color: Colors.grey, fontSize: 14))]), const SizedBox(height: 16),
                    const Text('ABOUT COMPANY', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24)), const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 120, width: 120, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/images/products/logo hananori.jpeg', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.black26)))), const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.amber : Colors.black, borderRadius: BorderRadius.circular(20)), child: Text('About Company', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white, fontSize: 12))), const SizedBox(height: 12), 
                        Text(globalCompanyProfile.aboutText ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5))]))
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(globalCompanyProfile.foundedYear ?? '', style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 20)), const SizedBox(height: 4), const Text('Founded', style: TextStyle(color: Colors.grey, fontSize: 12))]), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(globalCompanyProfile.totalClients ?? '', style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 20)), const SizedBox(height: 4), const Text('Client', style: TextStyle(color: Colors.grey, fontSize: 12))]), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(globalCompanyProfile.projectsDone ?? '', style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 20)), const SizedBox(height: 4), const Text('Project Done', style: TextStyle(color: Colors.grey, fontSize: 12))]), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(globalCompanyProfile.fiveStarReviews ?? '', style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 20)), const SizedBox(height: 4), const Text('5-Star Review', style: TextStyle(color: Colors.grey, fontSize: 12))])]),
                    const SizedBox(height: 32), const Text('WHAT WE DO?', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24)), const SizedBox(height: 16),
                  ],
                ),
              ),
              SizedBox(height: 200, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: services.length, separatorBuilder: (context, index) => const SizedBox(width: 16), itemBuilder: (context, index) { return SizedBox(width: 150, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 140, width: 150, decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(services[index]['image']!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey)))), const SizedBox(height: 8), Text(services[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 2)])); })),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Our services are tailored to meet the unique needs of each client.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)), const SizedBox(height: 32), const Text('CONTACT US', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24)), const SizedBox(height: 16),
                    _buildFigmaContactRow(context, Icons.alternate_email, globalCompanyProfile.igUsername ?? '', 'https://instagram.com/${(globalCompanyProfile.igUsername ?? '').replaceAll('@', '')}'),
                    _buildFigmaContactRow(context, Icons.phone, globalCompanyProfile.waNumber ?? '', 'https://wa.me/62${(globalCompanyProfile.waNumber ?? '').startsWith('0') ? (globalCompanyProfile.waNumber ?? '').substring(1) : (globalCompanyProfile.waNumber ?? '')}?text=Halo%20Hananori!'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFigmaContactRow(BuildContext context, IconData icon, String text, String urlString) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(urlString);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (context.mounted) AppFeedback.showError(context, title: 'Gagal Membuka Tautan', message: 'Tautan media sosial tidak dapat dibuka.');
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: isDark ? Colors.amber : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 5, spreadRadius: 1)]), child: Icon(icon, color: Colors.black, size: 20)),
            const SizedBox(width: 16), Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}