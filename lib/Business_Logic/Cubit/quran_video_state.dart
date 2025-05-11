part of 'quran_video_cubit.dart';

abstract class QuranVideoState {}

class QuranVideoInitial extends QuranVideoState {}

class QuranVideoLoading extends QuranVideoState {}

class QuranVideoSuccess extends QuranVideoState {}

class QuranVideoError extends QuranVideoState {
  final String error;
  QuranVideoError(this.error);
}
