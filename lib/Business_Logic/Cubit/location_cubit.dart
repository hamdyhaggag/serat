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

  Future<void> getMyCurrentLocation() async {
    emit(GetCurrentAddressLoading());
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled. Please enable location services.',
        );
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // Handle permission states
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. Please enable them in app settings.',
        );
      }

      // Only proceed if we have permission
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        position = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(milliseconds: 3000),
          desiredAccuracy: LocationAccuracy.high,
        );

        if (position != null) {
          await _getLocationData(position!.latitude, position!.longitude);
        }
        emit(GetCurrentLocationSuccess());
      }
    } catch (error) {
      errorStatus = true;
      log('Error when getting location: $error');
      emit(GetCurrentLocationError());
    }
  }

  Future<void> getTimings({
    required String time,
    required double latitude,
    required double longitude,
  }) async {
    emit(GetCurrentAddressLoading());
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

      // Check if response is HTML (indicating a redirection or error page)
      if (response.data is String &&
          (response.data as String).contains('<!DOCTYPE html>')) {
        log(
          'Received HTML response instead of JSON. Possible network issue or API endpoint problem.',
        );
        throw Exception(
          'Network error: Received HTML response. Please check your internet connection.',
        );
      }

      if (response.data is Map<String, dynamic>) {
        try {
          timesModel = TimesModel.fromJson(response.data);
          saveTimeModel(timeModel: timesModel!);
          emit(GetTimingsSuccess());
        } catch (parseError) {
          log('Error parsing response: $parseError');
          throw Exception('Error parsing prayer times data: $parseError');
        }
      } else {
        log('Invalid response type: ${response.data.runtimeType}');
        throw Exception(
          'Invalid response format: Expected Map<String, dynamic> but got ${response.data.runtimeType}',
        );
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
