

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/service/offline_service.dart';

import '../model/song.dart';

class OfflineProvider extends ChangeNotifier {

  final Box _offlineBox = Hive.box('downloaded');

  final List<Map<String, dynamic>> _offlineSongs = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get offlineSongs => _offlineSongs;


  OfflineProvider() {
    _loadOfflineSongs();
  }

  void _loadOfflineSongs() {
    _isLoading = true;
    notifyListeners();
    _offlineSongs.addAll(
      _offlineBox.values
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOfflineSong(Song song, DownloadProgress downloadProgress) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final localPath = await OfflineService().downloadSong(song: song, downloadProgress: downloadProgress);
      _offlineSongs.add({
        'id': song.id,
        'title': song.title,
        'artist': song.artist,
        'artwork150': song.artwork150,
        'artwork500': song.artwork500,
        'filePath': localPath,
      });

    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeOfflineSong(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final song = _offlineBox.get(id);

      if (song != null && song['filePath'] != null) {
        final file = File(song['filePath']);

        if (await file.exists()) {
          await file.delete();
        }
      }

      await _offlineBox.delete(id);

      _offlineSongs.removeWhere((e) => e['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete offline song: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }

}