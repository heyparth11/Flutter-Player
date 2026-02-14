import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

import '../save_helpers.dart';

enum MyRepeatMode {
  off,
  one,
  all,
}

class MusicAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  final ConcatenatingAudioSource _playlist =
  ConcatenatingAudioSource(children: []);

  Stream<Duration> get positionStream => _player.positionStream;

  MyRepeatMode _repeatMode = MyRepeatMode.off;
  bool _shuffleEnabled = false;

  MyRepeatMode get repeatMode => _repeatMode;
  bool get shuffleEnabled => _shuffleEnabled;

  // bool _completionHandled = false;

  MusicAudioHandler() {
    _listenToPlayer();
  }


  void _listenToPlayer() {
    _player.playbackEventStream.listen((event) {
      final processingState = const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[event.processingState]!;

      playbackState.add(
        playbackState.value.copyWith(
          playing: _player.playing,
          processingState: processingState,
          updatePosition: event.updatePosition,
          bufferedPosition: event.bufferedPosition,
          queueIndex: event.currentIndex,
          controls: [
            MediaControl.skipToPrevious,
            _player.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
          ],
        ),
      );
    });
    _player.durationStream.listen((duration) {
      if (duration == null) return;

      final currentItem = mediaItem.value;
      if (currentItem == null) return;

      // Update mediaItem with duration
      mediaItem.add(
        currentItem.copyWith(duration: duration),
      );
    });
    // _player.currentIndexStream.listen((index) {
    //   if (index == null) return;
    //   if (index >= queue.value.length) return;
    //
    //   final currentItem = queue.value[index];
    //
    //   StreamSubscription? sub;
    //   sub = _player.durationStream.listen((duration) {
    //     if (duration == null) return;
    //
    //     mediaItem.add(
    //       currentItem.copyWith(duration: duration),
    //     );
    //
    //     sub?.cancel();
    //   });
    // });

    _player.currentIndexStream.listen((index) {
      if (index == null || index >= queue.value.length) return;
      mediaItem.add(queue.value[index]);
    });

    _player.playerStateStream
        .where((state) => state.processingState == ProcessingState.completed)
        .listen((_) {
        skipToNext();
      // _onCompleted();
    });

  }

  // Queue API
  Future<void> playQueue(List<MediaItem> items, {int startIndex = 0}) async {
    // _completionHandled = false;

    queue.add(items);

    final newPlaylist = ConcatenatingAudioSource(
      children: items.map(
            (e) => AudioSource.uri(Uri.parse(e.id)),
      ).toList(),
    );

    // 4️⃣ SET new audio source
    await _player.setAudioSource(
      newPlaylist,
      initialIndex: startIndex,
    );

    mediaItem.add(items[startIndex]);
    await _player.play();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final newQueue = [...queue.value, mediaItem];
    queue.add(newQueue);

    await _playlist.add(
      AudioSource.uri(Uri.parse(mediaItem.id)),
    );
  }

  @override
  Future<void> skipToNext() async {
    if (!_player.hasNext) return;
    await _player.seekToNext();
    mediaItem.add(queue.value[_player.currentIndex!]);
    await _player.play();
    await saveState();
  }

  @override
  Future<void> skipToPrevious() async {
    if (!_player.hasPrevious) return;
    await _player.seekToPrevious();
    mediaItem.add(queue.value[_player.currentIndex!]);
    await _player.play();
  }

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;

    await _player.setShuffleModeEnabled(_shuffleEnabled);
    if (_shuffleEnabled) {
      await _player.shuffle();
    }

    playbackState.add(
      playbackState.value.copyWith(
        shuffleMode: _shuffleEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  Future<void> toggleRepeat() async {
    switch (_repeatMode) {
      case MyRepeatMode.off:
        _repeatMode = MyRepeatMode.all;
        await _player.setLoopMode(LoopMode.all);
        break;
      case MyRepeatMode.all:
        _repeatMode = MyRepeatMode.one;
        await _player.setLoopMode(LoopMode.one);
        break;
      case MyRepeatMode.one:
        _repeatMode = MyRepeatMode.off;
        await _player.setLoopMode(LoopMode.off);
        break;
    }

    playbackState.add(
      playbackState.value.copyWith(
        repeatMode: {
          MyRepeatMode.off: AudioServiceRepeatMode.none,
          MyRepeatMode.all: AudioServiceRepeatMode.all,
          MyRepeatMode.one: AudioServiceRepeatMode.one,
        }[_repeatMode]!,
      ),
    );
  }



  // Future<void> _onCompleted() async {
  //   if (_completionHandled) return;
  //   _completionHandled = true;
  //
  //   await _player.pause();
  //   await _player.seek(Duration.zero);
  //
  //   playbackState.add(
  //     playbackState.value.copyWith(
  //       playing: false,
  //       processingState: AudioProcessingState.completed,
  //       updatePosition: Duration.zero,
  //     ),
  //   );
  // }


  // ---------- PUBLIC API ----------

  Future<void> playSingle(MediaItem item) async {
    // 🔥 CLEAR OLD QUEUE
    queue.add([item]);

    // await _playlist.clear();
    // await _playlist.add(
    //   AudioSource.uri(Uri.parse(item.id)),
    // );
    final source = AudioSource.uri(Uri.parse(item.id));
    await _player.setAudioSource(source);

    // final duration = await _player.setAudioSource(_playlist);
    mediaItem.add(item);
    // mediaItem.add(item.copyWith(duration: duration));

    await _player.play();
  }

  // Future<void> playSong(MediaItem item) async {
  //   // _completionHandled = false;
  //   mediaItem.add(item);
  //   final duration = await _player.setUrl(item.id);
  //   mediaItem.add(
  //     item.copyWith(duration: duration),
  //   );
  //
  //   await _player.setUrl(item.id);
  //   await _player.play();
  // }

  Future<void> saveState() async {
    final box = Hive.box('player_state');

    final queueItems = queue.value.map(mediaItemToMap).toList();

    await box.put('queue', queueItems);
    await box.put('index', _player.currentIndex ?? 0);
    await box.put('position', _player.position.inSeconds);
    await box.put('shuffle', _player.shuffleModeEnabled);
    await box.put('repeat', _player.loopMode.index);
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    await saveState();
  }

  Future<void> restoreState() async {
    final box = Hive.box('player_state');

    if (!box.containsKey('queue')) return;

    final savedQueue = (box.get('queue') as List)
        .map<MediaItem>((e) => mapToMediaItem(e as Map))
        .toList();


    final index = box.get('index', defaultValue: 0);
    final position = box.get('position', defaultValue: 0);
    final shuffle = box.get('shuffle', defaultValue: false);
    final repeat = box.get('repeat', defaultValue: 0);

    queue.add(savedQueue);

    final playlist = ConcatenatingAudioSource(
      children: savedQueue
          .map((e) => AudioSource.uri(Uri.parse(e.id)))
          .toList(),
    );

    await _player.setAudioSource(
      playlist,
      initialIndex: index,
      initialPosition: Duration(seconds: position),
    );

    await _player.setShuffleModeEnabled(shuffle);
    await _player.setLoopMode(LoopMode.values[repeat]);

    mediaItem.add(savedQueue[index]);
  }


  @override
  Future<void> play() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }
}
