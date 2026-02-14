import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'album_art.dart';
import 'bottom_actions.dart';
import 'now_playing_model.dart';
import 'playback_controls.dart';
import 'progress_bar.dart';
import 'song_info.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingModel>(
      builder: (context, model, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(25),
              right: Radius.circular(25),
            ),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [model.darkColor, model.dominantColor],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AlbumArtCard(model: model),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SongInfoSection(song: model.currentSong!),
                      ),
                      const SizedBox(height: 12),
                      ProgressSection(model: model),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),
                      PlaybackControls(model: model),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.061,
                      ),
                      const BottomActions(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 0.5,
                  color: Color.fromRGBO(140, 82, 60, 0.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedTransform extends StatelessWidget {
  final double offsetY;
  final double dragOffset;
  final double screenHeight;
  final Widget child;

  const AnimatedTransform({
    super.key,
    required this.offsetY,
    required this.child,
    required this.dragOffset,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      transform: Matrix4.identity()
        ..translate(0.0, dragOffset)
        ..scale(1 - (dragOffset / screenHeight * 0.05)),
      child: child,
    );
  }
}
