import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Core/models/quran_chapter.dart';
import 'package:serat/Core/services/quran_service.dart';

part 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final QuranService _quranService;

  QuranCubit(this._quranService) : super(QuranInitial());

  static QuranCubit get(context) => BlocProvider.of(context);

  Future<void> getQuranChapters() async {
    emit(QuranLoading());
    try {
      final chapters = await _quranService.getChapters();
      emit(QuranLoaded(chapters));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }
} 