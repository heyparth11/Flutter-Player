import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/model/song.dart';
import '../../data/providers/recent_plays.dart';
import '../now_playing/now_playing_model.dart';
import 'options_bottom_sheet.dart';

class LibrarySongRow extends StatelessWidget {
  final Song song;
  final bool isAlbum;

  const LibrarySongRow({super.key, required this.song, this.isAlbum = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isAlbum ? null : () {
        final model = context.read<NowPlayingModel>();
        model.setSong(song);
        context.read<RecentPlaysProvider>().add(song);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 10.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: song == null
                      ? Image.asset("assets/cover.png", width: 60, height: 60)
                      : Image.network(song!.artwork150, width: 60, height: 60),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song == null ? "Blinding Lights" : song!.title,
                              style: TextStyle(color: Colors.white, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song == null
                                  ? "The Weeknd"
                                  : 'Song · ${song!.artist}',
                              style: TextStyle(
                                color: Color.fromRGBO(123, 123, 135, 1.0),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        padding: EdgeInsets.only(right: -5),
                        visualDensity: VisualDensity.compact,
                        iconSize: 27,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => OptionsBottomSheet(song: song!),
                          );
                        },
                        icon: Icon(Icons.more_vert, color: Colors.white,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: const Color.fromRGBO(71, 71, 80, 0.4), height: 0.4),
          ],
        ),
      ),
    );
  }
}
