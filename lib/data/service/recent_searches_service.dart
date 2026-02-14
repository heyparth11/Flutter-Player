
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/service/recent_plays.dart';

enum RecentType {
  song,
  album,
}

class RecentSearchService {
  static const _boxName = 'recent_searches';
  static const _maxItems = 20;

  final Box _box = Hive.box(_boxName);

  void add({
    required String type,
    required String id,
    required String title,
    required String artwork,
    required String playbackUrl,
    required String artist,
    required String year,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final existingKey = _box.keys.firstWhere(
          (key) =>
      _box.get(key)['id'] == id &&
          _box.get(key)['type'] == type,
      orElse: () => null,
    );

    if (existingKey != null) {
      _box.delete(existingKey);
    }

    _box.add({
      'type': type,
      'id': id,
      'title': title,
      'artist': artist,
      'artwork': artwork,
      'playbackUrl': playbackUrl,
      'year': year,
      'timestamp': now,
    });

    if (_box.length > _maxItems) {
      _box.deleteAt(0);
    }
    RecentPlayedService().add(type: type, id: id, title: title, artwork: artwork, playbackUrl: playbackUrl, artist: artist, year: year);
  }

  List<Map<String, dynamic>> getAll() {
    final items = _box.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    items.sort(
          (a, b) => b['timestamp'].compareTo(a['timestamp']),
    );

    return items;
  }

  void clear() => _box.clear();
}
