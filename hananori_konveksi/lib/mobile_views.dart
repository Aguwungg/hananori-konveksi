import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'data_models.dart';
import 'admin_views.dart';

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
  final ScrollController _testimonialScrollController = ScrollController();

  void _handleTracking() {
    String input = _trackingController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Silakan masukkan ID Pesanan atau Nomor WA!'), backgroundColor: Colors.red.shade800, behavior: SnackBarBehavior.floating));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TimelinePage(orderId: input)));
    }
  }

  void _scrollTestimonial(bool isRight) {
    double offset = isRight ? _testimonialScrollController.offset + 296 : _testimonialScrollController.offset - 296;
    _testimonialScrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  void dispose() { _trackingController.dispose(); _testimonialScrollController.dispose(); super.dispose(); }

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
                      padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TRACK YOUR\nORDER', style: TextStyle(fontFamily: 'IntegralCF', color: Colors.white, fontSize: 28, height: 1.1)), const SizedBox(height: 24),
                          TextField(controller: _trackingController, decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: 'Enter Order ID or WA Number', hintStyle: const TextStyle(color: Colors.grey, fontSize: 12), prefixIcon: const Icon(Icons.search, color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 0))), const SizedBox(height: 16),
                          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: _handleTracking, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: const Text('Find Your Order', style: TextStyle(fontWeight: FontWeight.bold)))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32), const Text('OUR PRODUCT', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24)), const SizedBox(height: 16),
                  ],
                ),
              ),
              SizedBox(height: 265, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: hoodiesDataList.length, separatorBuilder: (context, index) => const SizedBox(width: 16), itemBuilder: (context, index) => _buildProductCard(context, hoodiesDataList[index], 'home_${hoodiesDataList[index].name}_$index'))),
              Padding(padding: const EdgeInsets.all(16.0), child: _buildViewAllButton(context, const OurProductPage())),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [SizedBox(height: 16), Text('YOUTH & SOCIETY', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24)), SizedBox(height: 16)])),
              SizedBox(height: 265, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: hoodiesDataList.length, separatorBuilder: (context, index) => const SizedBox(width: 16), itemBuilder: (context, index) { final int reversedIndex = hoodiesDataList.length - 1 - index; return _buildProductCard(context, hoodiesDataList[reversedIndex], 'youthhome_${hoodiesDataList[reversedIndex].name}_$index'); })),
              Padding(padding: const EdgeInsets.all(16.0), child: _buildViewAllButton(context, const YouthSocietyPage())),
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
              SizedBox(height: 180, child: ListView.separated(controller: _testimonialScrollController, padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: 5, separatorBuilder: (context, index) => const SizedBox(width: 16), itemBuilder: (context, index) => _buildTestimonialCard('Customer ${index + 1}'))),
              const SizedBox(height: 40),
            ],
          ),
        ),
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
              child: Container(height: 160, width: 150, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(item.mainAssetPath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported)))),
            ),
            const SizedBox(height: 12), Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text('Min Order: ${item.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(String name) {
    return Container(
      width: 280, padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16))), const SizedBox(height: 8),
          Row(children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 4), const Icon(Icons.check_circle, color: Colors.green, size: 16)]), const SizedBox(height: 8),
          const Text('"Kualitas baju dari Hananori luar biasa! Sangat direkomendasikan untuk event organisasi."', style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5), maxLines: 4, overflow: TextOverflow.ellipsis),
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
  const TimelinePage({super.key, required this.orderId});

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

            OrderData? order;

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              List<OrderData> ordersList = dataMap.values.map((e) => OrderData.fromMap(e as Map<dynamic, dynamic>)).toList();
              
              try { 
                order = ordersList.firstWhere((o) => o.idPesanan.toLowerCase() == orderId.toLowerCase() || o.nomorWa == orderId); 
              } catch (e) { 
                order = null; 
              }
            }

            if (order == null) {
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
                            Text('Pemesan: ${order!.namaPelanggan}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), 
                                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(order.imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.inventory, color: Colors.grey)))
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
    int parenthesisIndex = widget.product.mainAssetPath.lastIndexOf('(');
    String basePath = widget.product.mainAssetPath.substring(0, parenthesisIndex);
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
                      child: Container(height: 300, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset(_currentMainImage, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 50)))),
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
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(3, (i) => _thumb('$basePath(${i + 1}).jpeg'))),
                          const SizedBox(height: 24),
                          Text(widget.product.name.toUpperCase(), style: const TextStyle(fontFamily: 'IntegralCF', fontSize: 28)),
                          const SizedBox(height: 8), Text('Min Order: ${widget.product.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 14)), const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity, height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final String phone = globalCompanyProfile.waNumber;
                                final String message = "Halo Hananori Konveksi! Saya ingin konsultasi dan memesan produk *${widget.product.name}*.";
                                final Uri waUrl = Uri.parse("https://wa.me/62${phone.substring(1)}?text=${Uri.encodeComponent(message)}");
                                if (!await launchUrl(waUrl, mode: LaunchMode.externalApplication)) {
                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka WhatsApp.')));
                                }
                              },
                              icon: const Icon(Icons.chat_bubble_outline), label: const Text('Konsultasi & Pesan via WA', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            ),
                          ),
                          const SizedBox(height: 24), const Text("This graphic streetwear product which is perfect for any occasion.", style: TextStyle(color: Colors.grey, height: 1.5)), const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Center(child: Text('YOU MIGHT\nALSO LIKE', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'IntegralCF', fontSize: 28, height: 1.1))),
              const SizedBox(height: 24),
              SizedBox(
                height: 265, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: hoodiesDataList.length, separatorBuilder: (context, index) => const SizedBox(width: 16), itemBuilder: (context, index) { 
                  final ProductItem item = hoodiesDataList[hoodiesDataList.length - 1 - index]; 
                  final String uniqueHeroTag = 'related_${widget.product.name}_${item.name}_$index';
                  return _buildRelatedProductCard(context, item, uniqueHeroTag); 
                }),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb(String path) {
    return GestureDetector(
      onTap: () => setState(() => _currentMainImage = path),
      child: Container(height: 80, width: 100, decoration: BoxDecoration(border: Border.all(color: _currentMainImage == path ? Colors.black : Colors.grey.shade300, width: 2), borderRadius: BorderRadius.circular(8)), child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset(path, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)))),
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
              child: Container(height: 160, width: 150, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(item.mainAssetPath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey)))), 
            ),
            const SizedBox(height: 12), Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text('Min Order: ${item.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 12))
          ]
        )
      ),
    );
  }
}

