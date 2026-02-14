import 'package:flutter/material.dart';
import 'package:music_player/data/providers/download_provider.dart';
import 'package:music_player/screens/main_nav/library_song_row.dart';
import 'package:provider/provider.dart';

import '../../data/model/song.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<OfflineProvider>(
      builder: (context, offlineProvider, _) {
        if(offlineProvider.isLoading) return const Center(child: CircularProgressIndicator.adaptive());

        final offlineSongs = offlineProvider.offlineSongs;

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
                  "Downloaded",
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
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert, size: 29),
                ),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            if (offlineSongs.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text(
                      'No downloaded songs',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            if (offlineSongs.isNotEmpty)
              SliverList.builder(
                itemCount: offlineSongs.length,
                itemBuilder: (context, index) {
                  final item = offlineSongs[index];
                  return LibrarySongRow(
                    song: Song(
                      id: item['id'],
                      title: item['title'],
                      artist: item['artist'],
                      artwork150: item['artwork150'],
                      artwork500: item['artwork500'],
                      url: '',
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
