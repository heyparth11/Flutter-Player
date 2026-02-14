import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import 'options_bottom_sheet.dart';

class AlbumSongRow extends StatelessWidget {
  final int index;
  final Song? song;

  const AlbumSongRow({super.key, required this.song, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 0, 10.0),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 5,),
              Text(
                index.toString(),
                style: TextStyle(color: Color(0x62FFFFFF), fontSize: 18, fontWeight: FontWeight.w300),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 14,),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        song == null ? "Blinding Lights" : song!.title,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 12),
          Divider(color: const Color.fromRGBO(71, 71, 80, 0.4), height: 0.4),
        ],
      ),
    );
  }
}
