import 'package:dio/dio.dart';
import 'package:jiosaavn/jiosaavn.dart';
import 'package:music_player/data/model/album.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/song.dart';

class MusicApiService {
  static const _baseUrl = "https://saavn.sumit.co/api";

  final jiosaavn = JioSaavnClient();

  Future<List<Map<String, dynamic>>> searchAll(String query) async {

    // getSongByID('XTabrVow');

    final res = await jiosaavn.search.all(query);

    final topQuery = res.topQuery.results.map((e) {
      final json = e.toJson();
      json['image'] = (e.image as List)
          .map((i) => (i as DownloadLink).toJson())
          .toList();
      return json;
    }).toList();

    final songs = res.songs.results.map((e) {
      final json = e.toJson();
      json['image'] = (e.image as List)
          .map((i) => (i as DownloadLink).toJson())
          .toList();
      return json;
    }).toList();

    final artists = res.artists.results.map((e) {
      final json = e.toJson();
      json['image'] = (e.image as List)
          .map((i) => (i as DownloadLink).toJson())
          .toList();
      return json;
    }).toList();

    final albums = res.albums.results.map((e) {
      final json = e.toJson();
      json['image'] = (e.image as List)
          .map((i) => (i as DownloadLink).toJson())
          .toList();
      return json;
    }).toList();

    return [...topQuery, ...songs, ...artists, ...albums];

    // final url =
    // Uri.parse("$_baseUrl/search/songs?query=$query&page=0&limit=10");
    //
    // final response = await http.get(url);
    //
    // if (response.statusCode == 200) {
    //   final json = jsonDecode(response.body);
    //   final results = json['data']['results'] as List;
    //
    //   return results.map((e) => Song.fromJson(e)).toList();
    // } else {
    //   throw Exception("Failed to fetch songs");
    // }
  }

  // Future<List<Song>> getSongs(String id) async{
  //   final res = await jiosaavn.songs.;
  //   final resJson = res.toJson();
  //
  //   return [];
  // }

  Future<List<Song>> getAlbumSongs(String id) async {
    final res = await jiosaavn.albums.detailsById(id);
    final resJson = res.toJson();

    final songsJson = resJson['songs'].map<Song>((e) {
      final json = e.toJson();
      final image = json['image'].map((i) => i.toJson()).toList();
      final downloadUrls = json['download_links']
          .map((i) => i.toJson())
          .toList();

      return Song(
        id: json['id'],
        title: json['name'],
        artist: Song.formatArtistNames(json['primary_artists']),
        url: downloadUrls[4]['link'],
        artwork150: image[1]['link'],
        artwork500: image[2]['link'],
      );
    }).toList();

    return songsJson;
  }

  Future<Map<String, dynamic>> getArtistSongsAlbumsById(String id) async {

    final res = await jiosaavn.artists.artistSongs(
      "697691",
      page: 0,
      sort: "popularity",
    );
    final resJson = res.toJson();

    final songsJson = resJson['results'].map<Song>((e) {
      final json = e.toJson();
      final image = json['image'].map((i) => i.toJson()).toList();
      final downloadUrls = json['download_links']
          .map((i) => i.toJson())
          .toList();

      return Song(
        id: json['id'],
        title: json['name'],
        artist: Song.formatArtistNames(json['primary_artists']),
        url: downloadUrls[4]['link'],
        artwork150: image[1]['link'],
        artwork500: image[2]['link'],
      );
    }).toList();

    final albumRes = await jiosaavn.artists.artistAlbums(
      "697691",
      page: 0,
      sort: "popularity",
    );
    final albumResJson = albumRes.toJson();

    final albumJson = albumResJson['results'].map<MyAlbum>((e) {
      final json = e.toJson();
      final image = json['image'].map((i) => i.toJson()).toList();

      return MyAlbum(
        id: json['id'],
        title: json['name'],
        year: json['year'].toString(),
        artist: Song.formatArtistNames(json['primary_artists']),
        artwork150: image[1]['link'],
        artwork500: image[2]['link'],
      );
    }).toList();
    return {'topSongs': songsJson, 'topAlbums': albumJson};

    // if (response.statusCode == 200) {
    //   final json = jsonDecode(response.body);
    //   final results = json['data'];
    //
    //   final res = {
    //     'topSongs': results['topSongs']
    //         .map<Song>(
    //           (e) => Song(
    //             id: e['id'],
    //             title: e['name'],
    //             artist: Song.formatArtistNames(e['artists']['primary']),
    //             url: e['downloadUrl'][4]['url'],
    //             artwork150: e['image'][1]['url'],
    //             artwork500: e['image'][2]['url'],
    //           ),
    //         )
    //         .toList(),
    //     'topAlbums': results['topAlbums']
    //         .map<MyAlbum>(
    //           (e) => MyAlbum(
    //             id: e['id'],
    //             title: e['name'],
    //             year: e['year'].toString(),
    //             artist: Song.formatArtistNames(e['artists']['primary']),
    //             artwork150: e['image'][1]['url'],
    //             artwork500: e['image'][2]['url'],
    //           ),
    //         )
    //         .toList(),
    //   };
    //
    //   return res;
    // } else {
    //   throw Exception("Failed to fetch songs");
    // }
  }

  Future<SongResponse> getSongByID(String id) async {
    final res = await jiosaavn.songs.detailsById([id]);
    return res[0];
  }

}
