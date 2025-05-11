class QuranVideoModel {
  final int id;
  final String reciterName;
  final List<Video> videos;

  QuranVideoModel({
    required this.id,
    required this.reciterName,
    required this.videos,
  });

  factory QuranVideoModel.fromJson(Map<String, dynamic> json) {
    return QuranVideoModel(
      id: json['id'],
      reciterName: json['reciter_name'],
      videos:
          (json['videos'] as List)
              .map((video) => Video.fromJson(video))
              .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reciter_name': reciterName,
      'videos': videos.map((video) => video.toMap()).toList(),
    };
  }
}

class Video {
  final int id;
  final int videoType;
  final String videoUrl;
  final String videoThumbUrl;

  Video({
    required this.id,
    required this.videoType,
    required this.videoUrl,
    required this.videoThumbUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      videoType: json['video_type'],
      videoUrl: json['video_url'],
      videoThumbUrl: json['video_thumb_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'video_type': videoType,
      'video_url': videoUrl,
      'video_thumb_url': videoThumbUrl,
    };
  }
}
