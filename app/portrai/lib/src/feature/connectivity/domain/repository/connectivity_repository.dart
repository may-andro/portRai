abstract class ConnectivityRepository {
  Future<bool> isConnected();

  /// Emits whenever the reachability of the internet changes.
  Stream<bool> watchConnection();
}
