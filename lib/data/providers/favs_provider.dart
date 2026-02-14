import 'dart:async';
import 'package:flutter/material.dart';
import '../repos/favourites_repo.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesRepository _repo;

  FavoritesProvider(this._repo);

  final Map<String, Map<String, dynamic>> _favorites = {};

  StreamSubscription? _subscription;

  Map<String, Map<String, dynamic>> get favorites => _favorites;
  List<Map<String, dynamic>> get favoriteList => _favorites.values.toList();


  bool isFavorite(String songId) {
    return _favorites.containsKey(songId);
  }

  void startListening() {
    _subscription?.cancel();

    _subscription = _repo.favoritesStream().listen((data) {
      _favorites
        ..clear()
        ..addAll(data);
      notifyListeners();
    });
  }

  Future<void> toggleFavorite({
    required String songId,
    required String title,
    required String artist,
    required String artwork,
    required String playbackUrl
  }) async {
    if (isFavorite(songId)) {
      await _repo.removeFavorite(songId);
    } else {
      await _repo.addFavorite(
        songId: songId,
        title: title,
        artist: artist,
        artwork: artwork,
        playbackUrl: playbackUrl,
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
