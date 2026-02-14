class Song {
  final String id;
  final String title;
  final String artist;
  final String artwork150;
  final String artwork500;
  String url;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.artwork150,
    required this.artwork500,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['name'] ?? json['title'],
      artist: json['artists']?['primary'] ?? json['primary_artists'] ?? json['artist'],
      artwork150: json['image']?[1]?['url'] ?? json['artwork'],
      artwork500: json['image']?[2]?['url'] ?? json['artwork'],
      url: json['downloadUrl']?[3]?['url'] ?? json['playbackUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artwork150': artwork150,
      'artwork500': artwork500,
      'url': url,
    };
  }

  void setUrl(String url){
    this.url = url;
  }

  static String formatArtistNames(dynamic primary) {
    late final List<String> names;
    if(primary.runtimeType == String) {
      names = primary.split(',');
    } else {
      names = primary.map<String>((artist) => artist['name'] as String).toList();
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
