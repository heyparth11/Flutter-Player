// import 'dart:async';
// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:palette_generator/palette_generator.dart';
// import '../../data/model/song.dart';
// import '../../data/service/audio_player.dart';
// import '../../main.dart';
//
// class NowPlayingModel extends ChangeNotifier {
//   final AudioPlayerService _audioService = AudioPlayerService();
//
//   StreamSubscription? _positionSub;
//   StreamSubscription? _durationSub;
//   StreamSubscription? _playerStateSub;
//
//   bool _isPlaying = false;
//   bool _isShuffle = false;
//   bool _isRepeat = false;
//   bool _isSeeking = false;
//
//   double _currentPosition = 0.0; // seconds
//   double _totalDuration = 0.0;   // seconds
//
//   Song? _currentSong;
//
//   Color _dominantColor = const Color(0xFF6B2E12);
//   Color _darkColor = const Color(0xFF000000);
//
//   // ---------------- GETTERS ----------------
//
//   Song? get currentSong => _currentSong;
//   bool get isPlaying => _isPlaying;
//   bool get isShuffle => _isShuffle;
//   bool get isRepeat => _isRepeat;
//   bool get isSeeking => _isSeeking;
//   Color get dominantColor => _dominantColor;
//   Color get darkColor => _darkColor;
//
//   double get currentPosition => _currentPosition;
//   double get totalDuration => _totalDuration;
//
//   double get progress =>
//       _totalDuration == 0 ? 0 : _currentPosition / _totalDuration;
//
//   // ---------------- INIT STREAMS ----------------
//
//   void _listenToPlayer() {
//     _positionSub?.cancel();
//     _durationSub?.cancel();
//     _playerStateSub?.cancel();
//
//     final player = _audioService.player;
//
//     _positionSub = player.positionStream.listen((position) {
//       if (_isSeeking) return;
//       _currentPosition = position.inSeconds.toDouble();
//       notifyListeners();
//     });
//
//     _durationSub = player.durationStream.listen((duration) {
//       if (duration == null) return;
//       _totalDuration = duration.inSeconds.toDouble();
//       notifyListeners();
//     });
//
//     _playerStateSub = player.playerStateStream.listen((state) async {
//       if (state.processingState == ProcessingState.completed) {
//         _isPlaying = false;
//         _currentPosition = 0.0;
//
//         // reset player so play works again
//         await player.seek(Duration.zero);
//         await player.pause();
//
//         notifyListeners();
//       } else {
//         _isPlaying = state.playing;
//         notifyListeners();
//       }
//     });
//   }
//
//   // ---------------- ACTIONS ----------------
//
//   Future<void> setSong(Song song) async {
//     _currentSong = song;
//     notifyListeners();
//
//     await extractColorsFromArtwork(song.artwork);
//     await _audioService.playUrl(song.url);
//     final mediaItem = MediaItem(
//       id: song.url,
//       title: song.title,
//       artist: song.artist,
//       artUri: Uri.parse(song.artwork),
//     );
//     await audioHandler.playSong(mediaItem);
//
//     _listenToPlayer();
//   }
//
//   Future<void> togglePlay() async {
//     if (_isPlaying) {
//       await _audioService.pause();
//     } else if (_currentSong != null) {
//       await _audioService.player.play();
//     }
//   }
//
//   void toggleShuffle() {
//     _isShuffle = !_isShuffle;
//     notifyListeners();
//   }
//
//   void toggleRepeat() {
//     _isRepeat = !_isRepeat;
//     notifyListeners();
//   }
//
//   Future<void> extractColorsFromArtwork(String imageUrl) async {
//     final palette = await PaletteGenerator.fromImageProvider(
//       NetworkImage(imageUrl),
//       size: const Size(200, 200),
//     );
//
//     _dominantColor =
//         palette.dominantColor?.color ?? const Color(0xFF121212);
//
//     _darkColor = const Color(0xFF272424);
//
//     notifyListeners();
//   }
//
//
//   // ---------------- SEEKING ----------------
//
//   void startSeeking() {
//     _isSeeking = true;
//   }
//
//   void seek(double value) {
//     _currentPosition = value * _totalDuration;
//     notifyListeners();
//   }
//
//   Future<void> stopSeeking() async {
//     _isSeeking = false;
//     await _audioService.seek(
//       Duration(seconds: _currentPosition.toInt()),
//     );
//   }
//
//   // ---------------- CLEANUP ----------------
//
//   @override
//   void dispose() {
//     _positionSub?.cancel();
//     _durationSub?.cancel();
//     _playerStateSub?.cancel();
//     _audioService.dispose();
//     super.dispose();
//   }
// }

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:palette_generator/palette_generator.dart';

import '../../data/api/music_api.dart';
import '../../data/model/song.dart';
import '../../data/service/audio_handler.dart';
import '../../main.dart';

