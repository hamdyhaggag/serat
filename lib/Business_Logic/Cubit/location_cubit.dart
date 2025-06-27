import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:serat/Data/Model/times_model.dart';
import 'package:serat/imports.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  static LocationCubit get(context) => BlocProvider.of(context);

  Position? position;
  bool errorStatus = false;
  TimesModel? timesModel;
  Placemark? address;
  String? administrativeArea;
  String? country;
  String? locality;
  int radioValue = 5;
  String? errorMessage;

  Future<void> getMyCurrentLocation() async {
    emit(GetCurrentAddressLoading());
    errorMessage = null;
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorStatus = true;
        errorMessage = 'خدمة الموقع غير مفعلة. يرجى تفعيل خدمة الموقع.';
        emit(GetCurrentLocationError());
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // Handle permission states
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorStatus = true;
          errorMessage =
              'تم رفض إذن الوصول للموقع. يرجى السماح بالوصول للموقع.';
          emit(GetCurrentLocationError());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorStatus = true;
        errorMessage =
            'تم رفض إذن الوصول للموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.';
        emit(GetCurrentLocationError());
        return;
      }

      // Only proceed if we have permission
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        position = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 10),
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            errorStatus = true;
            errorMessage = 'انتهت مهلة طلب الموقع. يرجى المحاولة مرة أخرى.';
            throw TimeoutException(errorMessage);
          },
        );

        if (position != null) {
          await _getLocationData(position!.latitude, position!.longitude);
        }
        errorStatus = false;
        emit(GetCurrentLocationSuccess());
      }
    } catch (error) {
      errorStatus = true;
      log('Error when getting location: $error');
      if (error is TimeoutException) {
        emit(GetCurrentLocationError());
      } else {
        errorMessage = 'حدث خطأ في تحديد الموقع. يرجى المحاولة مرة أخرى.';
        emit(GetCurrentLocationError());
      }
    }
  }

  Future<void> getTimings({
    required String time,
    required double latitude,
    required double longitude,
  }) async {
    emit(GetCurrentAddressLoading());
    errorMessage = null;
    try {
      final now = DateTime.now();
      final formattedTime =
          "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

      final response = await DioHelper.getData(
        url: "timings/$formattedTime",
        latitude: latitude,
        longitude: longitude,
        method: radioValue,
      );

      log('API Response: [32m${response.data}[0m');

      // Check if response is HTML (indicating a redirection or error page)
      if (response.data is String &&
          (response.data as String).contains('<!DOCTYPE html>')) {
        errorStatus = true;
        errorMessage = 'خطأ في الاتصال بالإنترنت. يرجى التحقق من اتصالك.';
        throw Exception(errorMessage);
      }

      if (response.data is Map<String, dynamic>) {
        try {
          timesModel = TimesModel.fromJson(response.data);
          saveTimeModel(timeModel: timesModel!);
          errorStatus = false;
          emit(GetTimingsSuccess());
        } catch (parseError) {
          errorStatus = true;
          errorMessage =
              'خطأ في تحليل بيانات أوقات الصلاة. يرجى المحاولة مرة أخرى.';
          throw Exception(errorMessage);
        }
      } else {
        errorStatus = true;
        errorMessage = 'تنسيق استجابة غير صالح. يرجى المحاولة مرة أخرى.';
        throw Exception(errorMessage);
      }
    } catch (error) {
      log('getTimings error: $error');
      await _handleError();
    }
  }

  Future<void> getCurrentLocationAddress({
    required double latitude,
    required double longitude,
  }) async {
    emit(GetCurrentAddressLoading());
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        address = placemarks.first;
        administrativeArea = address?.administrativeArea;
        country = address?.country;
        locality = address?.locality;

        CacheHelper.saveData(
          key: 'administrativeArea',
          value: administrativeArea,
        );
        CacheHelper.saveData(key: 'country', value: country);
        CacheHelper.saveData(key: 'locality', value: locality);

        emit(GetCurrentAddressSuccess());
      }
    } catch (error) {
      log('getCurrentLocationAddress error: $error');
      emit(GetCurrentAddressError());
    }
  }

  void changeRadio(int value) {
    radioValue = value;
    emit(ChangeRadio());
    CacheHelper.saveData(key: 'value', value: value);
    getMyCurrentLocation();
  }

  Future<void> _getLocationData(double latitude, double longitude) async {
    await getCurrentLocationAddress(latitude: latitude, longitude: longitude);
    await getTimings(
      latitude: latitude,
      longitude: longitude,
      time: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Future<void> _handleError() async {
    timesModel = await getTimeModel();
    if (timesModel == null) {
      errorStatus = true;
      emit(GetTimingsError());
    } else {
      errorStatus = false;
      emit(GetTimingsSuccess());
    }
  }
}

// Location States
abstract class LocationState {}

class LocationInitial extends LocationState {}

class GetCurrentLocationSuccess extends LocationState {}

class GetCurrentLocationError extends LocationState {}

class GetTimingsSuccess extends LocationState {}

class GetTimingsError extends LocationState {}

class GetCurrentAddressLoading extends LocationState {}

class GetCurrentAddressSuccess extends LocationState {}

class GetCurrentAddressError extends LocationState {}

class ChangeRadio extends LocationState {}
