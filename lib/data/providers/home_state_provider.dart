import 'package:flutter/foundation.dart';

class HomeStateProvider extends ChangeNotifier {
  bool isLastPlayedEmpty = true;
  bool isLikedEmpty = true;
  bool isDownloadedEmpty = true;

  bool get isHomeEmpty =>
      isLastPlayedEmpty &&
          isLikedEmpty &&
          isDownloadedEmpty;

  void updateLastPlayed(bool isEmpty) {
    isLastPlayedEmpty = isEmpty;
    notifyListeners();
  }

  void updateLiked(bool isEmpty) {
    isLikedEmpty = isEmpty;
    notifyListeners();
  }

  void updateDownloaded(bool isEmpty) {
    isDownloadedEmpty = isEmpty;
    notifyListeners();
  }
}
