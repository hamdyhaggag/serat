import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:shared_preferences.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/models/quran_verse.dart';
import 'package:serat/Core/services/quran_service.dart';
import 'package:serat/Core/services/cache_service.dart';

// States
abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<QuranChapter> chapters;
  QuranLoaded(this.chapters);
}

class QuranError extends QuranState {
  final String message;
  QuranError(this.message);
}

class QuranVersesLoading extends QuranState {
  final int chapterNumber;
  QuranVersesLoading(this.chapterNumber);
}

class QuranVersesLoaded extends QuranState {
  final int chapterNumber;
  final List<QuranVerse> verses;
  QuranVersesLoaded(this.chapterNumber, this.verses);
}

class QuranVersesError extends QuranState {
  final int chapterNumber;
  final String message;
  QuranVersesError(this.chapterNumber, this.message);
}

// Cubit
class QuranCubit extends Cubit<QuranState> {
  final QuranService _quranService;

  QuranCubit() : _quranService = QuranService(
    CacheService(SharedPreferences.getInstance() as SharedPreferences),
  ), super(QuranInitial());

  Future<void> getChapters() async {
    emit(QuranLoading());
    try {
      dev.log('QuranCubit: Fetching chapters...');
      final chapters = await _quranService.getChapters();
      dev.log('QuranCubit: Successfully fetched ${chapters.length} chapters');
      emit(QuranLoaded(chapters));
    } catch (e, stackTrace) {
      dev.log('QuranCubit: Error fetching chapters: $e');
      dev.log('QuranCubit: Stack trace: $stackTrace');
      emit(QuranError(e.toString()));
    }
  }

  Future<void> getChapterVerses(int chapterNumber) async {
    emit(QuranVersesLoading(chapterNumber));
    try {
      dev.log('QuranCubit: Fetching verses for chapter $chapterNumber...');
      final verses = await _quranService.getChapterVerses(chapterNumber);
      dev.log('QuranCubit: Successfully fetched ${verses.length} verses');
      emit(QuranVersesLoaded(chapterNumber, verses));
    } catch (e, stackTrace) {
      dev.log('QuranCubit: Error fetching verses: $e');
      dev.log('QuranCubit: Stack trace: $stackTrace');
      emit(QuranVersesError(chapterNumber, e.toString()));
    }
  }
}
