import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _favoritesRef =>
      _firestore.collection('users').doc(_uid).collection('favorites');

  Future<void> addFavorite({
    required String songId,
    required String title,
    required String artist,
    required String artwork,
    required String playbackUrl
  }) async {
    await _favoritesRef.doc(songId).set({
      'id': songId,
      'title': title,
      'artist': artist,
      'artwork': artwork,
      'playbackUrl': playbackUrl,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getFavoriteById(String songId) async {
    final doc = await _favoritesRef.doc(songId).get();

    if (!doc.exists) return null;
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> removeFavorite(String songId) async {
    await _favoritesRef.doc(songId).delete();
  }

  Future<bool> isFavorite(String songId) async {
    final doc = await _favoritesRef.doc(songId).get();
    return doc.exists;
  }

  Stream<Map<String, Map<String, dynamic>>> favoritesStream() {
    return _favoritesRef.snapshots().map((snapshot) {
      return {
        for (var doc in snapshot.docs)
          doc.id: doc.data() as Map<String, dynamic>,
      };
    });
  }

}
