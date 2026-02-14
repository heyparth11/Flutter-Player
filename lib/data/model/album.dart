import 'song.dart';

class MyAlbum {
  final String id;
  final String title;
  final String artist;
  final String year;
  final String artwork150;
  final String artwork500;

  MyAlbum({
    required this.id,
    required this.title,
    required this.artist,
    required this.artwork150,
    required this.artwork500, required this.year,
  });

  factory MyAlbum.fromJson(Map<String, dynamic> json) {
    return MyAlbum(
      id: json['id'],
      year: json['year'].toString(),
      title: json['title'],
      artist: Song.formatArtistNames(json['artists']?['primary'] ?? 'NA'),
      artwork150: json['image']?[1]?['link'] ?? json['artwork'],
      artwork500: json['image']?[2]?['link'] ?? json['artwork'],
    );
  }

  static String formatArtistNames(dynamic primary) {
    late final List<String> names;
    if(primary.runtimeType == String) {
      names = primary.split(',');
    } else{
      names = primary.map((artist) => artist['name'] as String).toList();
    }

    if (names.isEmpty) return "";

    if (names.length == 1) {
      return names.first;
    }

    if (names.length == 2) {
      return "${names[0]} & ${names[1]}";
    }

    return "${names.sublist(0, names.length - 1).join(', ')} & ${names.last}";
  }
}
