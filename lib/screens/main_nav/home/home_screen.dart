import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/song.dart';
import '../../../data/providers/download_provider.dart';
import '../../../data/providers/favs_provider.dart';
import '../../../data/providers/recent_plays.dart';
import '../../now_playing/now_playing_model.dart';
import 'empty_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final lastPlayedEmpty =
        context.watch<RecentPlaysProvider>().songs.isEmpty;

    final favoritesEmpty =
        context.watch<FavoritesProvider>().favoriteList.isEmpty;

    final downloadedEmpty =
        context.watch<OfflineProvider>().offlineSongs.isEmpty;

    final isHomeEmpty =
        lastPlayedEmpty && favoritesEmpty && downloadedEmpty;

    if (isHomeEmpty) {
      return const HomeEmptyState();
    }
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          backgroundColor: Colors.black,
          foregroundColor: Color(0xFFFFFFFF),
          expandedHeight: 135,
          pinned: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(
              color: const Color.fromRGBO(71, 71, 80, 0.6),
              height: 0.5,
              width: double.infinity,
            ),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              "Home",
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
        SliverList(
          delegate: SliverChildListDelegate([
            Consumer<RecentPlaysProvider>(
              builder: (context, pro, _) {
                final songs = pro.songs;

                if(songs.isEmpty) {
                  return SizedBox.shrink();
                }
                return buildCategoryRow(label: "Recently Played", items: songs);
              },
            ),
            Consumer<OfflineProvider>(
              builder: (context, offlineProvider, _) {
                final offlineSongs = offlineProvider.offlineSongs;

                if(offlineSongs.isEmpty){
                  return SizedBox.shrink();
                }

                return buildCategoryRow(
                  label: "Recently Downloaded",
                  items: offlineSongs,
                );
              },
            ),
            Consumer<FavoritesProvider>(
              builder: (context, favProvider, _) {
                final favs = favProvider.favoriteList;

                if(favs.isEmpty) {
                  return SizedBox.shrink();
                }
                return buildCategoryRow(label: "Recently Liked", items: favs);
              },
            ),
          ]),
        ),
      ],
    );
  }

  Column buildCategoryRow({
    required String label,
    required List<Map<String, dynamic>> items,
  }) {
    final List<Song> songs = items.map((item) {
      return Song(
        id: item['id'],
        title: item['title'],
        artist: item['artist'],
        artwork150: item['artwork'] ?? item['artwork500'],
        artwork500: item['artwork'] ?? item['artwork500'],
        url: item['playbackUrl'] ?? '',
      );
    }).toList();


    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(CupertinoIcons.chevron_right, color: Colors.white),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
          child: SizedBox(
            height: 240,
            child: PageView.builder(
              padEnds: false,
              controller: PageController(viewportFraction: 0.48),
              itemCount: songs.length > 5 ? 5 : songs.length,
              itemBuilder: (context, index) {

                return Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final model = context.read<NowPlayingModel>();
                      model.playAlbum(songs, startIndex: index);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              songs[index].artwork500,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error,
                                  color: Color(0xFF4F4F4F),
                                  size: 30,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          songs[index].title,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          songs[index].artist,
                          style: TextStyle(
                            color: Color.fromRGBO(123, 123, 135, 1.0),
                            fontSize: 15,
                            // fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
