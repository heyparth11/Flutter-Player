import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/api/music_api.dart';
import 'package:music_player/screens/main_nav/library_song_row.dart';
import 'package:provider/provider.dart';

import '../data/model/album.dart';
import '../data/model/song.dart';
import 'album_screen.dart';
import 'now_playing/now_playing_model.dart';

class ArtistScreen extends StatefulWidget {
  final Map<String, dynamic> artist;

  const ArtistScreen({super.key, required this.artist});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  late final Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    _data = MusicApiService().getArtistSongsAlbumsById(widget.artist['id']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.artist);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: const Color(0xFFFFFFFF),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: FutureBuilder(
        future: _data,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text(asyncSnapshot.error.toString(), style: TextStyle(color: Colors.white),));
          }
          final data = asyncSnapshot.data;
          final List<Song> topSongs = data!['topSongs'];
          final List<MyAlbum> topAlbums = data['topAlbums'];

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  Image.network(widget.artist['image'][2]['link']),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.artist["title"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      "Top Songs",
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: SizedBox(
                  height: 275,
                  child: PageView.builder(
                    padEnds: false,
                    controller: PageController(viewportFraction: 0.94),
                    itemCount: (topSongs.length / 3).ceil(),
                    itemBuilder: (context, pageIndex) {
                      final startIndex = pageIndex * 3;
                      final endIndex = (startIndex + 3).clamp(
                        0,
                        topSongs.length,
                      );

                      final pageSongs = topSongs.sublist(startIndex, endIndex);

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: List.generate(pageSongs.length, (i) {
                            final song = pageSongs[i];

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                final model = context.read<NowPlayingModel>();
                                model.setSong(song);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: i == pageSongs.length - 1 ? 0 : 8,
                                ),
                                child: LibrarySongRow(song: song),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      "Albums",
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
                child: SizedBox(
                  height: 240,
                  child: PageView.builder(
                    padEnds: false,
                    controller: PageController(viewportFraction: 0.48),
                    itemCount: topAlbums.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlbumScreen(
                                    album: topAlbums[index],
                                  ),
                                ),
                              );
                            },child: buildAlbum(topAlbums[index])),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Column buildAlbum(MyAlbum album) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(album.artwork500),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          album.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            // fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          album.artist,
          style: TextStyle(
            color: Color.fromRGBO(123, 123, 135, 1.0),
            fontSize: 15,
            // fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
