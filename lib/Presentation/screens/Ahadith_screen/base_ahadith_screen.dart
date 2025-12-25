import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:serat/imports.dart' hide AppColors;
import 'package:serat/domain/models/hadith_model.dart';
import 'hadith_card.dart';
import 'package:serat/shared/constants/app_colors.dart';

class BaseAhadithScreen extends StatefulWidget {
  final String title;
  final HadithModel hadith;

  const BaseAhadithScreen({
    super.key,
    required this.title,
    required this.hadith,
  });

  @override
  State<BaseAhadithScreen> createState() => _BaseAhadithScreenState();
}

class _BaseAhadithScreenState extends State<BaseAhadithScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  double _fontSize = 16.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shareHadith() {
    final String shareText =
        'حديث نبوي: \n\n${widget.hadith.hadithText}\n\nالشرح:\n${widget.hadith.explanation}';
    Share.share(shareText);
  }

  void _copyToClipboard() {
    final String text =
        '${widget.hadith.hadithText}\n\n${widget.hadith.explanation}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // The original SnackBar had 'content'. The instruction provided 'title'.
        // SnackBar does not have a 'title' property. Assuming the intent was to replace the 'content'.
        // The methods _buildHighlightedText and _highlightText, and the variable chapterName are not defined in the provided context.
        // To maintain syntactical correctness as per instructions, I'm replacing 'content' with a placeholder Text widget.
        // If _buildHighlightedText, _highlightText, and chapterName are intended to be added, they need to be defined elsewhere.
        content: const Text('تم النسخ إلى الحافظة',
            style: TextStyle(fontFamily: 'Cairo')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _adjustFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(12.0, 24.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : const Color(0xffF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "تفاصيل الحديث",
          style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.primaryColor),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
              size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
              onPressed: _copyToClipboard),
          IconButton(
              icon: const Icon(Icons.share_rounded, size: 20),
              color: isDarkMode ? Colors.white : AppColors.primaryColor,
              onPressed: _shareHadith),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    HadithCard(
                      hadithNumber: widget.hadith.hadithNumber,
                      hadithText: widget.hadith.hadithText,
                      explanation: widget.hadith.explanation,
                      heroTag: 'hadith_${widget.hadith.id}',
                      fontSize: _fontSize,
                    ),
                    const SizedBox(height: 32),
                    _buildControlPanel(isDarkMode),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildControlPanel(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              onPressed: () => _adjustFontSize(-1),
              color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Text(
            'حجم الخط: ${_fontSize.toInt()}',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(width: 8),
          IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () => _adjustFontSize(1),
              color: AppColors.primaryColor),
        ],
      ),
    );
  }
}
