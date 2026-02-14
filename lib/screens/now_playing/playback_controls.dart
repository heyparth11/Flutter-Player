import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_player/screens/now_playing/now_playing_model.dart';
import 'package:provider/provider.dart';

class PlaybackControls extends StatefulWidget {
  final NowPlayingModel model;

  const PlaybackControls({super.key, required this.model});

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final model = context.watch<NowPlayingModel>();

    if (model.processingState == AudioProcessingState.completed ||
        model.processingState == AudioProcessingState.idle) {
      _controller.reverse();
      return;
    }

    if (model.isPlaying) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.74,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 65,
            highlightColor: Colors.black38,
            padding: EdgeInsets.all(12),
            onPressed: () {
              widget.model.playPrevious();
            },
            icon: Image.asset(
              "assets/playback-prev.png",
              width: 45,
              height: 45,
            ),
          ),
          const Spacer(),
          IconButton(
            iconSize: 65,
            highlightColor: Colors.black38,
            icon: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              color: Colors.white,
              progress: _controller,
            ),
            onPressed: () {
              context.read<NowPlayingModel>().togglePlay();
            },
          ),
          const Spacer(),
          IconButton(
            iconSize: 65,
            padding: EdgeInsets.all(12),
            highlightColor: Colors.black38,
            onPressed: () {
              widget.model.playNext();
            },
            icon: Image.asset(
              "assets/playback-next.png",
              width: 45,
              height: 45,
            ),
          ),
        ],
      ),
    );
  }
}
