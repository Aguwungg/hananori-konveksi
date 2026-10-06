import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'data_models.dart';

/// Menampilkan gambar produk dari asset lokal ATAU URL (mis. ImgBB).
class ProductImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final Alignment alignment;
  final double iconSize;
  final IconData iconData;
  const ProductImage({super.key, required this.path, this.fit = BoxFit.cover, this.alignment = Alignment.center, this.iconSize = 24, this.iconData = Icons.image_not_supported});

  @override
  Widget build(BuildContext context) {
    final Widget fallback = Center(child: Icon(iconData, color: Colors.grey, size: iconSize));
    if (path.isEmpty) return fallback;
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        alignment: alignment,
        loadingBuilder: (c, child, progress) => progress == null ? child : const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        errorBuilder: (c, e, s) => fallback,
      );
    }
    return Image.asset(path, fit: fit, alignment: alignment, errorBuilder: (c, e, s) => fallback);
  }
}

/// Thumbnail "zoom": mengisi penuh bingkai (crop), fokus ke bagian atas-tengah foto
/// agar kepala model / bagian atas baju tidak terpotong.
class ThumbImage extends StatelessWidget {
  final String path;
  final double iconSize;
  const ThumbImage({super.key, required this.path, this.iconSize = 24});

  @override
  Widget build(BuildContext context) => ProductImage(path: path, fit: BoxFit.cover, alignment: const Alignment(0, -0.6), iconSize: iconSize);
}

/// Menampilkan foto sesuai rasio aslinya (tanpa crop). Rasio dibatasi agar foto
/// yang sangat panjang/lebar tidak merusak layout halaman.
class OriginalRatioImage extends StatefulWidget {
  final String path;
  final double radius;
  final double minRatio;
  final double maxRatio;
  final VoidCallback? onTap;
  const OriginalRatioImage({super.key, required this.path, this.radius = 16, this.minRatio = 0.55, this.maxRatio = 1.6, this.onTap});

  @override
  State<OriginalRatioImage> createState() => _OriginalRatioImageState();
}

class _OriginalRatioImageState extends State<OriginalRatioImage> {
  double? _ratio;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant OriginalRatioImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _resolve();
  }

  void _resolve() {
    _detach();
    if (widget.path.isEmpty) return;
    final ImageProvider provider = widget.path.startsWith('http') ? NetworkImage(widget.path) : AssetImage(widget.path);
    _stream = provider.resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener(
      (info, _) {
        if (mounted) setState(() => _ratio = info.image.width / info.image.height);
      },
      onError: (e, s) {
        if (mounted) setState(() => _ratio = 4 / 5);
      },
    );
    _stream!.addListener(_listener!);
  }

  void _detach() {
    if (_stream != null && _listener != null) _stream!.removeListener(_listener!);
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double ratio = (_ratio ?? 4 / 5).clamp(widget.minRatio, widget.maxRatio).toDouble();
    final BorderRadius r = BorderRadius.circular(widget.radius);
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: ratio,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              foregroundDecoration: BoxDecoration(borderRadius: r, border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1))),
              decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], borderRadius: r),
              child: ClipRRect(borderRadius: r, child: ProductImage(path: widget.path, fit: BoxFit.contain, iconSize: 50)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gambar produk yang selalu tampil UTUH (tidak terpotong).
/// Sisa ruang bingkai diisi versi blur dari foto yang sama agar tetap estetik.
class FramedProductImage extends StatelessWidget {
  final String path;
  final double iconSize;
  final double radius;
  const FramedProductImage({super.key, required this.path, this.iconSize = 24, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    final BorderRadius r = BorderRadius.circular(radius);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Widget content = path.isEmpty
        ? ProductImage(path: path, iconSize: iconSize)
        : Stack(
            fit: StackFit.expand,
            children: [
              // Lapisan blur; tileMode mirror menghindari tepi transparan sehingga tidak perlu di-scale
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18, tileMode: TileMode.mirror),
                child: ProductImage(path: path, fit: BoxFit.cover),
              ),
              Container(color: Colors.white.withValues(alpha: 0.35)),
              ProductImage(path: path, fit: BoxFit.contain, iconSize: iconSize),
            ],
          );
    return Container(
      // Garis tepi tipis: foto berlatar putih tetap terlihat punya bingkai
      foregroundDecoration: BoxDecoration(borderRadius: r, border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1))),
      child: ClipRRect(
        borderRadius: r,
        clipBehavior: Clip.hardEdge,
        child: RepaintBoundary(child: content),
      ),
    );
  }
}

/// Membaca produk dari Firebase secara real-time.
/// Produk baru dari Admin Panel otomatis muncul tanpa restart.
class ProductsBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, List<ProductItem> products) builder;
  const ProductsBuilder({super.key, required this.builder});

  @override
  State<ProductsBuilder> createState() => _ProductsBuilderState();
}

class _ProductsBuilderState extends State<ProductsBuilder> {
  late final Stream<List<ProductItem>> _stream = productsStream();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductItem>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return widget.builder(context, hoodiesDataList);
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator()));
        }
        return widget.builder(context, snapshot.data!);
      },
    );
  }
}

/// Chip filter kategori (All, T-Shirt, Hoodie, dst).
class CategoryChips extends StatefulWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsets padding;
  const CategoryChips({super.key, required this.categories, required this.selected, required this.onSelected, this.padding = const EdgeInsets.symmetric(horizontal: 16)});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  List<GlobalKey> _keys = [];
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.categories.length, (i) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void didUpdateWidget(CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories.length != widget.categories.length) {
      _keys = List.generate(widget.categories.length, (i) => GlobalKey());
    }
    if (oldWidget.selected != widget.selected || oldWidget.categories != widget.categories) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
    }
  }

  void _updateIndicator() {
    if (!mounted) return;
    int index = widget.categories.indexOf(widget.selected);
    if (index == -1 || index >= _keys.length) return;
    
    final RenderBox? renderBox = _keys[index].currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
    
    if (renderBox != null && stackBox != null) {
      final position = renderBox.localToGlobal(Offset.zero, ancestor: stackBox);
      setState(() {
        _indicatorLeft = position.dx;
        _indicatorWidth = renderBox.size.width - 24; // Dikurangi right padding agar persis selebar teks
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Fallback jika belum terukur
    if (_indicatorWidth == 0 && widget.categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: Stack(
        children: [
          Row(
            children: widget.categories.asMap().entries.map((entry) {
              final int i = entry.key;
              final String c = entry.value;
              final bool isSel = c == widget.selected;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  key: _keys[i],
                  onTap: () => widget.onSelected(c),
                  child: Container(
                    padding: const EdgeInsets.only(right: 24, bottom: 8, top: 8),
                    color: Colors.transparent, // Ensure tap area is large enough
                    child: Text(
                      c.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'IntegralCF',
                        fontSize: 14,
                        color: isSel ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            bottom: 0,
            left: _indicatorLeft,
            width: _indicatorWidth > 0 ? _indicatorWidth : 32,
            height: 3,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.amber : Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
