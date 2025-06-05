import 'package:flutter/foundation.dart';

/// A model class representing a location with its coordinates and name.
/// This class is immutable to ensure thread safety and prevent accidental modifications.
@immutable
class Location {
  /// The latitude of the location
  final double latitude;

  /// The longitude of the location
  final double longitude;

  /// The name of the location (city, country, etc.)
  final String name;

  /// Creates a new [Location] instance.
  const Location({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  /// Creates a copy of this [Location] with the given fields replaced with the new values.
  Location copyWith({
    double? latitude,
    double? longitude,
    String? name,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
    );
  }

  /// Creates a [Location] from a JSON map.
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      name: json['name'] as String,
    );
  }

  /// Converts this [Location] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, name);

  @override
  String toString() =>
      'Location(latitude: $latitude, longitude: $longitude, name: $name)';
}
