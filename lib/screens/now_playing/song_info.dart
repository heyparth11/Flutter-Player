import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiosaavn/jiosaavn.dart';
import 'package:provider/provider.dart';

import '../../data/model/song.dart';
import '../../data/providers/favs_provider.dart';
import '../utils/marquee_text.dart';
import 'like_button.dart';

class SongInfoSection extends StatelessWidget {
  final Song song;

  const SongInfoSection({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoMarqueeText(
                text: song.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              AutoMarqueeText(
                text: song.artist,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Consumer<FavoritesProvider>(
          builder: (context, favProvider, _) {
            final isFav = favProvider.isFavorite(song.id);
            return LikeButton(
              isLiked: isFav,
              onTap: () {
                favProvider.toggleFavorite(
                  songId: song.id,
                  title: song.title,
                  artist: song.artist,
                  artwork: song.artwork150,
                  playbackUrl: song.url,
                );
              },
            );

            return GestureDetector(
              onTap: () {
                favProvider.toggleFavorite(
                  songId: song.id,
                  title: song.title,
                  artist: song.artist,
                  artwork: song.artwork150,
                  playbackUrl: song.url,
                );
              },
              // child: AnimatedIcon(
              //     icon: AnimatedIcon,
              //     progress: progress,
              // ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(189, 174, 174, 0.5),
                  borderRadius: BorderRadius.circular(40),
                ),
                width: 30,
                height: 30,
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                  size: 25,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 18),
        Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(189, 174, 174, 0.5),
            borderRadius: BorderRadius.circular(40),
          ),
          width: 28,
          height: 28,
          child: Icon(CupertinoIcons.ellipsis_vertical, color: Colors.white),
        ),
      ],
    );
  }
}
