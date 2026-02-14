import 'package:flutter/material.dart';
import 'package:music_player/screens/now_playing/now_playing.dart';
import 'package:provider/provider.dart';

import 'now_playing/now_playing_model.dart';
import 'utils/marquee_text.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingModel>(
      builder: (context, model, _) {
        final song = model.currentSong;

        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const NowPlayingScreen(),
            );
          },
          child: Container(
            height: 64,
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 2),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(27, 26, 31, 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Artwork(song.artwork150),
                const SizedBox(width: 14),
                Expanded(
                  flex: 7,
                  child: AutoMarqueeText(
                    text: song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                _PlayPauseButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Artwork extends StatelessWidget {
  final String url;
  const _Artwork(this.url);

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingModel>(
      builder: (context, model, _) {
        return AnimatedScale(
          scale: model.isPlaying ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              url,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

// class _SongInfo extends StatelessWidget {
//   final Song song;
//   const _SongInfo(this.song);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           song.title,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           song.artist,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
// }

class _PlayPauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingModel>(
      builder: (context, model, _) {
        return IconButton(
          icon: Icon(
            model.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: model.togglePlay,
        );
      },
    );
  }
}
