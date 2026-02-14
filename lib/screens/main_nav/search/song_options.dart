import 'package:flutter/material.dart';

class SongOptionsSheet extends StatelessWidget {
  const SongOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _SheetHandle(),
            SizedBox(height: 12),
            _OptionTile(
              icon: Icons.download_rounded,
              title: "Download",
            ),
            _OptionTile(
              icon: Icons.playlist_add_rounded,
              title: "Add to playlist",
            ),
            _OptionTile(
              icon: Icons.favorite_border,
              title: "Add to favorites",
            ),
            _OptionTile(
              icon: Icons.share_rounded,
              title: "Share",
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _OptionTile({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
