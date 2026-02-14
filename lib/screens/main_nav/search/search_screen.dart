import 'package:flutter/material.dart';
import 'package:music_player/data/model/album.dart';
import 'package:music_player/data/service/recent_searches_service.dart';
import 'package:music_player/screens/album_screen.dart';
import 'package:music_player/screens/artist_screen.dart';
import 'package:music_player/screens/main_nav/library_album_item.dart';
import 'package:provider/provider.dart';

import '../../../data/model/song.dart';
import '../../now_playing/now_playing_model.dart';
import '../library_artist_item.dart';
import '../library_song_row.dart';
import 'search_view_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16.0),
            child: SearchField(focusNode: _searchFocusNode),
          ),
          if(context.read<RecentSearchService>().getAll().isNotEmpty && context.watch<SearchViewModel>().searchResult.isEmpty && !context.watch<SearchViewModel>().isLoading)...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 12, 10.0),
              child: Row(
                children: [
                  const Text(
                    "Recently Searched",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      context.read<RecentSearchService>().clear();
                      setState(() {
                      });
                    },
                    icon: Text(
                      "Clear All",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color.fromRGBO(71, 71, 80, 0.6), height: 0.5),
          ],
          const SizedBox(height: 18),
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.searchResult.isEmpty) {
                  final recentSearches = context
                      .read<RecentSearchService>()
                      .getAll();

                  if(recentSearches.isEmpty) {
                    return const Center(
                      child: Text(
                        "Search something",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: recentSearches.length,
                    itemBuilder: (context, index) {
                      final item = recentSearches[index];
                      if (item['type'] == 'song') {
                        final song = Song(
                          id: item['id'],
                          title: item['title'],
                          artist: item['artist'],
                          artwork150: item['artwork'],
                          artwork500: item['artwork'],
                          url: item['playbackUrl'],
                        );

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _searchFocusNode.unfocus();
                            context.read<RecentSearchService>().add(
                              type: 'song',
                              id: song.id,
                              title: song.title,
                              artist: song.artist,
                              artwork: song.artwork500,
                              year: '',
                              playbackUrl: song.url,
                            );
                          },
                          child: LibrarySongRow(song: song),
                        );
                      } else if (item['type'] == 'album') {
                        final album = MyAlbum(
                          id: item['id'],
                          title: item['title'],
                          year: item['year'],
                          artist: item['artist'],
                          artwork150: item['artwork'],
                          artwork500: item['artwork'],
                        );
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            context.read<RecentSearchService>().add(
                              type: 'album',
                              id: album.id,
                              title: album.title,
                              year: album.year,
                              artist: album.artist,
                              artwork: album.artwork500,
                              playbackUrl: '',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlbumScreen(album: album),
                              ),
                            );
                          },
                          child: LibraryAlbumItem(album: album),
                        );
                      }
                      return Text('a');
                    },
                  );
                }

                return ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: vm.searchResult.length,
                  itemBuilder: (context, index) {
                    final item = vm.searchResult[index];

                    if (item['type'] == 'song') {
                      final song = Song(
                        id: item['id'],
                        title: item['title'],
                        artist: Song.formatArtistNames(item['primary_artists']),
                        artwork150: item['image'][1]['link'],
                        artwork500: item['image'][2]['link'],
                        url: '',
                      );
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _searchFocusNode.unfocus();
                          final model = context.read<NowPlayingModel>();
                          model.setSong(song);

                          context.read<RecentSearchService>().add(
                            type: 'song',
                            id: song.id,
                            title: song.title,
                            artist: song.artist,
                            year: '',
                            artwork: song.artwork500,
                            playbackUrl: song.url,
                          );
                        },
                        child: LibrarySongRow(song: song),
                      );
                    } else if (item['type'] == 'artist') {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistScreen(artist: item),
                            ),
                          );
                        },
                        child: LibraryArtistItem(artist: item),
                      );
                    } else if (item['type'] == 'album') {
                      final album = MyAlbum.fromJson(item);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumScreen(album: album),
                            ),
                          );
                          context.read<RecentSearchService>().add(
                            type: 'album',
                            id: album.id,
                            title: album.title,
                            artist: album.artist,
                            year: album.year,
                            artwork: album.artwork500,
                            playbackUrl: '',
                          );
                        },
                        child: LibraryAlbumItem(album: album),
                      );
                    }

                    return Text('asdf');

                    // return GestureDetector(
                    //   behavior: HitTestBehavior.opaque,
                    //   onTap: () {
                    //
                    //     // _searchFocusNode.unfocus();
                    //     // final model = context.read<NowPlayingModel>();
                    //     // model.setSong(song);
                    //     // showModalBottomSheet(
                    //     //   context: context,
                    //     //   isScrollControlled: true,
                    //     //   backgroundColor: Colors.transparent,
                    //     //   builder: (_) => const NowPlayingScreen(),
                    //     // );
                    //
                    //   },
                    //   child: LibrarySongRow(song:song),
                    // );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final FocusNode focusNode;

  const SearchField({super.key, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SearchViewModel>();

    return SizedBox(
      height: 66,
      child: TextField(
        onChanged: vm.onSearchChanged,
        focusNode: focusNode,
        autofocus: false,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: "Artists, songs, or podcasts",
          hintStyle: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9C9393),
          ),
          filled: true,
          fillColor: Color.fromRGBO(27, 26, 31, 1),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: const Icon(Icons.search, color: Color(0xFF9C9393)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
