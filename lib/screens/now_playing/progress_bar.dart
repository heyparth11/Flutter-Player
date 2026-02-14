import 'package:flutter/material.dart';
import 'package:music_player/screens/now_playing/now_playing_model.dart';
import 'package:provider/provider.dart';

class ProgressSection extends StatelessWidget {
  final NowPlayingModel model;

  const ProgressSection({super.key, required this.model});

  String _formatTime(double seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return "$min:${sec.toInt().toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: model.progress.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, animatedValue, _) {
            return AnimatedScale(
              scale: model.isSeeking ? 1.01 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: SizedBox(
                height: 20,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    trackHeight: 5.1,
                  ),
                  child: Slider(
                    value: animatedValue,
                    onChangeStart: (_) {
                      context.read<NowPlayingModel>().startSeeking();
                    },
                    onChanged: (value) {
                      context.read<NowPlayingModel>().seek(value);
                    },
                    onChangeEnd: (_) {
                      context.read<NowPlayingModel>().stopSeeking();
                    },
                    activeColor: const Color.fromRGBO(182, 165, 155, 1.0),
                    inactiveColor: Colors.white24,
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(model.currentPosition),
                style: TextStyle(
                    color: Colors.white30,
                  fontSize: 13
                ),
              ),
              Text(
                "-${_formatTime(model.totalDuration - model.currentPosition)}",
                style: TextStyle(
                    color: Colors.white30,
                    fontSize: 13
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
