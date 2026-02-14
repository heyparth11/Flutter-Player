import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/service/offline_service.dart';
import 'package:music_player/data/service/recent_plays.dart';

import '../model/song.dart';

class RecentPlaysProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _songs = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> get songs => _songs;

  RecentPlaysProvider() {
    _loadSongs();
  }

  void _loadSongs() {
    _isLoading = true;
    notifyListeners();
    _songs.addAll(RecentPlayedService().getAll());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> add(Song song) async {
    _isLoading = true;
    notifyListeners();

    try {
      RecentPlayedService().add(
        type: 'song',
        id: song.id,
        title: song.title,
        artwork: song.artwork150,
        playbackUrl: song.url,
        artist: song.artist,
        year: '',
      );
      final now = DateTime.now().millisecondsSinceEpoch;

      _songs.add({'type': 'song',
        'id': song.id,
        'title': song.title,
        'artwork': song.artwork150,
        'playbackUrl': song.url,
        'artist': song.artist,
        'year': '',
        'timestamp': now,
      }
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeSong(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      RecentPlayedService().delete(id);
      _songs.removeWhere((e) => e['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete offline song: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
