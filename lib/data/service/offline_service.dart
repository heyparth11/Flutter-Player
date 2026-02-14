
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/model/song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/music_api.dart';

class OfflineService {

  final _offlineBox = Hive.box('downloaded');

  Future<void> requestStoragePermissionAudio() async {
    if (Platform.isAndroid) {
      if (await Permission.audio.isGranted) return;

      final status = await Permission.audio.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
    }
  }

  Future<void> requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission denied');
    }
  }

  Future<String> downloadSong({
    required Song song,
    required DownloadProgress downloadProgress,
  }) async {
    await requestStoragePermissionAudio();

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${song.id}.mp3';

    final dio = Dio();

    if (song.url == '') {
      final res = await MusicApiService().getSongByID(song.id);
      song.setUrl(res.downloadUrl![4].link);
    }

    await dio.download(
      song.url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final percent = (received / total) * 100;
          downloadProgress.add(percent);
        }
        if (received == total) {
          downloadProgress.complete();
          _offlineBox.put(song.id, {
            'id': song.id,
            'title': song.title,
            'artist': song.artist,
            'artwork150': song.artwork150,
            'artwork500': song.artwork500,
            'filePath': filePath,
          });
        }
      },
    );

    return filePath;
  }
}


class DownloadProgress {
  final StreamController<double> _controller =
  StreamController<double>.broadcast();

  Stream<double> get stream => _controller.stream;

  void add(double value) => _controller.add(value);

  void complete() {
    _controller.add(100);
    _controller.close();
  }

  void dispose() {
    _controller.close();
  }
}