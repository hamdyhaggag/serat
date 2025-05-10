class TimesModel {
  TimesModel({required this.code, required this.status, required this.data});

  final int code;
  final String status;
  final Data data;

  factory TimesModel.fromJson(Map<String, dynamic> json) {
    try {
      return TimesModel(
        code: json["code"] as int? ?? 0,
        status: json["status"] as String? ?? "",
        data: Data.fromJson(json["data"] as Map<String, dynamic>? ?? {}),
      );
    } catch (e) {
      throw Exception('Error parsing TimesModel: $e');
    }
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "status": status,
    "data": data.toJson(),
  };
}

class Data {
  Data({required this.timings, required this.date, required this.meta});

  final Timings timings;
  final Date date;
  final Meta meta;

  factory Data.fromJson(Map<String, dynamic> json) {
    try {
      return Data(
        timings: Timings.fromJson(
          json["timings"] as Map<String, dynamic>? ?? {},
        ),
        date: Date.fromJson(json["date"] as Map<String, dynamic>? ?? {}),
        meta: Meta.fromJson(json["meta"] as Map<String, dynamic>? ?? {}),
      );
    } catch (e) {
      throw Exception('Error parsing Data: $e');
    }
  }

  Map<String, dynamic> toJson() => {
    "timings": timings.toJson(),
    "date": date.toJson(),
    "meta": meta.toJson(),
  };
}

class Date {
  Date({
    required this.readable,
    required this.timestamp,
    required this.hijri,
    required this.gregorian,
  });
  String readable;
  String timestamp;
  Hijri hijri;
  Gregorian gregorian;

  factory Date.fromJson(Map<String, dynamic> json) => Date(
    readable: json["readable"] as String? ?? "",
    timestamp: json["timestamp"] as String? ?? "",
    hijri: Hijri.fromJson(json["hijri"] as Map<String, dynamic>? ?? {}),
    gregorian: Gregorian.fromJson(
      json["gregorian"] as Map<String, dynamic>? ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "readable": readable,
    "timestamp": timestamp,
    "hijri": hijri.toJson(),
    "gregorian": gregorian.toJson(),
  };
}

class Gregorian {
  Gregorian({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
  });
  String date;
  String format;
  String day;
  GregorianWeekday weekday;
  GregorianMonth month;
  String year;

  factory Gregorian.fromJson(Map<String, dynamic> json) => Gregorian(
    date: json["date"] as String? ?? "",
    format: json["format"] as String? ?? "",
    day: json["day"] as String? ?? "",
    weekday: GregorianWeekday.fromJson(
      json["weekday"] as Map<String, dynamic>? ?? {},
    ),
    month: GregorianMonth.fromJson(
      json["month"] as Map<String, dynamic>? ?? {},
    ),
    year: json["year"] as String? ?? "",
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "format": format,
    "day": day,
    "weekday": weekday.toJson(),
    "month": month.toJson(),
    "year": year,
  };
}

class GregorianMonth {
  GregorianMonth({required this.number, required this.en, required this.ar});
  int number;
  String en;
  String ar;

  factory GregorianMonth.fromJson(Map<String, dynamic> json) => GregorianMonth(
    number: json["number"] as int? ?? 0,
    en: json["en"] as String? ?? "",
    ar:
        json["ar"] as String? ??
        json["en"] ??
        "", // Fallback to English if Arabic not available
  );

  Map<String, dynamic> toJson() => {"number": number, "en": en, "ar": ar};
}

class GregorianWeekday {
  GregorianWeekday({required this.en, required this.ar});
  String en;
  String ar;

  factory GregorianWeekday.fromJson(Map<String, dynamic> json) =>
      GregorianWeekday(
        en: json["en"] as String? ?? "",
        ar:
            json["ar"] as String? ??
            json["en"] ??
            "", // Fallback to English if Arabic not available
      );

  Map<String, dynamic> toJson() => {"en": en, "ar": ar};
}

class Hijri {
  Hijri({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
    required this.holidays,
  });
  String date;
  String format;
  String day;
  HijriWeekday weekday;
  HijriMonth month;
  String year;
  List<dynamic> holidays;

