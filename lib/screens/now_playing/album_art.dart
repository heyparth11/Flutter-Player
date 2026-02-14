import 'package:flutter/material.dart';
import 'package:music_player/screens/now_playing/now_playing_model.dart';


class AlbumArtCard extends StatelessWidget {
  final NowPlayingModel model;
  const AlbumArtCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: model.isPlaying ? 1.0 : 0.86,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.hardEdge,
        child: Image.network(
          model.currentSong!.artwork500,
          height: MediaQuery.of(context).size.height * 0.407,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
