import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/surah_model.dart';
import '../services/surah_service.dart';
import '../services/image_cache_service.dart';
import '../services/image_cache_manager.dart';

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
  List<SurahModel> _surahs = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final int _cacheExtent = 5;
  bool _isScrolling = false;
  int _lastVisibleIndex = 0;

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
    super.dispose();
  }

  Widget _buildSurahImage(SurahModel surah, int index) {
    if (surah.image.isEmpty) {
      return _buildPlaceholder(index);
    }

    return CachedNetworkImage(
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

  @override
  Widget build(BuildContext context) {
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
                            'القرآن الكريم',
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
                  color: Colors.white,
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'ابحث عن سورة...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
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
                    Colors.white,
                  ],
                ),
              ),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
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
                        itemCount: _surahs.length,
                        itemBuilder: (context, index) {
                          final surah = _surahs[index];
                          return Hero(
                            tag: 'surah_${surah.surah}',
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                  onTap: () => _showSurahDetails(context, surah),
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
                                                Theme.of(context).primaryColor,
                                              ],
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: _buildSurahImage(surah, index),
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
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                surah.ayaatiha,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.play_arrow_rounded,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              // TODO: Implement audio playback
                                            },
                                            padding: EdgeInsets.zero,
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
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
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
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
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
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
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}
