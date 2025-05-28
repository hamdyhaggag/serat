import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/surah_model.dart';
import '../services/surah_service.dart';
import '../services/image_cache_service.dart';
import '../services/image_cache_manager.dart';
import 'dart:async';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({Key? key}) : super(key: key);

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen>
    with SingleTickerProviderStateMixin {
  final SurahService _surahService = SurahService();
  final ImageCacheService _imageCacheService = ImageCacheService();
  final ImageCacheManager _imageCacheManager = ImageCacheManager();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<SurahModel> _surahs = [];
  List<SurahModel> _filteredSurahs = [];
  bool _isLoading = true;
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final int _cacheExtent = 5;
  bool _isScrolling = false;
  int _lastVisibleIndex = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _initializeServices();
    _setupScrollListener();
    _setupSearchListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.isScrollingNotifier.value) {
        _isScrolling = true;
        _lastVisibleIndex = (_scrollController.position.pixels / 100).floor();
        _preloadImages();
      } else {
        _isScrolling = false;
      }
    });
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _filterSurahs(_searchController.text);
          });
        }
      });
    });
  }

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurahs = _surahs;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredSurahs = _surahs.where((surah) {
        final surahName = surah.surah.toLowerCase();
        final surahNumber = (_surahs.indexOf(surah) + 1).toString();
        final searchQuery = query.toLowerCase();

        return surahName.contains(searchQuery) ||
            surahNumber.contains(searchQuery) ||
            surah.maeniAsamuha.toLowerCase().contains(searchQuery) ||
            surah.asmawuha.toString().toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _preloadImages() async {
    if (!_isScrolling) return;

    final int startIndex = _lastVisibleIndex - 2;
    final int endIndex = _lastVisibleIndex + 3;

    for (int i = startIndex; i <= endIndex; i++) {
      if (i >= 0 && i < _surahs.length) {
        final surah = _surahs[i];
        if (surah.image.isNotEmpty) {
          await _imageCacheManager.getCachedImagePath(surah.image);
        }
      }
    }
  }

  Future<void> _initializeServices() async {
    await _imageCacheService.init();
    await _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final surahs = await _surahService.loadSurahs();
    if (mounted) {
      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
        _isLoading = false;
      });
      _animationController.forward();
      _preloadInitialImages(surahs);
    }
  }

  Future<void> _preloadInitialImages(List<SurahModel> surahs) async {
    for (var i = 0; i < surahs.length && i < _cacheExtent; i++) {
      if (surahs[i].image.isNotEmpty) {
        await _imageCacheManager.getCachedImagePath(surahs[i].image);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _showFullScreenImage(BuildContext context, SurahModel surah, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageView(
            imageUrl: surah.image,
            heroTag: 'surah_${surah.surah}',
            index: index,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildSurahImage(SurahModel surah, int index) {
    if (surah.image.isEmpty) {
      return _buildPlaceholder(index);
    }

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, surah, index),
      child: CachedNetworkImage(
        imageUrl: surah.image,
        width: 65,
        height: 65,
        fit: BoxFit.cover,
        memCacheWidth: 130,
        memCacheHeight: 130,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => _buildPlaceholder(index),
        errorWidget: (context, url, error) => _buildPlaceholder(index),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(int index) {
    return Center(
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : Colors.white;
  }

  Color _getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.white;
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[300]!
        : Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'بطاقات القرآن',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                height: 60,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن سورة...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 16,
                        fontFamily: 'Din',
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterSurahs('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getTextColor(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.05),
                    _getBackgroundColor(context),
                  ],
                ),
              ),
              child: _isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : _isSearching && _filteredSurahs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لم يتم العثور على نتائج',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _getSecondaryTextColor(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'حاول البحث بكلمات مختلفة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getSecondaryTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            itemCount: _filteredSurahs.length,
                            itemBuilder: (context, index) {
                              final surah = _filteredSurahs[index];
                              return Hero(
                                tag: 'surah_${surah.surah}',
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: _getCardColor(context),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () =>
                                          _showSurahDetails(context, surah),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 65,
                                              height: 65,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.8),
                                                    Theme.of(context)
                                                        .primaryColor,
                                                  ],
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: _buildSurahImage(
                                                    surah, index),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    surah.surah,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: _getTextColor(
                                                          context),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    surah.ayaatiha,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color:
                                                          _getSecondaryTextColor(
                                                              context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSurahDetails(BuildContext context, SurahModel surah) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'surah_${surah.surah}',
                        child: Text(
                          surah.surah,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailSection('عدد الآيات', surah.ayaatiha),
                      _buildDetailSection(
                          'معنى اسم السورة', surah.maeniAsamuha),
                      _buildDetailSection('سبب التسمية', surah.sababTasmiatiha),
                      _buildDetailSection('أسماء السورة', surah.asmawuha),
                      _buildDetailSection(
                          'مقصدها العام', surah.maqsiduhaAleamu),
                      _buildDetailSection('سبب نزولها', surah.sababNuzuliha),
                      _buildDetailSection('فضلها', surah.fadluha),
                      _buildDetailSection('مناسباتها', surah.munasabatiha),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, dynamic content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          if (content is List)
            ...content.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color: _getTextColor(context),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
          else
            Text(
              content.toString(),
              style: TextStyle(
                fontSize: 16,
                color: _getTextColor(context),
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenImageView extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final int index;

  const _FullScreenImageView({
    required this.imageUrl,
    required this.heroTag,
    required this.index,
  });

  @override
  State<_FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<_FullScreenImageView> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;
  double _scale = 1.0;
  bool _isZoomed = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    if (_isZoomed) {
      _transformationController.value = Matrix4.identity();
      setState(() => _isZoomed = false);
    } else {
      final position = _doubleTapDetails!.localPosition;
      final double scale = 2.0;
      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);

      final Matrix4 zoomedMatrix = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);

      _transformationController.value = zoomedMatrix;
      setState(() => _isZoomed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 1.0,
            maxScale: 4.0,
            onInteractionUpdate: (details) {
              setState(() {
                _scale = details.scale;
                _isZoomed = _scale > 1.0;
              });
            },
            child: Center(
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTapDown,
                onDoubleTap: _handleDoubleTap,
                child: Hero(
                  tag: widget.heroTag,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'فشل تحميل الصورة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          if (_isZoomed)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'مكبّر ${(_scale * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
