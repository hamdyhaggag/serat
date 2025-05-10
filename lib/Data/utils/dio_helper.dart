import 'package:dio/dio.dart';

class DioHelper {
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://api.aladhan.com/v1/',
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    double? latitude,
    double? longitude,
    int? method,
  }) async {
    try {
      final response = await dio!.get(
        url,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
        },
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }

      return response;
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        error: 'Network error: ${e.message}',
      );
    }
  }
}
