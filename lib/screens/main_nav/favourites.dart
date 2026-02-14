import 'package:flutter/material.dart';
import 'package:music_player/data/providers/recent_plays.dart';
import 'package:provider/provider.dart';

import '../../data/model/song.dart';
import '../../data/providers/favs_provider.dart';
import '../now_playing/now_playing.dart';
import '../now_playing/now_playing_model.dart';
import 'library_song_row.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          backgroundColor: Colors.black,
          foregroundColor: Color(0xFFFFFFFF),
          expandedHeight: 135,
          pinned: true,
          scrolledUnderElevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(
              color: const Color.fromRGBO(71, 71, 80, 0.6),
              height: 0.5,
              width: double.infinity,
            ),
          ),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              "Favourites",
              style: TextStyle(
                fontSize: 27,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            expandedTitleScale: 1.19,
            titlePadding: const EdgeInsets.only(left: 16, bottom: 20),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, size: 29)),
          ],
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        Consumer<FavoritesProvider>(
          builder: (context, favProvider, _) {
            final favs = favProvider.favoriteList;
            final List<Song> favSongs = favs.map((fav){
              return Song(
                id: fav['id'],
                title: fav['title'],
                artist: fav['artist'],
                artwork150: fav['artwork'],
                artwork500: fav['artwork'],
                url: fav['playbackUrl'],
              );
            }).toList();

            return SliverList.builder(
              itemCount: favSongs.length,
              itemBuilder: (context, index) {

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final model = context.read<NowPlayingModel>();
                    model.playAlbum(favSongs, startIndex: index);
                  },
                  child: LibrarySongRow(song: favSongs[index], isAlbum: true));
              },
            );
          },
        ),
      ],
    );
  }
}
