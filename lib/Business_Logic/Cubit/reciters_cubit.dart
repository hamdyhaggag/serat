import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/reciter_model.dart';
import 'package:serat/Data/services/reciters_cache_service.dart';

class RecitersCubit extends Cubit<RecitersState> {
  final RecitersCacheService _cacheService = RecitersCacheService();

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
    bool forceRefresh = false,
  }) async {
    try {
      isLoading = true;
      error = null;
      emit(RecitersLoading());

      // Try to get cached data first if not forcing refresh
      if (!forceRefresh) {
        final cachedModel = await _cacheService.getCachedReciters();
        if (cachedModel != null) {
          recitersModel = cachedModel;
          isLoading = false;
          emit(RecitersSuccess());
          return;
        }
      }

      final queryParams = <String, String>{};
      if (language != null) queryParams['language'] = language;
      if (reciterId != null) queryParams['reciter'] = reciterId.toString();
      if (rewayaId != null) queryParams['rewaya'] = rewayaId.toString();
      if (suraId != null) queryParams['sura'] = suraId.toString();

      final uri = Uri.https(
        'www.mp3quran.net',
        '/api/v3/reciters',
        queryParams,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['reciters'] != null) {
          recitersModel = ReciterModel.fromJson(jsonResponse);
          // Cache the new data
          await _cacheService.cacheReciters(recitersModel!);
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
      // If there's a network error, try to get cached data
      final cachedModel = await _cacheService.getCachedReciters();
      if (cachedModel != null) {
        recitersModel = cachedModel;
        isLoading = false;
        emit(RecitersSuccess());
        return;
      }

      error = 'Network error: ${e.toString()}';
      isLoading = false;
      emit(RecitersError(error!));
    }
  }

  Future<void> clearCache() async {
    await _cacheService.clearCache();
    recitersModel = null;
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
