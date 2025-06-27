import 'dart:developer';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Data/Model/direction_model.dart';
import 'package:serat/imports.dart';
import 'package:flutter/foundation.dart';

class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit() : super(QiblaInitial());

  static QiblaCubit get(context) => BlocProvider.of(context);

  DirectionModel? directionModel;
  bool isFromCache = false;

  Future<void> getQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    emit(GetQiblaDirectionLoading());
    isFromCache = false;
    try {
      final value = await DioHelper.getData(
        url: "qibla/$latitude/$longitude",
        latitude: latitude,
        longitude: longitude,
        method: 5, // Using default method for qibla calculation
      );

      if (value.data is Map<String, dynamic>) {
        directionModel = DirectionModel.fromJson(value.data);
        isFromCache = false;
        // Cache the direction model as JSON string
        await CacheHelper.saveData(
          key: 'cached_qibla_direction',
          value: jsonEncode(directionModel!.toJson()),
        );
        emit(GetQiblaDirectionSuccess());
      } else {
        throw Exception('Invalid response format');
      }
    } catch (error) {
      log('getQiblaDirection error: $error');
      // Try to load from cache
      final cached = CacheHelper.getString(key: 'cached_qibla_direction');
      if (cached.isNotEmpty) {
        try {
          directionModel = DirectionModel.fromJson(jsonDecode(cached));
          isFromCache = true;
          emit(GetQiblaDirectionSuccess());
          return;
        } catch (e) {
          // ignore cache error, fallback to error state
        }
      }
      emit(GetQiblaDirectionError());
    }
  }
}

// Qibla States
abstract class QiblaState {}

class QiblaInitial extends QiblaState {}

class GetQiblaDirectionLoading extends QiblaState {}

class GetQiblaDirectionSuccess extends QiblaState {}

class GetQiblaDirectionError extends QiblaState {}
