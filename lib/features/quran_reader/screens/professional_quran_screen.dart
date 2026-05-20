/// Professional Quran Reader Screen using quran_library package
/// This provides exact Madinah Mushaf rendering using KFGQPC fonts

import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:serat/Presentation/Config/constants/colors.dart';
import 'package:serat/Presentation/Widgets/share_verse_generator.dart';

class ProfessionalQuranScreen extends StatelessWidget {
  final int? initialSurah;
  final int? initialPage;
  final int? initialJuz;

  const ProfessionalQuranScreen({
    super.key,
    this.initialSurah,
    this.initialPage,
    this.initialJuz,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Attempting to navigate after build
    // Note: If jumpTo methods are static or accessible via instance, functionality will work.
    // Commented out to prevent build errors until API is confirmed.
    /*
    if (initialSurah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // QuranLibrary.jumpToSurah(initialSurah!); 
      });
    }
    */

    return QuranLibraryScreen(
      parentContext: context,
      withPageView: true,
      useDefaultAppBar: true,
      isShowAudioSlider: true,
      showAyahBookmarkedIcon: true,
      isDark: isDarkMode,
      appLanguageCode: 'ar',
      // Correct param placement
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFFFFDF5),
      textColor: isDarkMode ? Colors.white : Colors.black87,
      ayahSelectedBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
      ayahIconColor: AppColors.primaryColor,
      surahInfoStyle: SurahInfoStyle.defaults(
        isDark: isDarkMode,
        context: context,
      ).copyWith(
        ayahCount: 'عدد الآيات',
        firstTabText: 'أسماء السور',
        secondTabText: 'عن السورة',
      ),
      basmalaStyle: BasmalaStyle(
        verticalPadding: 0.0,
        basmalaColor:
            isDarkMode ? const Color(0xFFD4AF37) : AppColors.primaryColor,
        basmalaFontSize: 25.0,
      ),
      ayahStyle: AyahAudioStyle.defaults(
        isDark: isDarkMode,
        context: context,
      ).copyWith(
        dialogWidth: 300,
        readersTabText: 'القراء',
      ),
      topBarStyle: QuranTopBarStyle.defaults(
        isDark: isDarkMode,
        context: context,
      ).copyWith(
        showAudioButton: true, // Audio button enabled
        showFontsButton: true, // Fonts download button enabled
        tabIndexLabel: 'الفهرس',
        tabBookmarksLabel: 'المفضلة',
        tabSearchLabel: 'البحث',
        backgroundColor: AppColors.primaryColor,
      ),
      indexTabStyle: IndexTabStyle.defaults(
        isDark: isDarkMode,
        context: context,
      ).copyWith(
        tabSurahsLabel: 'السور',
        tabJozzLabel: 'الأجزاء',
      ),
      searchTabStyle: SearchTabStyle.defaults(
        isDark: isDarkMode,
        context: context,
      ).copyWith(
        searchHintText: 'ابحث في القرآن الكريم...',
      ),
      bookmarksTabStyle: BookmarksTabStyle.defaults(
        isDark: isDarkMode,
        context: context,
      ).copyWith(
        emptyStateText: 'لا توجد علامات مرجعية بعد',
        greenGroupText: 'المفضلة الخضراء',
        yellowGroupText: 'المفضلة الصفراء',
        redGroupText: 'المفضلة الحمراء',
      ),
      // ignore: deprecated_member_use
      anotherMenuChild: Icon(
        Icons.share_rounded,
        color: AppColors.primaryColor,
        size: 24,
      ),
      // ignore: deprecated_member_use
      anotherMenuChildOnTap: (AyahModel ayah) {
        // Use ayaTextEmlaey (standard Unicode) for sharing — 'text' may be
        // font-encoded and unreadable outside the app.
        final shareText = ayah.ayaTextEmlaey.isNotEmpty
            ? ayah.ayaTextEmlaey
            : ayah.text;
            
        // Use the original text for the Uthmanic font rendering
        final verseText = ayah.text;

        // arabicName is populated for original fonts; fall back to QuranCtrl
        // for downloaded fonts where it may be null.
        final surahData = QuranLibrary().getCurrentSurahDataByAyahUniqueNumber(ayahUniqueNumber: ayah.ayahUQNumber);
        final surahName = ayah.arabicName?.isNotEmpty == true
            ? ayah.arabicName!
            : surahData.arabicName;

        // IMPORTANT: Defer to the next event-loop tick.
        // The library calls close() immediately after this callback returns,
        // which calls Navigator.pop(). If we push the BottomSheet
        // synchronously here, that pop removes the BottomSheet instead of
        // the menu dialog. Delaying by one tick lets the dialog dismiss
        // first, then the BottomSheet is pushed onto a clean navigator stack.
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            final surahAyahs = surahData.ayahs;
            final initialAyahIndex = surahAyahs.indexWhere((a) => a.ayahNumber == ayah.ayahNumber);
            
            ShareVerseGenerator.show(
              context,
              verseText: verseText,
              shareText: shareText,
              surahName: surahName,
              verseNumber: ayah.ayahNumber,
              surahAyahs: surahAyahs,
              initialAyahIndex: initialAyahIndex != -1 ? initialAyahIndex : null,
            );
          }
        });
      },
      ayahMenuStyle: AyahMenuStyle.defaults(
        isDark: isDarkMode,
        context: context,
      ).copyWith(
        copySuccessMessage: 'تم نسخ الآية',
        showPlayAllButton: true,
      ),
      tafsirStyle: TafsirStyle.defaults(
        isDark: isDarkMode,
        context: context,
      ).copyWith(
        widthOfBottomSheet: MediaQuery.of(context).size.width,
        heightOfBottomSheet: MediaQuery.of(context).size.height * 0.9,
        tafsirName: 'التفسير',
        translateName: 'الترجمة',
        tafsirIsEmptyNote: 'التفسير غير متوفر',
        footnotesName: 'الحواشي',
      ),
      topBottomQuranStyle: TopBottomQuranStyle.defaults(
        isDark: isDarkMode,
        context: context,
      ).copyWith(
        hizbName: 'الحزب',
        juzName: 'الجزء',
        sajdaName: 'سجدة',
        // Removed backgroundColor and textColor which caused errors
        pageNumberColor: AppColors.primaryColor,
      ),
    );
  }
}
