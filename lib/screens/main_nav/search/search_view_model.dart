import 'dart:async';
import 'package:flutter/material.dart';

import '../../../data/api/music_api.dart';
import '../../../data/model/song.dart';

class SearchViewModel extends ChangeNotifier {
  final MusicApiService _apiService = MusicApiService();

  List<Map<String, dynamic>> searchResult = [];
  bool isLoading = false;
  Timer? _debounce;

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        searchSongs(query);
      } else {
        searchResult = [];
        notifyListeners();
      }
    });
  }

  Future<void> searchSongs(String query) async {
    isLoading = true;
    notifyListeners();

    try {
      searchResult = await _apiService.searchAll(query);
    } catch (e) {
      print(e.toString());
      searchResult = [];
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
