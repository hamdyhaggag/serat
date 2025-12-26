import 'dart:math' as math;
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

    // First, calculate locally for instant offline support
    final localDirection = _calculateQibla(latitude, longitude);
    directionModel = DirectionModel(
      code: 200,
      status: "OK",
      data: Data(
        latitude: latitude,
        longitude: longitude,
        direction: localDirection,
      ),
    );

    // We can still try to refresh from API if online, but local is sufficient
    try {
      isFromCache = false;
      emit(GetQiblaDirectionSuccess());

      // Background sync with API if possible, but don't block
      _syncWithApi(latitude, longitude);
    } catch (error) {
      log('getQiblaDirection local success error: $error');
      emit(GetQiblaDirectionSuccess());
    }
  }

  double _calculateQibla(double lat, double lon) {
    const phiK = 21.422487; // Kaaba Latitude
    const lambdaK = 39.826206; // Kaaba Longitude

    final phi = lat * math.pi / 180;
    final lambda = lon * math.pi / 180;
    final phiKRad = phiK * math.pi / 180;
    final lambdaKRad = lambdaK * math.pi / 180;

    final deltaLambda = lambdaKRad - lambda;

    final y = math.sin(deltaLambda);
    final x = math.cos(phi) * math.tan(phiKRad) -
        math.sin(phi) * math.cos(deltaLambda);

    var qibla = math.atan2(y, x) * 180 / math.pi;
    return (qibla + 360) % 360;
  }

  Future<void> _syncWithApi(double latitude, double longitude) async {
    try {
      final value = await DioHelper.getData(
        url: "qibla/$latitude/$longitude",
        latitude: latitude,
        longitude: longitude,
        method: 5,
      );

      if (value.data is Map<String, dynamic>) {
        directionModel = DirectionModel.fromJson(value.data);
        await CacheHelper.saveData(
          key: 'cached_qibla_direction',
          value: jsonEncode(directionModel!.toJson()),
        );
      }
    } catch (e) {
      log("API Sync failed: $e");
    }
  }
}

// Qibla States
abstract class QiblaState {}

class QiblaInitial extends QiblaState {}

class GetQiblaDirectionLoading extends QiblaState {}

class GetQiblaDirectionSuccess extends QiblaState {}

class GetQiblaDirectionError extends QiblaState {}
