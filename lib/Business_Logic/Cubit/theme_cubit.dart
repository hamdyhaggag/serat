import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/imports.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());

  static ThemeCubit get(context) => BlocProvider.of(context);

  bool isLightMode = true;

  void changeAppMode({required bool? isLight}) {
    isLightMode = !isLightMode;
    CacheHelper.saveData(key: 'isLight', value: isLightMode);
    emit(ThemeChangeModeState());
  }
}

// Theme States
abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeChangeModeState extends ThemeState {}
