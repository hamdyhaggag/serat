import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Business_Logic/Cubit/settings_states.dart';
import 'package:serat/Data/Shared/cache_helper.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitialState());

  static SettingsCubit get(context) => BlocProvider.of(context);

  int radioValue = 5;

  void changeRadio(int value) {
    radioValue = value;
    CacheHelper.putData(key: 'value', value: value);
    emit(ChangeRadioState());
  }
}
