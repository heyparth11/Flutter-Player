import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/providers/download_provider.dart';
import 'package:music_player/data/providers/home_state_provider.dart';
import 'package:music_player/data/providers/recent_plays.dart';
import 'package:music_player/data/service/auth_service.dart';
import 'package:music_player/screens/now_playing/now_playing_model.dart';
import 'package:provider/provider.dart';

import 'data/providers/favs_provider.dart';
import 'data/repos/favourites_repo.dart';
import 'data/service/audio_handler.dart';
import 'data/service/recent_searches_service.dart';
import 'firebase_options.dart';
import 'screens/main_nav/bottom_nav.dart';
import 'screens/main_nav/search/search_view_model.dart';

late final MusicAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AuthService().signInAnonymously();

  await Hive.initFlutter();
  await Hive.openBox('player_state');
  await Hive.openBox('recent_searches');
  await Hive.openBox('recent_plays');
  await Hive.openBox('downloaded');

  audioHandler = await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music.channel',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  audioHandler.restoreState();

  runApp(
    MultiProvider(
      providers: [
        Provider<RecentSearchService>(create: (_) => RecentSearchService()),
        ChangeNotifierProvider(create: (_) => HomeStateProvider()),
        ChangeNotifierProvider(create: (_) => OfflineProvider()),
        ChangeNotifierProvider(create: (_) => RecentPlaysProvider()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(lazy: false, create: (_) => NowPlayingModel()),
        ChangeNotifierProvider(
          create: (_) =>
              FavoritesProvider(FavoritesRepository())..startListening(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parth\'s Player',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const SplashScreen();
          }

          return const MainShell();
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: const CircularProgressIndicator()));
  }
}
