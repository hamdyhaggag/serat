/// Surah Header Widget - Decorative header for surah beginning
/// Inspired by Madinah Mushaf design

import 'package:flutter/material.dart';
import '../theme/quran_reader_theme.dart';
import '../data/quran_page_data.dart';

class SurahHeaderWidget extends StatelessWidget {
  final String surahName;
  final int surahNumber;
  final QuranThemeData theme;
  final bool showBismillah;

  const SurahHeaderWidget({
    super.key,
    required this.surahName,
    required this.surahNumber,
    required this.theme,
    this.showBismillah = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Decorative Surah Header
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative frame
              CustomPaint(
                size: const Size(double.infinity, 50),
                painter: SurahHeaderPainter(color: theme.surahHeaderBg),
              ),
              // Surah name
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'سُورَةُ $surahName',
                  style: QuranTypography.surahNameStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bismillah (except for Surah At-Tawbah)
        if (showBismillah && surahNumber != 9 && surahNumber != 1)
          Container(
            margin: const EdgeInsets.only(bottom: 16, top: 8),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: QuranTypography.bismillahStyle(
                color: theme.bismillahColor,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

/// Custom painter for the decorative surah header frame
class SurahHeaderPainter extends CustomPainter {
  final Color color;

  SurahHeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create a decorative frame shape (rounded rectangle with ornamental edges)
    final centerY = size.height / 2;
    final edgeOffset = 20.0;
    final cornerRadius = 8.0;

    // Main rectangle with curved corners
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          edgeOffset, 5, size.width - (edgeOffset * 2), size.height - 10),
      Radius.circular(cornerRadius),
    );

    path.addRRect(rect);

    // Left decorative edge
    path.moveTo(edgeOffset, centerY - 10);
    path.lineTo(5, centerY);
    path.lineTo(edgeOffset, centerY + 10);

    // Right decorative edge
    path.moveTo(size.width - edgeOffset, centerY - 10);
    path.lineTo(size.width - 5, centerY);
    path.lineTo(size.width - edgeOffset, centerY + 10);

    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Verse Number Widget - Diamond shape with Arabic numbers
class VerseNumberWidget extends StatelessWidget {
  final int verseNumber;
  final QuranThemeData theme;
  final double size;

  const VerseNumberWidget({
    super.key,
    required this.verseNumber,
    required this.theme,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: CustomPaint(
        painter: DiamondPainter(
          fillColor: theme.verseNumberBg,
          borderColor: theme.verseNumberBg.withOpacity(0.7),
        ),
        child: Center(
          child: Text(
            ArabicNumbers.convert(verseNumber),
            style: TextStyle(
              fontFamily: 'DIN',
              fontSize: size * 0.4,
              color: theme.verseNumberText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for diamond/rhombus shape
class DiamondPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  DiamondPainter({
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Create diamond shape
    path.moveTo(centerX, 0); // Top
    path.lineTo(size.width, centerY); // Right
    path.lineTo(centerX, size.height); // Bottom
    path.lineTo(0, centerY); // Left
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Page Number Widget - Decorative page number at bottom
class PageNumberWidget extends StatelessWidget {
  final int pageNumber;
  final QuranThemeData theme;

  const PageNumberWidget({
    super.key,
    required this.pageNumber,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left decorative line
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    theme.frameColor.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          // Page number in decorative frame
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.pageNumberBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.frameColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              ArabicNumbers.convert(pageNumber),
              style: TextStyle(
                fontFamily: 'DIN',
                fontSize: 16,
                color: theme.verseNumberText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Right decorative line
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.frameColor.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page Header Widget - Shows Juz, Hizb and Surah name
class PageHeaderWidget extends StatelessWidget {
  final int juzNumber;
  final int hizbNumber;
  final String surahName;
  final QuranThemeData theme;

  const PageHeaderWidget({
    super.key,
    required this.juzNumber,
    required this.hizbNumber,
    required this.surahName,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.headerBg,
        border: Border(
          bottom: BorderSide(
            color: theme.frameColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Juz and Hizb info (left side)
          Text(
            'الجزء ${ArabicNumbers.convert(juzNumber)}، الحزب ${ArabicNumbers.convert(hizbNumber)}',
            style: QuranTypography.headerTextStyle(
              color: theme.frameColor,
              fontSize: 14,
            ),
          ),
          // Surah name (right side)
          Row(
            children: [
              Text(
                surahName,
                style: QuranTypography.headerTextStyle(
                  color: theme.frameColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.bookmark,
                size: 18,
                color: theme.frameColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