class OurProductPage extends StatelessWidget {
  const OurProductPage({super.key});
  @override Widget build(BuildContext context) { 
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
                const Text('Our Product', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 28)), const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: hoodiesDataList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.55, crossAxisSpacing: 16, mainAxisSpacing: 16),
                  itemBuilder: (context, index) {
                    final ProductItem item = hoodiesDataList[index];
                    final String heroTag = 'catalog_${item.name}_$index';
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: item, heroTag: heroTag))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Hero(tag: heroTag, child: Container(width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(item.mainAssetPath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 40)))))), const SizedBox(height: 12), Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text('Min Order: ${item.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 12))]),
                    );
                  },
                )
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
                GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.55, crossAxisSpacing: 16, mainAxisSpacing: 16),
                  itemBuilder: (context, index) {
                    final ProductItem item = hoodiesDataList[index];
                    final String heroTag = 'youth_${item.name}_$index';
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: item, heroTag: heroTag))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Hero(tag: heroTag, child: Container(width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(item.mainAssetPath, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 40)))))), const SizedBox(height: 12), Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text('Min Order: ${item.minOrder} pcs', style: const TextStyle(color: Colors.grey, fontSize: 12))]),
                    );
                  },
                )
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
                    Row(children: [GestureDetector(onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false), child: const Text('Home', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold))), const Text(' > Profile', style: TextStyle(color: Colors.grey, fontSize: 14))]), const SizedBox(height: 16),
                    const Text('ABOUT COMPANY', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24)), const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 120, width: 120, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/images/products/logo hananori.jpeg', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)))), const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: const Text('About Company', style: TextStyle(color: Colors.white, fontSize: 12))), const SizedBox(height: 12), 
                        Text(globalCompanyProfile.aboutText, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5))]))
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('2022', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 20)), SizedBox(height: 4), Text('Founded', style: TextStyle(color: Colors.grey, fontSize: 12))]), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('102', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 20)), SizedBox(height: 4), Text('Client', style: TextStyle(color: Colors.grey, fontSize: 12))]), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('140', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 20)), SizedBox(height: 4), Text('Project Done', style: TextStyle(color: Colors.grey, fontSize: 12))]), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('102', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 20)), SizedBox(height: 4), Text('5-Star Review', style: TextStyle(color: Colors.grey, fontSize: 12))])]),
                    const SizedBox(height: 32), const Text('WHAT WE DO?', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24)), const SizedBox(height: 16),
                  ],
                ),
              ),
              SizedBox(height: 200, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 16), scrollDirection: Axis.horizontal, itemCount: services.length, separatorBuilder: (context, index) => const SizedBox(width: 16), itemBuilder: (context, index) { return SizedBox(width: 150, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 140, width: 150, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(services[index]['image']!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)))), const SizedBox(height: 8), Text(services[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 2)])); })),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Our services are tailored to meet the unique needs of each client.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)), const SizedBox(height: 32), const Text('CONTACT US', style: TextStyle(fontFamily: 'IntegralCF', fontSize: 24)), const SizedBox(height: 16),
                    _buildFigmaContactRow(context, Icons.alternate_email, globalCompanyProfile.igUsername, 'https://instagram.com/${globalCompanyProfile.igUsername.replaceAll('@', '')}'),
                    _buildFigmaContactRow(context, Icons.phone, globalCompanyProfile.waNumber, 'https://wa.me/62${globalCompanyProfile.waNumber.substring(1)}?text=Halo%20Hananori!'),
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
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(urlString);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka link.')));
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, spreadRadius: 1)]), child: Icon(icon, color: Colors.black, size: 20)),
            const SizedBox(width: 16), Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}