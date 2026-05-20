import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serat/Data/utils/cache_helper.dart';

abstract class LastReadState {}

class LastReadInitial extends LastReadState {}

class LastReadLoaded extends LastReadState {
  final bool hasData;
  final String title;
  final String subtitle;
  final String type;

  LastReadLoaded({
    required this.hasData,
    this.title = '',
    this.subtitle = '',
    this.type = '',
  });
}

class LastReadCubit extends Cubit<LastReadState> {
  LastReadCubit() : super(LastReadInitial());

  static LastReadCubit get(context) => BlocProvider.of(context);

  void loadLastRead() {
    final lastReadJson = CacheHelper.getString(key: 'LastReadData');
    if (lastReadJson.isNotEmpty) {
      try {
        final data = jsonDecode(lastReadJson);
        emit(LastReadLoaded(
          hasData: true,
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          type: data['type'] ?? '',
        ));
      } catch (e) {
        emit(LastReadLoaded(hasData: false));
      }
    } else {
      emit(LastReadLoaded(hasData: false));
    }
  }

  void saveLastRead({
    required String title,
    required String subtitle,
    required String type,
  }) {
    final data = {
      'title': title,
      'subtitle': subtitle,
      'type': type,
    };
    CacheHelper.saveData(key: 'LastReadData', value: jsonEncode(data));
    emit(LastReadLoaded(
      hasData: true,
      title: title,
      subtitle: subtitle,
      type: type,
    ));
  }
  
  void clearLastRead() {
    CacheHelper.removeData(key: 'LastReadData');
    emit(LastReadLoaded(hasData: false));
  }
}
