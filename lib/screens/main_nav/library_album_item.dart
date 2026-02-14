import 'package:flutter/material.dart';

import '../../data/model/album.dart';

class LibraryAlbumItem extends StatelessWidget {
  final MyAlbum album;

  const LibraryAlbumItem({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 10.0),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(album.artwork150, width: 60, height: 60),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  album.title,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 60),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: const Color.fromRGBO(71, 71, 80, 0.4), height: 0.4),
        ],
      ),
    );
  }
}
