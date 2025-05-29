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
      code: json['code'],
      status: json['status'],
      data: (json['data'] as List)
          .map((item) => HolidayData.fromJson(item))
          .toList(),
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
      name: json['name'],
      description: json['description'],
    );
  }
}