class NowPlayingModel extends ChangeNotifier {
  Song? _currentSong;

  bool _isPlaying = false;
  bool _isSeeking = false;

  double _currentPosition = 0.0;
  double _totalDuration = 0.0;

  Color _dominantColor = const Color(0xFF6B2E12);
  Color _darkColor = const Color(0xFF121212);

  StreamSubscription? _playbackSub;
  StreamSubscription? _mediaItemSub;

  AudioProcessingState _processingState = AudioProcessingState.idle;

  // ---------- GETTERS ----------

  bool get isShuffle => audioHandler.shuffleEnabled;

  MyRepeatMode get repeatMode => audioHandler.repeatMode;

  AudioProcessingState get processingState => _processingState;

  Song? get currentSong => _currentSong;

  bool get isPlaying => _isPlaying;

  bool get isSeeking => _isSeeking;

  double get currentPosition => _currentPosition;

  double get totalDuration => _totalDuration;

  double get currentSeconds => _currentPosition;

  double get totalSeconds => _totalDuration;

  double get progress =>
      _totalDuration == 0 ? 0 : _currentPosition / _totalDuration;

  Color get dominantColor => _dominantColor;

  Color get darkColor => _darkColor;

  // ---------- INIT ----------

  NowPlayingModel() {
    _listenToAudioHandler();
  }

  void _listenToAudioHandler() {
    audioHandler.mediaItem.listen((item) {
      if (item == null) return;

      _currentSong = Song(
        id: item.extras!['id'],
        title: item.title,
        artist: item.artist ?? '',
        artwork150: item.artUri.toString(),
        artwork500: item.artUri.toString(),
        url: item.id,
      );

      notifyListeners();
    });

    audioHandler.positionStream.listen((position) {
      if (_isSeeking) return;
      _currentPosition = position.inSeconds.toDouble();
      notifyListeners();
    });

    // play / pause
    audioHandler.playbackState.listen((state) {
      _isPlaying = state.playing;
      _processingState = state.processingState;
      if (state.processingState == AudioProcessingState.completed ||
          state.processingState == AudioProcessingState.idle) {
        seek(0);
        _currentPosition = 0;
      }
      notifyListeners();
    });

    // duration
    audioHandler.mediaItem.listen((item) {
      if (item?.duration == null) return;
      _totalDuration = item!.duration!.inSeconds.toDouble();
      notifyListeners();
    });
  }

  // ---------- ACTIONS ----------

  Future<void> setSong(Song song) async {
    notifyListeners();
    if (song.url == '') {
      final res = await MusicApiService().getSongByID(song.id);
      song.setUrl(res.downloadUrl![4].link);
    }

    await _extractColors(song.artwork150);

    final mediaItem = MediaItem(
      id: song.url,
      title: song.title,
      artist: song.artist,
      artUri: Uri.parse(song.artwork500),
      extras: {'id': song.id},
    );

    await audioHandler.playSingle(mediaItem);
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await audioHandler.pause();
    } else {
      await audioHandler.play();
    }
  }

  // Queue
  Future<void> playAlbum(List<Song> songs, {int startIndex = 0}) async {
    final mediaItems = songs.map(_toMediaItem).toList();
    await audioHandler.playQueue(mediaItems, startIndex: startIndex);
  }

  Future<void> addToQueue(Song song) async {
    await audioHandler.addQueueItem(_toMediaItem(song));
  }

  Future<void> playNext() async {
    await audioHandler.skipToNext();
  }

  Future<void> playPrevious() async {
    await audioHandler.skipToPrevious();
  }

  Future<void> toggleShuffle() async {
    await audioHandler.toggleShuffle();
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    await audioHandler.toggleRepeat();
    notifyListeners();
  }

  MediaItem _toMediaItem(Song song) {
    return MediaItem(
      id: song.url,
      title: song.title,
      artist: song.artist,
      artUri: Uri.parse(song.artwork500),
      extras: {'id': song.id},
    );
  }

  // ---------- SEEKING ----------

  void startSeeking() {
    _isSeeking = true;
  }

  void seek(double value) {
    _currentPosition = value * _totalDuration;
    notifyListeners();
  }

  Future<void> stopSeeking() async {
    _isSeeking = false;
    await audioHandler.seek(Duration(seconds: _currentPosition.toInt()));
  }

  // ---------- COLORS ----------

  Future<void> _extractColors(String imageUrl) async {
    final palette = await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
      size: const Size(200, 200),
    );

    _dominantColor = palette.dominantColor?.color ?? const Color(0xFF6B2E12);
    _darkColor = palette.darkMutedColor?.color ?? const Color(0xFF121212);

    notifyListeners();
  }

  // ---------- CLEANUP ----------

  @override
  void dispose() {
    _playbackSub?.cancel();
    _mediaItemSub?.cancel();
    super.dispose();
  }
}
