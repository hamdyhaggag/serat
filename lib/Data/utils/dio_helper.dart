import 'package:dio/dio.dart';
import 'dart:developer';

class DioHelper {
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.aladhan.com/v1/',
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Add retry interceptor
    dio?.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            // Retry on timeout
            try {
              final response = await dio?.request(
                e.requestOptions.path,
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                ),
              );
              return handler.resolve(response!);
            } catch (e) {
              return handler.next(e as DioException);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    required double latitude,
    required double longitude,
    required int method,
  }) async {
    try {
      final response = await dio!.get(
        url,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
        },
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode != 200) {
        log('API Error: Status code ${response.statusCode}');
        log('Response data: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'API request failed with status code ${response.statusCode}',
        );
      }

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'API response data is null',
        );
      }

      // Check if response is HTML (indicating a redirection or error page)
      if (response.data is String &&
          (response.data as String).contains('<!DOCTYPE html>')) {
        log(
          'Received HTML response instead of JSON. Possible network issue or API endpoint problem.',
        );
        throw DioException(
          requestOptions: response.requestOptions,
          error:
              'Network error: Received HTML response. Please check your internet connection.',
        );
      }

      return response;
    } on DioException catch (e) {
      log('Network error: ${e.message}');
      if (e.response != null) {
        log('Error response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      log('Unexpected error: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }
}
