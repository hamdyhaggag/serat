import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
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
  late final QuranService _quranService;
  bool _isInitialized = false;
  List<QuranChapter>? _cachedChapters;
  List<QuranVerse>? _currentVerses;
  int? _currentChapterNumber;

  QuranCubit() : super(QuranInitial()) {
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _quranService = QuranService(CacheService(prefs));
      _isInitialized = true;
      getChapters();
    } catch (e) {
      dev.log('Error initializing QuranService: $e');
      emit(QuranError('Failed to initialize Quran service'));
    }
  }

  Future<void> getChapters() async {
    if (!_isInitialized) {
      dev.log('QuranService not initialized yet');
      return;
    }

    // If we have cached chapters, emit them immediately
    if (_cachedChapters != null) {
      emit(QuranLoaded(_cachedChapters!));
    }

    // Only emit loading if we don't have cached data
    if (_cachedChapters == null) {
      emit(QuranLoading());
    }

    try {
      dev.log('QuranCubit: Fetching chapters...');
      final chapters = await _quranService.getChapters();
      _cachedChapters = chapters; // Cache the chapters
      dev.log('QuranCubit: Successfully fetched ${chapters.length} chapters');
      emit(QuranLoaded(chapters));
    } catch (e, stackTrace) {
      dev.log('QuranCubit: Error fetching chapters: $e');
      dev.log('QuranCubit: Stack trace: $stackTrace');
      // If we have cached chapters, emit them even on error
      if (_cachedChapters != null) {
        emit(QuranLoaded(_cachedChapters!));
      } else {
        emit(QuranError(e.toString()));
      }
    }
  }

  Future<void> getChapterVerses(int chapterNumber) async {
    if (!_isInitialized) {
      dev.log('QuranService not initialized yet');
      return;
    }

    // If we're already loading verses for this chapter, don't start another load
    if (state is QuranVersesLoading && _currentChapterNumber == chapterNumber) {
      return;
    }

    _currentChapterNumber = chapterNumber;
    emit(QuranVersesLoading(chapterNumber));

    try {
      dev.log('QuranCubit: Fetching verses for chapter $chapterNumber...');
      final verses = await _quranService.getChapterVerses(chapterNumber);
      _currentVerses = verses;
      dev.log('QuranCubit: Successfully fetched ${verses.length} verses');
      // Only emit if we're still loading the same chapter
      if (_currentChapterNumber == chapterNumber) {
        emit(QuranVersesLoaded(chapterNumber, verses));
      }
    } catch (e, stackTrace) {
      dev.log('QuranCubit: Error fetching verses: $e');
      dev.log('QuranCubit: Stack trace: $stackTrace');
      // Only emit error if we're still loading the same chapter
      if (_currentChapterNumber == chapterNumber) {
        emit(QuranVersesError(chapterNumber, e.toString()));
      }
    }
  }

  void returnToChapters() {
    // Clear current verses and chapter number
    _currentVerses = null;
    _currentChapterNumber = null;

    if (_cachedChapters != null) {
      emit(QuranLoaded(_cachedChapters!));
    } else {
      getChapters();
    }
  }
}
