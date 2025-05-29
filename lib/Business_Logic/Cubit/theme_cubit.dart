import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/imports.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial()) {
    _loadThemeFromCache();
  }

  static ThemeCubit get(context) => BlocProvider.of(context);

  bool isLightMode = true;

  void _loadThemeFromCache() {
    final cachedTheme = CacheHelper.getBoolean(key: 'isLight');
    if (cachedTheme != null) {
      isLightMode = cachedTheme;
      emit(ThemeChangeModeState());
    }
  }

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
