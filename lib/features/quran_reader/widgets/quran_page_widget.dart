/// Quran Page Widget - The main page display widget
/// Renders verses with proper Arabic typography and decorative elements
/// Fixed: No scrolling, proper layout, RTL support

import 'package:flutter/material.dart';
import '../data/quran_page_data.dart';
import '../theme/quran_reader_theme.dart';
import 'quran_decorative_widgets.dart';

class QuranPageWidget extends StatelessWidget {
  final QuranPageData pageData;
  final QuranThemeData theme;
  final double fontSize;
  final String primarySurahName;
  final Function(PageVerse)? onVerseTap;
  final Function(PageVerse)? onVerseLongPress;
  final int? highlightedVerse;
  final int? highlightedSurah;

  const QuranPageWidget({
    super.key,
    required this.pageData,
    required this.theme,
    required this.fontSize,
    required this.primarySurahName,
    this.onVerseTap,
    this.onVerseLongPress,
    this.highlightedVerse,
    this.highlightedSurah,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: theme.background,
        child: Column(
          children: [
            // Page Header
            PageHeaderWidget(
              juzNumber: pageData.juzNumber,
              hizbNumber: pageData.hizbNumber,
              surahName: primarySurahName,
              theme: theme,
            ),
            // Main content with decorative frame - NO SCROLL
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.frameColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    color: theme.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: _buildPageContent(),
                  ),
                ),
              ),
            ),
            // Page Number Footer
            PageNumberWidget(
              pageNumber: pageData.pageNumber,
              theme: theme,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    final content = <Widget>[];
    int? currentSurah;

    for (int i = 0; i < pageData.verses.length; i++) {
      final verse = pageData.verses[i];

      // Check if we need to add a surah header
      if (verse.isSurahStart && verse.surahNumber != currentSurah) {
        content.add(
          SurahHeaderWidget(
            surahName: verse.surahName,
            surahNumber: verse.surahNumber,
            theme: theme,
            showBismillah: true,
          ),
        );
        currentSurah = verse.surahNumber;
      } else if (verse.surahNumber != currentSurah && currentSurah == null) {
        currentSurah = verse.surahNumber;
      }
    }

    // Build the verses text with inline verse numbers
    content.add(
      Expanded(
        child: _buildVersesText(),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: content,
    );
  }

  Widget _buildVersesText() {
    // Build inline text with verse numbers
    final textSpans = <InlineSpan>[];

    for (final verse in pageData.verses) {
      // Add verse text
      final isHighlighted = highlightedVerse == verse.verseNumber &&
          highlightedSurah == verse.surahNumber;

      textSpans.add(
        TextSpan(
          text: verse.arabicText,
          style: QuranTypography.quranTextStyle(
            fontSize: fontSize,
            color: isHighlighted ? theme.surahHeaderBg : theme.textColor,
          ),
        ),
      );

      // Add verse number as inline widget
      textSpans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: VerseNumberWidget(
              verseNumber: verse.verseNumber,
              theme: theme,
              size: fontSize * 0.85,
            ),
          ),
        ),
      );

      // Add space between verses
      textSpans.add(
        const TextSpan(text: ' '),
      );
    }

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 380, // Standard page width
        child: Text.rich(
          TextSpan(children: textSpans),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          softWrap: true,
        ),
      ),
    );
  }
}

/// Simplified verse widget for individual verse display (e.g., in lists)
class QuranVerseWidget extends StatelessWidget {
  final PageVerse verse;
  final QuranThemeData theme;
  final double fontSize;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const QuranVerseWidget({
    super.key,
    required this.verse,
    required this.theme,
    required this.fontSize,
    this.isHighlighted = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isHighlighted
              ? theme.surahHeaderBg.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            // Verse number
            VerseNumberWidget(
              verseNumber: verse.verseNumber,
              theme: theme,
              size: fontSize * 0.8,
            ),
            const SizedBox(width: 8),
            // Verse text
            Expanded(
              child: Text(
                verse.arabicText,
                style: QuranTypography.quranTextStyle(
                  fontSize: fontSize,
                  color: theme.textColor,
                ),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
