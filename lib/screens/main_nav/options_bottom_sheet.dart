import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/data/service/offline_service.dart';
import 'package:provider/provider.dart';

import '../../data/model/song.dart';
import '../../data/providers/download_provider.dart';

class OptionsBottomSheet extends StatefulWidget {
  final Song song;

  const OptionsBottomSheet({super.key, required this.song});

  @override
  State<OptionsBottomSheet> createState() => _OptionsBottomSheetState();
}

class _OptionsBottomSheetState extends State<OptionsBottomSheet> {
  final DownloadProgress progress = DownloadProgress();

  @override
  Widget build(BuildContext context) {
    final offlineProvider = context.watch<OfflineProvider>().offlineSongs;

    final isOffline = offlineProvider.any(
      (element) => element['id'] == widget.song.id,
    );

    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(27, 26, 31, 1)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOffline)
            _bottomSheetItem(
              context,
              icon: CupertinoIcons.check_mark_circled_solid,
              title: "Downloaded",
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            )
          else
            StreamBuilder<double>(
              stream: progress.stream,
              initialData: 0,
              builder: (context, snapshot) {
                final value = snapshot.data ?? 0;

                if (value >= 100) {
                  return _bottomSheetItem(
                    context,
                    icon: CupertinoIcons.check_mark_circled_solid,
                    title: "Downloaded",
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context);
                    },
                  );
                } else if (value > 0) {
                  return _downloadItem(
                    context,
                    circularIndicator: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          value: value / 100,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                    title: "Downloading",
                  );
                }

                return _bottomSheetItem(
                  context,
                  icon: CupertinoIcons.arrow_down_circle,
                  title: "Download",
                  onTap: () async {
                    context.read<OfflineProvider>().addOfflineSong(widget.song, progress);
                  },
                );
              },
            ),

          _bottomSheetItem(
            context,
            icon: Icons.favorite_border,
            title: "Remove from favorites",
            onTap: () {
              Navigator.pop(context);
              // TODO: remove from favorites
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(27, 26, 31, 1),
          title: Text('Delete Song', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete this song?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                context.read<OfflineProvider>().removeOfflineSong(widget.song.id);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _downloadItem(
    BuildContext context, {
    required String title,
    required Widget circularIndicator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          circularIndicator,
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _bottomSheetItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.redAccent, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
