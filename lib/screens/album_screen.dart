import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/api/music_api.dart';
import 'package:provider/provider.dart';

import '../data/model/album.dart';
import '../data/model/song.dart';
import '../data/providers/recent_plays.dart';
import 'main_nav/album_song_row.dart';
import 'now_playing/now_playing_model.dart';

class AlbumScreen extends StatefulWidget {
  final MyAlbum album;

  const AlbumScreen({super.key, required this.album});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late final Future<List<Song>> _data;

  @override
  void initState() {
    _data = MusicApiService().getAlbumSongs(widget.album.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _data,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return Center(
              child: Text(
                asyncSnapshot.error.toString(),
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final data = asyncSnapshot.data ?? [];
          final List<Song> songs = data;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating:true,
                pinned: true,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                expandedHeight: 55,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Text(widget.album.title),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(color: Colors.transparent),
                ),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.album.artwork500,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => CachedNetworkImage(
                          imageUrl: widget.album.artwork150,
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.library_music,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 32,
                            left: 16,
                            right: 16,
                          ),
                          child: Column(
                            children: [
                              Text(
                                widget.album.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                spacing: 15,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        final model = context
                                            .read<NowPlayingModel>();
                                        model.playAlbum(songs);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                      ),
                                      icon: Icon(
                                        CupertinoIcons.play_fill,
                                        size: 22,
                                      ),
                                      label: Text(
                                        'Play',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed: () {},
                                      icon: Icon(
                                        CupertinoIcons.shuffle_medium,
                                        size: 22,
                                      ),
                                      label: Text(
                                        'Shuffle',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 10),
                    child: Column(
                      children: List.generate(songs.length, (i) {
                        final song = songs[i];

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            final model = context.read<NowPlayingModel>();
                            model.setSong(song);
                            context.read<RecentPlaysProvider>().add(song);
                          },
                          child: AlbumSongRow(song: song, index: i + 1),
                        );
                      }),
                    ),
                  ),
                ]),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 20,),
              )
            ],
          );
        },
      ),
    );
  }
}
