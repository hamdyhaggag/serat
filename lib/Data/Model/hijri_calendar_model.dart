class HijriCalendarResponse {
  final int code;
  final String status;
  final List<CalendarData> data;

  HijriCalendarResponse({
    required this.code,
    required this.status,
    required this.data,
  });

  factory HijriCalendarResponse.fromJson(Map<String, dynamic> json) {
    return HijriCalendarResponse(
      code: json['code'] as int,
      status: json['status'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => CalendarData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CalendarData {
  final HijriDate hijri;
  final GregorianDate gregorian;

  CalendarData({
    required this.hijri,
    required this.gregorian,
  });

  factory CalendarData.fromJson(Map<String, dynamic> json) {
    return CalendarData(
      hijri: HijriDate.fromJson(json['hijri'] as Map<String, dynamic>),
      gregorian:
          GregorianDate.fromJson(json['gregorian'] as Map<String, dynamic>),
    );
  }
}

class HijriDate {
  final String date;
  final String format;
  final String day;
  final Weekday weekday;
  final Month month;
  final String year;
  final Designation designation;
  final List<String> holidays;
  final List<String> adjustedHolidays;
  final String method;

  HijriDate({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
    required this.designation,
    required this.holidays,
    required this.adjustedHolidays,
    required this.method,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'] as String,
      format: json['format'] as String,
      day: json['day'] as String,
      weekday: Weekday.fromJson(json['weekday'] as Map<String, dynamic>),
      month: Month.fromJson(json['month'] as Map<String, dynamic>),
      year: json['year'] as String,
      designation:
          Designation.fromJson(json['designation'] as Map<String, dynamic>),
      holidays: (json['holidays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      adjustedHolidays: (json['adjustedHolidays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      method: json['method'] as String,
    );
  }
}

class GregorianDate {
  final String date;
  final String format;
  final String day;
  final Weekday weekday;
  final Month month;
  final String year;
  final Designation designation;
  final bool lunarSighting;

  GregorianDate({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
    required this.designation,
    required this.lunarSighting,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'] as String,
      format: json['format'] as String,
      day: json['day'] as String,
      weekday: Weekday.fromJson(json['weekday'] as Map<String, dynamic>),
      month: Month.fromJson(json['month'] as Map<String, dynamic>),
      year: json['year'] as String,
      designation:
          Designation.fromJson(json['designation'] as Map<String, dynamic>),
      lunarSighting: json['lunarSighting'] as bool? ?? false,
    );
  }
}

class Weekday {
  final String en;
  final String? ar;

  Weekday({
    required this.en,
    this.ar,
  });

  factory Weekday.fromJson(Map<String, dynamic> json) {
    return Weekday(
      en: json['en'] as String,
      ar: json['ar'] as String?,
    );
  }
}

class Month {
  final int number;
  final String en;
  final String? ar;
  final int? days;

  Month({
    required this.number,
    required this.en,
    this.ar,
    this.days,
  });

  factory Month.fromJson(Map<String, dynamic> json) {
    return Month(
      number: json['number'] as int,
      en: json['en'] as String,
      ar: json['ar'] as String?,
      days: json['days'] as int?,
    );
  }
}

class Designation {
  final String abbreviated;
  final String expanded;

  Designation({
    required this.abbreviated,
    required this.expanded,
  });

  factory Designation.fromJson(Map<String, dynamic> json) {
    return Designation(
      abbreviated: json['abbreviated'] as String,
      expanded: json['expanded'] as String,
    );
  }
}
