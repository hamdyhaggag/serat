import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran_library/quran_library.dart';
import 'package:gal/gal.dart';

class ShareTheme {
  final String name;
  final Color bg;
  final Color frame;
  final Color text;

  const ShareTheme(this.name, this.bg, this.frame, this.text);
}

enum ShareRatio {
  auto('تلقائي', null),
  square('مربع', 1.0),
  story('ستوري', 9 / 16);

  final String label;
  final double? value;
  const ShareRatio(this.label, this.value);
}

class ShareVerseGenerator extends StatefulWidget {
  final String verseText;
  final String shareText;
  final String surahName;
  final int verseNumber;
  final List<AyahModel>? surahAyahs;
  final int? initialAyahIndex;

  const ShareVerseGenerator({
    super.key,
    required this.verseText,
    required this.shareText,
    required this.surahName,
    required this.verseNumber,
    this.surahAyahs,
    this.initialAyahIndex,
  });

  static Future<void> show(
    BuildContext context, {
    required String verseText,
    required String shareText,
    required String surahName,
    required int verseNumber,
    List<AyahModel>? surahAyahs,
    int? initialAyahIndex,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareVerseGenerator(
        verseText: verseText,
        shareText: shareText,
        surahName: surahName,
        verseNumber: verseNumber,
        surahAyahs: surahAyahs,
        initialAyahIndex: initialAyahIndex,
      ),
    );
  }

  @override
  State<ShareVerseGenerator> createState() => _ShareVerseGeneratorState();
}

class _ShareVerseGeneratorState extends State<ShareVerseGenerator> {
  final GlobalKey _globalKey = GlobalKey();

  // Status states
  bool _isSharing = false;
  bool _isSaving = false;
  bool _showSaveSuccess = false;

  bool _showBasmala = true;

  late int _startIndex;
  late int _endIndex;

  static const String _basmala = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';

  // Personalization
  int _selectedThemeIndex = 0;
  ShareRatio _selectedRatio = ShareRatio.auto;

  final List<ShareTheme> _themes = const [
    ShareTheme(
        'كلاسيك', Color(0xFFFFFDF5), Color(0xFF137058), Color(0xFF1A1A1A)),
  ];

  ShareTheme get _theme => _themes[_selectedThemeIndex];

  @override
  void initState() {
    super.initState();
    if (widget.surahAyahs != null && widget.initialAyahIndex != null) {
      _startIndex = widget.initialAyahIndex!;
      _endIndex = widget.initialAyahIndex!;
    }
  }

  bool get _canExpandRange =>
      widget.surahAyahs != null && widget.initialAyahIndex != null;

  String get _currentShareText {
    if (!_canExpandRange) return widget.shareText;
    final ayahs = widget.surahAyahs!.sublist(_startIndex, _endIndex + 1);
    return ayahs
        .map((a) => a.ayaTextEmlaey.isNotEmpty ? a.ayaTextEmlaey : a.text)
        .join(' ');
  }

  String get _cleanSurahName {
    final name = widget.surahName.trim();
    return name.replaceAll(
        RegExp(r'^(سورة|سُورَةُ|سُورَةَ|سُورَةِ|سُورَةٌ)\s*'), '');
  }

  String get _currentReference {
    if (!_canExpandRange || _startIndex == _endIndex) {
      return 'سورة $_cleanSurahName  •  الآية ${widget.verseNumber}';
    }
    final endVerseNum = widget.surahAyahs![_endIndex].ayahNumber;
    return 'سورة $_cleanSurahName  •  الآيات ${widget.verseNumber}-$endVerseNum';
  }

  double get _dynamicFontSize {
    final length = _currentShareText.length;
    if (length < 100) return 28.0;
    if (length < 250) return 24.0;
    if (length < 500) return 20.0;
    return 16.0;
  }

  void _incrementEnd() {
    if (_canExpandRange && _endIndex < widget.surahAyahs!.length - 1) {
      HapticFeedback.lightImpact();
      setState(() => _endIndex++);
    }
  }

  void _decrementEnd() {
    if (_canExpandRange && _endIndex > _startIndex) {
      HapticFeedback.lightImpact();
      setState(() => _endIndex--);
    }
  }

