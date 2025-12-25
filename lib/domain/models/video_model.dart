import '../services/logging_service.dart';

class VideoModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final String publishedAt;
  static const String _tag = 'VideoModel';

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    try {
      LoggingService.debug('Parsing video JSON: $json', tag: _tag);

      // Handle cached data (flat structure)
      if (json['id'] is String && json['snippet'] == null) {
        return VideoModel(
          id: json['id'],
          title: json['title'],
          thumbnailUrl: json['thumbnailUrl'],
          channelTitle: json['channelTitle'],
          publishedAt: json['publishedAt'],
        );
      }

      // Handle YouTube API response (nested structure)
      final String videoId = json['id'] is Map
          ? json['id']['videoId']
          : json['snippet']['resourceId']['videoId'];

      LoggingService.debug('Extracted video ID: $videoId', tag: _tag);

      final video = VideoModel(
        id: videoId,
        title: json['snippet']['title'],
        thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
        channelTitle: json['snippet']['channelTitle'],
        publishedAt: json['snippet']['publishedAt'],
      );

      LoggingService.debug('Created video model: $video', tag: _tag);
      return video;
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error parsing video JSON',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'channelTitle': channelTitle,
      'publishedAt': publishedAt,
    };
  }

  @override
  String toString() {
    return 'VideoModel(id: $id, title: $title, channelTitle: $channelTitle)';
  }
}
