import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Data/Models/quran_video_model.dart';
import 'package:serat/Data/Web_Services/quran_video_web_services.dart';

part 'quran_video_state.dart';

class QuranVideoCubit extends Cubit<QuranVideoState> {
  final QuranVideoWebServices _webServices;

  QuranVideoCubit(this._webServices) : super(QuranVideoInitial());

  static QuranVideoCubit get(context) => BlocProvider.of(context);

  List<QuranVideoModel> videos = [];

  void updateVideos(List<QuranVideoModel> newVideos) {
    videos = newVideos;
    emit(QuranVideoSuccess());
  }

  Future<void> getVideos() async {
    emit(QuranVideoLoading());
    try {
      final response = await _webServices.getVideos();
      videos = response;
      emit(QuranVideoSuccess());
    } catch (e) {
      emit(QuranVideoError(e.toString()));
    }
  }
}
