part of 'quran_cubit.dart';

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