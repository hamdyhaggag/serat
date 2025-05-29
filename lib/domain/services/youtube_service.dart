import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import 'logging_service.dart';

class YoutubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String _tag = 'YoutubeService';

  // YouTube Data API key
  static const String _apiKey = 'AIzaSyDEDbNBIejzhQ3rQqE5UUkpDb4eNcjZJjc';

  YoutubeService() {
    _validateApiKey();
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      LoggingService.error(
        'YouTube API key not configured',
        tag: _tag,
        error: 'Please provide a valid YouTube Data API key',
      );
      throw Exception(
        'YouTube API key not configured. Please update the API key in YoutubeService.',
      );
    }
  }

  Future<List<VideoModel>> getPlaylistVideos(String playlistId) async {
    try {
      LoggingService.info('Fetching videos for playlist: $playlistId',
          tag: _tag);

      final String actualPlaylistId = _extractPlaylistId(playlistId);
      LoggingService.debug('Extracted playlist ID: $actualPlaylistId',
          tag: _tag);

      final url =
          '$_baseUrl/playlistItems?part=snippet&maxResults=50&playlistId=$actualPlaylistId&key=$_apiKey';
      LoggingService.debug('Requesting URL: $url', tag: _tag);

      final response = await http.get(Uri.parse(url));
      LoggingService.debug('Response status code: ${response.statusCode}',
          tag: _tag);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        LoggingService.debug('Response data: $data', tag: _tag);

        if (data['items'] == null || data['items'].isEmpty) {
          LoggingService.warning('No videos found in playlist', tag: _tag);
          throw Exception('No videos found in playlist');
        }

        final videos = data['items'].map<VideoModel>((item) {
          try {
            return VideoModel.fromJson(item);
          } catch (e, stackTrace) {
            LoggingService.error(
              'Error parsing video',
              tag: _tag,
              error: e,
              stackTrace: stackTrace,
            );
            rethrow;
          }
        }).toList();

        LoggingService.info('Successfully loaded ${videos.length} videos',
            tag: _tag);
        return videos;
      } else {
        final error = json.decode(response.body);
        LoggingService.error(
          'Failed to load playlist videos',
          tag: _tag,
          error: error,
        );
        throw Exception(
            'Failed to load playlist videos: ${error['error']['message']}');
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error in getPlaylistVideos',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Error fetching playlist videos: $e');
    }
  }

  String _extractPlaylistId(String input) {
    LoggingService.debug('Extracting playlist ID from: $input', tag: _tag);

    if (input.contains('youtube.com') || input.contains('youtu.be')) {
      final uri = Uri.parse(input);
      final queryParams = uri.queryParameters;
      LoggingService.debug('Query parameters: $queryParams', tag: _tag);

      if (queryParams.containsKey('list')) {
        final id = queryParams['list']!;
        LoggingService.debug('Found playlist ID in query params: $id',
            tag: _tag);
        return id;
      } else if (input.contains('playlist?list=')) {
        final id = input.split('playlist?list=')[1].split('&')[0];
        LoggingService.debug('Found playlist ID in URL: $id', tag: _tag);
        return id;
      }
    }

    LoggingService.debug('Using input as playlist ID: $input', tag: _tag);
    return input;
  }
}
