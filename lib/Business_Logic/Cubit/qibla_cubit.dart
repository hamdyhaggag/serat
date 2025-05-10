import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Data/Model/direction_model.dart';
import 'package:serat/imports.dart';

class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit() : super(QiblaInitial());

  static QiblaCubit get(context) => BlocProvider.of(context);

  DirectionModel? directionModel;

  Future<void> getQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    emit(GetQiblaDirectionLoading());
    try {
      final value = await DioHelper.getData(
        url: "qibla/$latitude/$longitude",
        latitude: latitude,
        longitude: longitude,
        method: 5, // Using default method for qibla calculation
      );

      if (value.data is Map<String, dynamic>) {
        directionModel = DirectionModel.fromJson(value.data);
        emit(GetQiblaDirectionSuccess());
      } else {
        throw Exception('Invalid response format');
      }
    } catch (error) {
      log('getQiblaDirection error: $error');
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
