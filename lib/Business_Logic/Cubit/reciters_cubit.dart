import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/reciter_model.dart';

class RecitersCubit extends Cubit<RecitersState> {
  RecitersCubit() : super(RecitersInitial());

  static RecitersCubit get(context) => BlocProvider.of(context);

  ReciterModel? recitersModel;
  bool isLoading = false;
  String? error;

  Future<void> getReciters({
    String? language,
    int? reciterId,
    int? rewayaId,
    int? suraId,
  }) async {
    try {
      isLoading = true;
      error = null;
      emit(RecitersLoading());

      final queryParams = <String, String>{};
      if (language != null) queryParams['language'] = language;
      if (reciterId != null) queryParams['reciter'] = reciterId.toString();
      if (rewayaId != null) queryParams['rewaya'] = rewayaId.toString();
      if (suraId != null) queryParams['sura'] = suraId.toString();

      final uri = Uri.https('www.mp3quran.net', '/api/v3/reciters', queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['reciters'] != null) {
          recitersModel = ReciterModel.fromJson(jsonResponse);
          isLoading = false;
          emit(RecitersSuccess());
        } else {
          error = 'No reciters found';
          isLoading = false;
          emit(RecitersError(error!));
        }
      } else if (response.statusCode == 404) {
        error = 'No reciters found with the specified criteria';
        isLoading = false;
        emit(RecitersError(error!));
      } else if (response.statusCode == 400) {
        error = 'Invalid parameters provided';
        isLoading = false;
        emit(RecitersError(error!));
      } else {
        error = 'Failed to load reciters (Status code: ${response.statusCode})';
        isLoading = false;
        emit(RecitersError(error!));
      }
    } catch (e) {
      error = 'Network error: ${e.toString()}';
      isLoading = false;
      emit(RecitersError(error!));
    }
  }
}

abstract class RecitersState {}

class RecitersInitial extends RecitersState {}

class RecitersLoading extends RecitersState {}

class RecitersSuccess extends RecitersState {}

class RecitersError extends RecitersState {
  final String message;
  RecitersError(this.message);
} 