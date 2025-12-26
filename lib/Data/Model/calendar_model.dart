import 'times_model.dart';

class CalendarModel {
  CalendarModel({required this.code, required this.status, required this.data});

  final int code;
  final String status;
  final List<Data> data;

  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    try {
      return CalendarModel(
        code: json["code"] as int? ?? 0,
        status: json["status"] as String? ?? "",
        data: (json["data"] as List? ?? [])
            .map((e) => Data.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw Exception('Error parsing CalendarModel: $e');
    }
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "data": data.map((e) => e.toJson()).toList(),
      };
}
