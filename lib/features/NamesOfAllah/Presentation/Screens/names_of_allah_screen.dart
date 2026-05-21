import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:serat/imports.dart';
import 'package:serat/Features/NamesOfAllah/Data/Model/names_of_allah_model.dart';
import 'package:serat/Features/NamesOfAllah/Business_Logic/Services/names_of_allah_service.dart';

// ─── Pro Minimal Design ───────────────────────────────────────────────────────

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen>
    with SingleTickerProviderStateMixin {
  List<NamesOfAllahModel> _names = [];
  List<NamesOfAllahModel> _filtered = [];
  bool _isLoading = true;
  double _fontScale = 1.0;
  final TextEditingController _searchCtrl = TextEditingController();
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: 800.ms);
    _loadNames();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNames() async {
    try {
      final names = await NamesOfAllahService.loadNamesOfAllah();
      if (mounted) {
        setState(() {
          _names = names;
          _filtered = names;
          _isLoading = false;
        });
        _animCtrl.forward();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = query.isEmpty
          ? _names
          : _names
              .where((n) => n.name.contains(query) || n.text.contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xff0A0A0A) : const Color(0xffF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Subtle Top Glow Background
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
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(isDark),
              _buildSearchBar(isDark),
              if (_isLoading)
                _buildShimmer(isDark)
              else if (_filtered.isEmpty)
                _buildEmptyState()
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
      actions: [
        PopupMenuButton<double>(
          icon: Icon(Icons.text_fields_rounded, 
            color: isDark ? Colors.white : Colors.black87),
          tooltip: 'حجم الخط',
          color: isDark ? const Color(0xff1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (v) => setState(() => _fontScale = v),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 0.85, child: Text('صغير', style: TextStyle(fontFamily: 'Cairo'))),
            const PopupMenuItem(value: 1.0, child: Text('متوسط', style: TextStyle(fontFamily: 'Cairo'))),
            const PopupMenuItem(value: 1.2, child: Text('كبير', style: TextStyle(fontFamily: 'Cairo'))),
            const PopupMenuItem(value: 1.4, child: Text('كبير جداً', style: TextStyle(fontFamily: 'Cairo'))),
          ],
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          'أسماء الله الحسنى',
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
            controller: _searchCtrl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            onChanged: _onSearch,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              hintText: 'ابحث عن اسم من أسماء الله...',
              hintStyle: TextStyle(
                fontFamily: 'Cairo',
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.search_rounded, 
                color: isDark ? Colors.grey[500] : Colors.grey[400], size: 22),
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
            final name = _filtered[index];
            return _NameTile(
              name: name,
              index: index,
              fontScale: _fontScale,
              isDark: isDark,
            );
          },
          childCount: _filtered.length,
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
                height: 140,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            );
          },
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            Text('لم نجد نتائج مطابقة',
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

// ─── Elegant List Card ────────────────────────────────────────────────────────

class _NameTile extends StatefulWidget {
  final NamesOfAllahModel name;
  final int index;
  final double fontScale;
  final bool isDark;

  const _NameTile({
    required this.name,
    required this.index,
    required this.fontScale,
    required this.isDark,
  });

  @override
  State<_NameTile> createState() => _NameTileState();
}

class _NameTileState extends State<_NameTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = widget.isDark ? const Color(0xff1C1C1E) : Colors.white;
    final shadowColor = widget.isDark ? Colors.black45 : Colors.black.withOpacity(0.04);
    final borderColor = widget.isDark ? Colors.white.withOpacity(0.05) : Colors.transparent;
    final delayMs = (widget.index % 10) * 60;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _isExpanded = !_isExpanded);
      },
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.fastOutSlowIn,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Beautiful Watermark Name
              Positioned(
                left: -20,
                bottom: -30,
                child: Text(
                  widget.name.name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor.withOpacity(widget.isDark ? 0.03 : 0.02),
                    height: 1.0,
                  ),
                ),
              ),
              
              // Decorative Strip
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Trailing info/icon
                        Icon(
                          _isExpanded 
                              ? Icons.keyboard_arrow_up_rounded 
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey[400],
                          size: 28,
                        ),
                        
                        // Main Name
                        Expanded(
                          child: Text(
                            widget.name.name,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 28 * widget.fontScale,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryColor,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Meaning Text
                    AnimatedCrossFade(
                      firstChild: Text(
                        widget.name.text,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15 * widget.fontScale,
                          color: widget.isDark ? Colors.grey[400] : Colors.grey[700],
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(
                        widget.name.text,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15 * widget.fontScale,
                          color: widget.isDark ? Colors.grey[300] : Colors.grey[800],
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      crossFadeState: _isExpanded 
                          ? CrossFadeState.showSecond 
                          : CrossFadeState.showFirst,
                      duration: 300.ms,
                      sizeCurve: Curves.fastOutSlowIn,
                    ),
                    
                    if (_isExpanded) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            icon: Icons.copy_rounded,
                            label: 'نسخ',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Clipboard.setData(ClipboardData(text: '${widget.name.name}\n${widget.name.text}'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم نسخ الاسم والمعنى', style: TextStyle(fontFamily: 'Cairo')),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            icon: Icons.share_rounded,
                            label: 'مشاركة',
                            isPrimary: true,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Share.share('اسم الله: ${widget.name.name}\n\n${widget.name.text}\n\nتمت المشاركة من تطبيق صراط');
                            },
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delayMs)).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required String label, 
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final bgColor = isPrimary 
        ? AppColors.primaryColor 
        : (widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1));
    final fgColor = isPrimary 
        ? Colors.white 
        : (widget.isDark ? Colors.grey[300]! : Colors.grey[800]!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fgColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
