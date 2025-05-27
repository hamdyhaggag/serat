import 'dart:async';
import 'package:http/http.dart' as http;

class ErrorMapper {
  static String getFriendlyMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'انتهت مهلة الطلب. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
    }

    if (error is http.ClientException) {
      return 'فشل الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
    }

    if (error is FormatException) {
      return 'حدث خطأ في تنسيق البيانات. يرجى المحاولة مرة أخرى.';
    }

    if (error is Exception) {
      final message = error.toString().toLowerCase();

      if (message.contains('socket')) {
        return 'فشل الاتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';
      }

      if (message.contains('timeout')) {
        return 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';
      }

      if (message.contains('permission')) {
        return 'لا يوجد لديك الصلاحيات المطلوبة. يرجى التحقق من الإعدادات.';
      }

      if (message.contains('not found')) {
        return 'لم يتم العثور على البيانات المطلوبة. يرجى المحاولة مرة أخرى.';
      }

      if (message.contains('unauthorized')) {
        return 'غير مصرح لك بالوصول. يرجى التحقق من إعداداتك.';
      }

      if (message.contains('server')) {
        return 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';
      }
    }

    // Default error message
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  }

  static String getHadithErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'انتهت مهلة طلب الحديث. يرجى المحاولة مرة أخرى.';
    }

    if (error is http.ClientException) {
      return 'فشل الاتصال بخادم الأحاديث. يرجى التحقق من اتصالك بالإنترنت.';
    }

    if (error is FormatException) {
      return 'حدث خطأ في تنسيق الحديث. يرجى المحاولة مرة أخرى.';
    }

    if (error is Exception) {
      final message = error.toString().toLowerCase();

      if (message.contains('random')) {
        return 'فشل في تحميل الحديث العشوائي. يرجى المحاولة مرة أخرى.';
      }

      if (message.contains('invalid')) {
        return 'تنسيق استجابة غير صالح. يرجى المحاولة مرة أخرى.';
      }

      if (message.contains('data')) {
        return 'لم يتم العثور على محتوى الحديث. يرجى المحاولة مرة أخرى.';
      }
    }

    // Default hadith error message
    return 'حدث خطأ في تحميل الحديث. يرجى المحاولة مرة أخرى.';
  }
}
