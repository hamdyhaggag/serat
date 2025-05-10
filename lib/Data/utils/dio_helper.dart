import 'package:dio/dio.dart';

class DioHelper {
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://api.aladhan.com/v1/',
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    double? latitude,
    double? longitude,
    int? method,
  }) async {
    return await dio!.get(
      url,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'method': method,
      },
    );
  }
}
