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
      await Geolocator.requestPermission();
      position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(milliseconds: 3000),
        desiredAccuracy: LocationAccuracy.high,
      );
      if (position != null) {
        await _getLocationData(position!.latitude, position!.longitude);
      }
      emit(GetCurrentLocationSuccess());
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
    time = time.substring(0, time.length - 3);
    try {
      final value = await DioHelper.getData(
        url: "timings/$time",
        latitude: latitude,
        longitude: longitude,
        method: radioValue,
      );
      timesModel = TimesModel.fromJson(value.data);
      saveTimeModel(timeModel: timesModel!);
      emit(GetTimingsSuccess());
    } catch (error) {
      log('getTimings error: $error');
      _handleError();
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
