import 'package:audio_service/audio_service.dart';

Map<String, dynamic> mediaItemToMap(MediaItem item) {
  return {
    'id': item.id,
    'title': item.title,
    'artist': item.artist,
    'artUri': item.artUri?.toString(),
    'duration': item.duration?.inSeconds,
    'extras': item.extras,
  };
}

MediaItem mapToMediaItem(Map map) {
  return MediaItem(
    id: map['id'],
    title: map['title'],
    artist: map['artist'],
    artUri: map['artUri'] != null ? Uri.parse(map['artUri']) : null,
    extras: map['extras'] != null
        ? Map<String, dynamic>.from(map['extras'] as Map)
        : null,
    duration: map['duration'] != null
        ? Duration(seconds: map['duration'])
        : null,
  );
}
