import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_player/screens/now_playing/now_playing_model.dart';
import 'package:provider/provider.dart';

import '../../data/model/song.dart';
import '../../data/service/audio_handler.dart';
import '../../main.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NowPlayingModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder<List<MediaItem>>(
          stream: audioHandler.queue,
          builder: (context, snapshot) {
            final queue = snapshot.data ?? [];

            if (queue.isEmpty) {
              return const Center(
                child: Text(
                  'Queue is empty',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                StreamBuilder<MediaItem?>(
                  stream: audioHandler.mediaItem,
                  builder: (context, mediaSnapshot) {
                    final item = mediaSnapshot.data;
                    if (item == null) return const SizedBox();

                    final song = Song(
                      id: item.id,
                      title: item.title,
                      artist: item.artist ?? '',
                      artwork150: item.artUri?.toString() ?? '',
                      artwork500: item.artUri?.toString() ?? '',
                      url: item.id,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: QueueCurrentSong(
                        song: song,
                        isPlaying: model.isPlaying,
                        onPlayPause: model.togglePlay,
                        onNext: model.playNext,
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        "Playing Next",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),

                      ToggleIconButton(
                        icon: Icons.shuffle,
                        isActive: model.isShuffle,
                        onTap: model.toggleShuffle,
                      ),

                      const SizedBox(width: 24),

                      ToggleIconButton(
                        icon: Icons.repeat,
                        isActive: model.repeatMode != RepeatMode.off,
                        onTap: model.toggleRepeat,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder<int?>(
                    stream: audioHandler.playbackState
                        .map((state) => state.queueIndex)
                        .distinct(),
                    builder: (context, indexSnapshot) {
                      final currentIndex = indexSnapshot.data ?? 0;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                          final item = queue[index];

                          final song = Song(
                            id: item.id,
                            title: item.title,
                            artist: item.artist ?? '',
                            artwork150: item.artUri?.toString() ?? '',
                            artwork500: item.artUri?.toString() ?? '',
                            url: item.id,
                          );

                          final isCurrent = index == currentIndex;

                          return LibrarySongRow(
                            song: song,
                            isCurrent: isCurrent,
                            onTap: () {
                              audioHandler.skipToQueueItem(index);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}

class QueueCurrentSong extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const QueueCurrentSong({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              song.artwork500,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: onPlayPause,
          ),

          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class ToggleIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const ToggleIconButton({
    super.key,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: isActive ? Colors.redAccent : Colors.white,
      ),
    );
  }
}

class LibrarySongRow extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final VoidCallback onTap;

  const LibrarySongRow({
    super.key,
    required this.song,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Image.network(song.artwork500, width: 48),
      title: Text(
        song.title,
        style: TextStyle(
          color: isCurrent ? Colors.redAccent : Colors.white,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: const TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isCurrent
          ? const Icon(Icons.play_arrow, color: Colors.redAccent)
          : SizedBox(width: 30,),
    );
  }
}