  String _toArabicNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'[0-9]'),
        (Match m) =>
            String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x0660 - 0x0030));
  }

  List<TextSpan> get _ayahSpans {
    final List<TextSpan> spans = [];
    final fontSize = _dynamicFontSize;

    void addAyah(String text, int number) {
      final cleanText = text
          .replaceAll(
              RegExp(
                  r'(?:\s*[\u06DD]\s*)?(?:\s*[﴿\uFD3F]\s*)?\s*[\u0660-\u0669\u06F0-\u06F9]+\s*(?:[﴾\uFD3E])?\s*$'),
              '')
          .trimRight();

      spans.add(TextSpan(
        text: '$cleanText ',
        style: TextStyle(
          fontFamily: 'hafs',
          package: 'quran_library',
          fontSize: fontSize,
          color: _theme.text,
          height: 2.0,
        ),
      ));

      final arabicNum = _toArabicNumber(number);
      spans.add(TextSpan(
        text: '\uFD3F$arabicNum\uFD3E ',
        style: TextStyle(
          fontFamily: 'hafs',
          package: 'quran_library',
          fontSize: fontSize * 0.9,
          color: _theme.frame,
        ),
      ));
    }

    if (!_canExpandRange) {
      addAyah(widget.verseText, widget.verseNumber);
    } else {
      final ayahs = widget.surahAyahs!.sublist(_startIndex, _endIndex + 1);
      for (final a in ayahs) {
        addAyah(a.text, a.ayahNumber);
      }
    }

    return spans;
  }

  // ── Capture & Share ──────────────────────────────────────────────────────

  Future<Uint8List> _captureCard() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<String> _saveToTemp(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/share_verse_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> _onShare() async {
    setState(() => _isSharing = true);
    try {
      final bytes = await _captureCard();
      final path = await _saveToTemp(bytes);
      String textToShare =
          '﴿${_currentShareText}﴾\n[${_currentReference.replaceAll("  •  ", ": ")}]\n';
      textToShare += '\nتطبيق صراط';

      await Share.shareXFiles(
        [XFile(path)],
        text: textToShare,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء المشاركة')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _onSave() async {
    setState(() {
      _isSaving = true;
      _showSaveSuccess = false;
    });
    try {
      final bytes = await _captureCard();
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync();
      }
      final file = File(
          '${downloadsDir.path}/Serat_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _showSaveSuccess = true;
        });
        HapticFeedback.lightImpact();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showSaveSuccess = false);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء الحفظ')),
        );
      }
    }
  }

  // ── Build UI ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final labelColor = isDark ? Colors.white70 : Colors.black54;

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'شارك الآية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Preview Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RepaintBoundary(
                          key: _globalKey,
                          child: Container(
                            alignment: Alignment.center,
                            color: _theme
                                .bg, // Fill background for transparency safety
                            child: _buildDynamicCard(),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(begin: const Offset(0.95, 0.95)),

                      const SizedBox(height: 24),

                      // Personalization
                      _buildSectionTitle(
                          'شكل المشاركة', Icons.aspect_ratio_rounded),
                      _buildRatioSelector(),

                      // const SizedBox(height: 16),
                      // _buildSectionTitle('المظهر', Icons.palette_rounded),
                      // _buildThemeSelector(),

                      if (_canExpandRange) ...[
                        const SizedBox(height: 16),
                        _buildSectionTitle(
                            'نطاق الآيات', Icons.unfold_more_rounded),
                        _buildRangeControls(),
                      ],

                      const SizedBox(height: 16),
                      _buildSectionTitle('خيارات', Icons.tune_rounded),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildToggle(
                          label: 'أرفق البسملة',
                          value: _showBasmala,
                          onChanged: (v) => setState(() => _showBasmala = v),
                          color: _theme.frame,
                          labelColor: labelColor,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Actions
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicCard() {
    Widget card = Container(
      decoration: BoxDecoration(
        color: _theme.bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _theme.frame.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: _theme.frame,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/logo.webp',
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                      color: Colors.white.withValues(alpha: 0.1),
                      colorBlendMode: BlendMode.srcATop,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'صراط',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _cleanSurahName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontFamily: 'Cairo',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Basmala
                    if (_showBasmala) ...[
                      Text(
                        _basmala,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'hafs',
                          package: 'quran_library',
                          fontSize: 18,
                          color: _theme.frame,
                          height: 2.0,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Verse
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text.rich(
                        TextSpan(children: _ayahSpans),
                        key: ValueKey('$_startIndex-$_endIndex'),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Reference
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _theme.frame.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentReference,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: _theme.frame,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (_selectedRatio.value != null) {
      return AspectRatio(
        aspectRatio: _selectedRatio.value!,
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: card,
          ),
        ),
      );
    }

    return card;
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ShareRatio.values.length,
        itemBuilder: (context, i) {
          final ratio = ShareRatio.values[i];
          final selected = _selectedRatio == ratio;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(ratio.label,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
              selected: selected,
              onSelected: (v) => setState(() => _selectedRatio = ratio),
              selectedColor: _theme.frame.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: selected ? _theme.frame : Colors.grey[700],
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: selected
                    ? _theme.frame
                    : Colors.grey.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeSelector() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _themes.length,
        itemBuilder: (context, i) {
          final theme = _themes[i];
          final selected = _selectedThemeIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedThemeIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? theme.frame
                      : Colors.grey.withValues(alpha: 0.3),
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: theme.frame.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                theme.name,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  color: theme.frame,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRangeControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _endIndex < widget.surahAyahs!.length - 1
                  ? _incrementEnd
                  : null,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'زود آية',
                style:
                    TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _theme.frame,
                side: BorderSide(
                    color: _endIndex < widget.surahAyahs!.length - 1
                        ? _theme.frame.withValues(alpha: 0.5)
                        : Colors.grey.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _endIndex > _startIndex ? _decrementEnd : null,
              icon: const Icon(Icons.remove_rounded, size: 18),
              label: const Text(
                'نقص آية',
                style:
                    TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                side: BorderSide(
                    color: _endIndex > _startIndex
                        ? Colors.red[700]!.withValues(alpha: 0.5)
                        : Colors.grey.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: value
            ? color.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? color.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Save Button (Secondary Action)
          OutlinedButton(
            onPressed:
                _isSaving || _isSharing || _showSaveSuccess ? null : _onSave,
            style: OutlinedButton.styleFrom(
              foregroundColor: _theme.frame,
              side: BorderSide(color: _theme.frame),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showSaveSuccess
                  ? const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 24)
                  : _isSaving
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _theme.frame,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          // Share Button (Primary Action)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSharing || _isSaving ? null : _onShare,
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.share_rounded, size: 20),
              label: Text(
                _isSharing ? 'جاري التحضير...' : 'مشاركة الآية',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _theme.frame,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
