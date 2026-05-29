import 'local_storage.dart';
import 'auth_service.dart';

/// Manages favourite synchronisation.
/// Currently writes to local Hive storage only.
/// Ready for cloud sync: when [authService.currentUser] is non-null,
/// a real implementation would push/pull from Firestore or a REST API.
class SyncService {
  final AuthService _authService;

  SyncService({required AuthService authService})
      : _authService = authService;

  /// Loads favourites from the best available source.
  /// Local storage is used unconditionally for now.
  Future<Set<String>> loadFavourites() async {
    return LocalStorage.loadFavourites();
  }

  /// Persists favourites locally and queues a cloud push when authenticated.
  Future<void> saveFavourites(Set<String> ids) async {
    await LocalStorage.saveFavourites(ids);
    if (_authService.currentUser != null) {
      await _syncToCloud(ids);
    }
  }

  /// Placeholder — will push to Firestore / backend in a future sprint.
  Future<void> _syncToCloud(Set<String> ids) async {
    // TODO(phase2.3): implement Firestore push
    // e.g.
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(_authService.currentUser!.id)
    //     .set({'favourites': ids.toList()}, SetOptions(merge: true));
  }
}