  factory Hijri.fromJson(Map<String, dynamic> json) => Hijri(
    date: json["date"] as String? ?? "",
    format: json["format"] as String? ?? "",
    day: json["day"] as String? ?? "",
    weekday: HijriWeekday.fromJson(
      json["weekday"] as Map<String, dynamic>? ?? {},
    ),
    month: HijriMonth.fromJson(json["month"] as Map<String, dynamic>? ?? {}),
    year: json["year"] as String? ?? "",
    holidays: List<dynamic>.from(json["holidays"]?.map((x) => x) ?? []),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "format": format,
    "day": day,
    "weekday": weekday.toJson(),
    "month": month.toJson(),
    "year": year,
    "holidays": holidays,
  };
}

class HijriMonth {
  HijriMonth({required this.number, required this.en, required this.ar});
  int number;
  String en;
  String ar;

  factory HijriMonth.fromJson(Map<String, dynamic> json) => HijriMonth(
    number: json["number"] as int? ?? 0,
    en: json["en"] as String? ?? "",
    ar: json["ar"] as String? ?? "",
  );

  Map<String, dynamic> toJson() => {"number": number, "en": en, "ar": ar};
}

class HijriWeekday {
  HijriWeekday({required this.en, required this.ar});
  String en;
  String ar;

  factory HijriWeekday.fromJson(Map<String, dynamic> json) => HijriWeekday(
    en: json["en"] as String? ?? "",
    ar: json["ar"] as String? ?? "",
  );

  Map<String, dynamic> toJson() => {"en": en, "ar": ar};
}

class Meta {
  Meta({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.method,
    required this.latitudeAdjustmentMethod,
    required this.midnightMode,
    required this.school,
  });
  double latitude;
  double longitude;
  String timezone;
  Method method;
  String latitudeAdjustmentMethod;
  String midnightMode;
  String school;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    latitude: json["latitude"]?.toDouble() ?? 0.0,
    longitude: json["longitude"]?.toDouble() ?? 0.0,
    timezone: json["timezone"] as String? ?? "",
    method: Method.fromJson(json["method"] as Map<String, dynamic>? ?? {}),
    latitudeAdjustmentMethod: json["latitudeAdjustmentMethod"] as String? ?? "",
    midnightMode: json["midnightMode"] as String? ?? "",
    school: json["school"] as String? ?? "",
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
    "timezone": timezone,
    "method": method.toJson(),
    "latitudeAdjustmentMethod": latitudeAdjustmentMethod,
    "midnightMode": midnightMode,
    "school": school,
  };
}

class Method {
  Method({
    required this.id,
    required this.name,
    required this.params,
    required this.location,
  });
  int id;
  String name;
  Params params;
  Location location;

  factory Method.fromJson(Map<String, dynamic> json) => Method(
    id: json["id"] as int? ?? 0,
    name: json["name"] as String? ?? "",
    params: Params.fromJson(json["params"] as Map<String, dynamic>? ?? {}),
    location: Location.fromJson(
      json["location"] as Map<String, dynamic>? ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "params": params.toJson(),
    "location": location.toJson(),
  };
}

class Location {
  Location({required this.latitude, required this.longitude});
  double latitude;
  double longitude;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    latitude: json["latitude"]?.toDouble() ?? 0.0,
    longitude: json["longitude"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class Params {
  Params({required this.fajr, required this.isha});
  double fajr;
  double isha;

  factory Params.fromJson(Map<String, dynamic> json) => Params(
    fajr: json["Fajr"]?.toDouble() ?? 0.0,
    isha: json["Isha"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {"Fajr": fajr, "Isha": isha};
}

class Timings {
  Timings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
  });

  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;

  factory Timings.fromJson(Map<String, dynamic> json) {
    try {
      return Timings(
        fajr: json["Fajr"] as String? ?? "",
        sunrise: json["Sunrise"] as String? ?? "",
        dhuhr: json["Dhuhr"] as String? ?? "",
        asr: json["Asr"] as String? ?? "",
        sunset: json["Sunset"] as String? ?? "",
        maghrib: json["Maghrib"] as String? ?? "",
        isha: json["Isha"] as String? ?? "",
        imsak: json["Imsak"] as String? ?? "",
        midnight: json["Midnight"] as String? ?? "",
      );
    } catch (e) {
      throw Exception('Error parsing Timings: $e');
    }
  }

  Map<String, dynamic> toJson() => {
    "Fajr": fajr,
    "Sunrise": sunrise,
    "Dhuhr": dhuhr,
    "Asr": asr,
    "Sunset": sunset,
    "Maghrib": maghrib,
    "Isha": isha,
    "Imsak": imsak,
    "Midnight": midnight,
  };
}
