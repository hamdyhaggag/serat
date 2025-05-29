class HijriHolidayModel {
  final int code;
  final String status;
  final List<HolidayData> data;

  HijriHolidayModel({
    required this.code,
    required this.status,
    required this.data,
  });

  factory HijriHolidayModel.fromJson(Map<String, dynamic> json) {
    return HijriHolidayModel(
      code: json['code'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map(
                  (item) => HolidayData.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class HolidayData {
  final String name;
  final String description;

  HolidayData({
    required this.name,
    required this.description,
  });

  factory HolidayData.fromJson(Map<String, dynamic> json) {
    return HolidayData(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
