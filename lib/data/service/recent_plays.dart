
import 'package:hive_flutter/hive_flutter.dart';

enum RecentType {
  song,
  album,
}

class RecentPlayedService {
  static const _boxName = 'recent_plays';
  static const _maxItems = 15;

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

    _box.put(id, {
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
  void delete(String id) => _box.delete(id);

  void clear() => _box.clear();
}
