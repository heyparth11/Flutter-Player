import 'package:flutter/material.dart';

class LibraryArtistItem extends StatelessWidget {
  final Map<String, dynamic> artist;

  const LibraryArtistItem({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 10.0),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  artist['image'][2]['link'],
                  width: 60,
                  height: 60,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist['title'],
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Artist",
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
              const SizedBox(width: 60,),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: const Color.fromRGBO(71, 71, 80, 0.4), height: 0.4),
        ],
      ),
    );
  }
}
