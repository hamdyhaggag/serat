import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serat/Data/Models/quran_video_model.dart';

class QuranVideoWebServices {
  final String baseUrl = 'https://mp3quran.net/api/v3/videos';

  Future<List<QuranVideoModel>> getVideos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?language=ar'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> videosList = data['videos'];
        return videosList
            .map((video) => QuranVideoModel.fromJson(video))
            .toList();
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
