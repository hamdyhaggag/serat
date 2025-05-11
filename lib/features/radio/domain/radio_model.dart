class RadioStation {
  final int id;
  final String name;
  final String url;

  RadioStation({required this.id, required this.name, required this.url});

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
