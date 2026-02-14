import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/screens/now_playing/now_playing_model.dart';
import 'package:provider/provider.dart';

import '../mini_player.dart';
import 'favourites.dart';
import 'home/home_screen.dart';
import './search/search_screen.dart';
import 'library_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _showBottomNav = true;

  void setBottomNavVisible(bool value) {
    setState(() => _showBottomNav = value);
  }

  Widget _buildNavigator(Widget root) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => root);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(10),
        child: AppBar(
          foregroundColor: const Color(0xFFFFFFFF),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: context
                .read<NowPlayingModel>()
                .currentSong != null ? 55.0 : 0),
            child: IndexedStack(index: _currentIndex,
                children: [
                  _buildNavigator(HomeScreen()),
                  _buildNavigator(LibraryScreen()),
                  _buildNavigator(FavouritesScreen()),
                  _buildNavigator(SearchScreen()),
                ]
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: !_showBottomNav
          ? null : _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(27, 26, 31, 1),
        border: BorderDirectional(
          top: BorderSide(color: Color.fromRGBO(71, 71, 80, 1.0), width: 0.6),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Color.fromRGBO(232, 68, 81, 1),
          unselectedItemColor: Color.fromRGBO(152, 153, 158, 1),
          showUnselectedLabels: true,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.music_albums_fill),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
          ],
        ),
      ),
    );
  }
}
