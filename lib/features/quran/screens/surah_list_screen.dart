import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:serat/imports.dart';
import '../models/surah_model.dart';
import '../services/surah_service.dart';
import 'package:serat/Presentation/Widgets/share_verse_generator.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen>
    with SingleTickerProviderStateMixin {
  final SurahService _surahService = SurahService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  List<SurahModel> _surahs = [];
  List<SurahModel> _filteredSurahs = [];
  
  bool _isLoading = true;
  late AnimationController _animCtrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: 600.ms);
    _loadSurahs();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _filterSurahs(_searchController.text));
      });
    });
  }

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      setState(() => _filteredSurahs = _surahs);
      return;
    }

    setState(() {
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

  Future<void> _loadSurahs() async {
    final surahs = await _surahService.loadSurahs();
    if (mounted) {
      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
        _isLoading = false;
      });
      _animCtrl.forward();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animCtrl.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _showSurahDetails(BuildContext context, SurahModel surah) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SurahDetailsSheet(surah: surah),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xff0A0A0A) : const Color(0xffF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Elegant Glow Background
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width / 4,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(isDark ? 0.15 : 0.08),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 4.seconds,
                  curve: Curves.easeInOut,
                ),
          ),
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(isDark),
              _buildSearchBar(isDark),
              if (_isLoading)
                _buildShimmer(isDark)
              else if (_filteredSurahs.isEmpty)
                _buildEmptyState(isDark)
              else
                _buildList(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xff0A0A0A).withOpacity(0.9) : const Color(0xffF8F9FA).withOpacity(0.9),
      systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          'بطاقات القرآن',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            ),
          ),
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              hintText: 'ابحث باسم السورة...',
              hintStyle: TextStyle(
                fontFamily: 'Cairo',
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.search_rounded, 
                color: isDark ? Colors.grey[500] : Colors.grey[400], size: 22),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded,
                          color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _filterSurahs('');
                      },
                    )
                  : null,
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildList(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final surah = _filteredSurahs[index];
            final globalIndex = _surahs.indexOf(surah) + 1; // Real surah number
            return _SurahTile(
              surah: surah,
              listIndex: index,
              surahNumber: globalIndex,
              isDark: isDark,
              onTap: () => _showSurahDetails(context, surah),
            );
          },
          childCount: _filteredSurahs.length,
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: isDark ? const Color(0xff2a2a2a) : Colors.grey[200]!,
              highlightColor: isDark ? const Color(0xff3a3a3a) : Colors.grey[50]!,
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            );
          },
          childCount: 8,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.05),
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 48, color: AppColors.primaryColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text('لم يتم العثور على نتائج',
                style: TextStyle(
                    fontFamily: 'Cairo', 
                    color: Colors.grey[500], 
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ).animate().fadeIn().scale(),
      ),
    );
  }
}

// ─── Minimal List Card (No Images) ────────────────────────────────────────────

class _SurahTile extends StatefulWidget {
  final SurahModel surah;
  final int listIndex;
  final int surahNumber;
  final bool isDark;
  final VoidCallback onTap;

  const _SurahTile({
    required this.surah,
    required this.listIndex,
    required this.surahNumber,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SurahTile> createState() => _SurahTileState();
}

class _SurahTileState extends State<_SurahTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = widget.isDark ? const Color(0xff1C1C1E) : Colors.white;
    final shadowColor = widget.isDark ? Colors.black45 : Colors.black.withOpacity(0.04);
    final borderColor = widget.isDark ? Colors.white.withOpacity(0.05) : Colors.transparent;
    final delayMs = (widget.listIndex % 10) * 50;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        final verseText = widget.surah.fadluha.toString().isNotEmpty
            ? widget.surah.fadluha.toString()
            : 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
        ShareVerseGenerator.show(
          context,
          verseText: verseText.length > 200 ? '${verseText.substring(0, 200)}...' : verseText,
          shareText: verseText.length > 200 ? '${verseText.substring(0, 200)}...' : verseText,
          surahName: widget.surah.surah,
          verseNumber: 1,
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: 200.ms,
        child: AnimatedContainer(
          duration: 300.ms,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Elegant Typography Badge
                Hero(
                  tag: 'surah_${widget.surah.surah}_badge',
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(widget.isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(widget.isDark ? 0.3 : 0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${widget.surahNumber}',
                      style: TextStyle(
                        fontFamily: 'Cairo', // Or 'Amiri'
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Surah Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'surah_${widget.surah.surah}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            widget.surah.surah,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.isDark ? Colors.white : AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.surah.ayaatiha,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Chevron icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: widget.isDark ? Colors.grey[600] : Colors.grey[300],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delayMs)).slideY(begin: 0.1, end: 0),
    );
  }
}

// ─── Details Bottom Sheet ─────────────────────────────────────────────────────

class _SurahDetailsSheet extends StatelessWidget {
  final SurahModel surah;

  const _SurahDetailsSheet({required this.surah});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1C1C1E) : const Color(0xffF8F9FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Elegant Header inside Sheet
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xff2F2F2F), const Color(0xff252525)]
                    : [AppColors.primaryColor.withOpacity(0.9), AppColors.primaryColor],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : AppColors.primaryColor.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'surah_${surah.surah}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            surah.surah,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        surah.ayaatiha,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Circular icon representation
                Hero(
                  tag: 'surah_${surah.surah}_badge',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                  ),
                )
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSection(context, 'معنى اسم السورة', surah.maeniAsamuha, isDark),
                _buildSection(context, 'سبب التسمية', surah.sababTasmiatiha, isDark),
                _buildSection(context, 'أسماء السورة', surah.asmawuha, isDark),
                _buildSection(context, 'المقصد العام', surah.maqsiduhaAleamu, isDark),
                _buildSection(context, 'سبب النزول', surah.sababNuzuliha, isDark),
                _buildSection(context, 'فضل السورة', surah.fadluha, isDark),
                _buildSection(context, 'المناسبات', surah.munasabatiha, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, dynamic content, bool isDark) {
    if (content == null || content.toString().trim().isEmpty || content.toString() == '[]') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ).animate().fadeIn(),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              ),
            ),
            child: _buildContent(content, isDark),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildContent(dynamic content, bool isDark) {
    final textColor = isDark ? Colors.grey[300] : Colors.grey[800];
    
    if (content is List && content.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(color: AppColors.primaryColor, fontSize: 18)),
              Expanded(
                child: Text(
                  item.toString(),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: textColor,
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      );
    }
    
    return Text(
      content.toString(),
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: textColor,
        height: 1.8,
      ),
    );
  }
}
