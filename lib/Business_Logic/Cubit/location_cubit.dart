import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:serat/Data/Model/times_model.dart';
import 'package:serat/core/services/home_widget_service.dart';
import 'package:serat/core/services/adhan_service.dart';
import 'package:serat/imports.dart';
import 'package:serat/Data/utils/cache_helper.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial()) {
    loadCachedData();
  }

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
  bool isBackgroundUpdating = false;

  void loadCachedData() async {
    try {
      // Load cached address data
      final cachedAdminArea = CacheHelper.getString(key: 'administrativeArea');
      final cachedCountry = CacheHelper.getString(key: 'country');
      final cachedLocality = CacheHelper.getString(key: 'locality');

      if (cachedAdminArea.isNotEmpty ||
          cachedCountry.isNotEmpty ||
          cachedLocality.isNotEmpty) {
        administrativeArea = cachedAdminArea;
        country = cachedCountry;
        locality = cachedLocality;

        // Create a temporary Placemark with cached data
        address = Placemark(
          administrativeArea: administrativeArea,
          country: country,
          locality: locality,
        );

        emit(GetCurrentAddressSuccess());
      }

      // Load cached timings
      final cachedTimes = await getTimeModel();
      if (cachedTimes != null) {
        timesModel = cachedTimes;
        emit(GetTimingsSuccess());
      }
    } catch (e) {
      log('Error loading cached data: $e');
    }
  }

  Future<void> getMyCurrentLocation() async {
    // Only emit loading if we don't have data, otherwise mark as background update
    if (timesModel == null || address == null) {
      emit(GetCurrentAddressLoading());
    } else {
      isBackgroundUpdating = true;
    }

    errorMessage = null;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorStatus = true;
        errorMessage = 'خدمة الموقع غير مفعلة. يرجى تفعيل خدمة الموقع.';
        if (!isBackgroundUpdating) emit(GetCurrentLocationError());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorStatus = true;
          errorMessage =
              'تم رفض إذن الوصول للموقع. يرجى السماح بالوصول للموقع.';
          if (!isBackgroundUpdating) emit(GetCurrentLocationError());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorStatus = true;
        errorMessage =
            'تم رفض إذن الوصول للموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.';
        if (!isBackgroundUpdating) emit(GetCurrentLocationError());
        return;
      }

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

        // Emit success to refresh UI with new live data
        emit(GetCurrentLocationSuccess());
      }
    } catch (error) {
      errorStatus = true;
      log('Error when getting location: $error');
      if (error is TimeoutException) {
        if (!isBackgroundUpdating) emit(GetCurrentLocationError());
      } else {
        errorMessage = 'حدث خطأ في تحديد الموقع. يرجى المحاولة مرة أخرى.';
        if (!isBackgroundUpdating) emit(GetCurrentLocationError());
      }
    } finally {
      isBackgroundUpdating = false;
    }
  }

  Future<void> getTimings({
    required String time,
    required double latitude,
    required double longitude,
  }) async {
    if (!isBackgroundUpdating) emit(GetCurrentAddressLoading());
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

      log('API Response: ${response.data}');

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
          HomeWidgetService.updatePrayerWidget();
          AdhanService.scheduleAdhans(timesModel!);
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
    if (!isBackgroundUpdating) emit(GetCurrentAddressLoading());
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
      if (!isBackgroundUpdating) emit(GetCurrentAddressError());
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
    // If we have cached data, we might not need to emit error if background update fails,
    // but typically we want to let the UI know if sync failed.
    // However, if we have timesModel (from cache), maybe we fallback to it properly.

    // Attempt to reload from cache one last time or keep existing
    if (timesModel == null) {
      timesModel = await getTimeModel();
    }

    if (timesModel == null) {
      errorStatus = true;
      if (!isBackgroundUpdating) emit(GetTimingsError());
    } else {
      // We have data (cached), so treated as success but maybe showing a snackbar/toast separately
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
