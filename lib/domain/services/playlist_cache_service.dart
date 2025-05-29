import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class PlaylistCacheService {
  static const String _cacheKey = 'cached_playlists';

  Future<void> cachePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> playlistsJson = playlists
        .map((playlist) => {
              'title': playlist.title,
              'playlistId': playlist.playlistId,
              'thumbnailUrl': playlist.thumbnailUrl,
            })
        .toList();

    await prefs.setString(_cacheKey, jsonEncode(playlistsJson));
  }

  Future<List<PlaylistModel>> getCachedPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(_cacheKey);

    if (cachedData == null) return [];

    final List<dynamic> playlistsJson = jsonDecode(cachedData);
    return playlistsJson
        .map((json) => PlaylistModel(
              title: json['title'],
              playlistId: json['playlistId'],
              thumbnailUrl: json['thumbnailUrl'],
            ))
        .toList();
  }

  Future<bool> hasCachedPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKey);
  }
}
