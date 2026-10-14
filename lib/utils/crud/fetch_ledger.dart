/// Remembers when each list query was last fetched so repeat screen opens
/// can be served from Hive alone while the data is fresh.
///
/// Keys are `"<endpoint>|<query signature>"`, built by `ResourceCubit`.
/// Cleared on sign-out via `HiveService.clearPrefs()`, on 401 via
/// `HiveService.clearBox()`, and in `HiveService.clearAllTables()`.
class FetchLedger {
  FetchLedger._();

  static final FetchLedger instance = FetchLedger._();

  final Map<String, DateTime> _fetchedAt = {};

  /// Bumped by [clear] (sign-out, 401, table wipe). A refresh captures it
  /// when it starts and only marks its query fresh if it is unchanged, so a
  /// request that finishes after sign-out cannot mark the next user's query
  /// fresh.
  int get epoch => _epoch;
  int _epoch = 0;

  bool isFresh(String key, Duration staleAfter) {
    final at = _fetchedAt[key];
    if (at == null) return false;
    return DateTime.now().difference(at) <= staleAfter;
  }

  void markFetched(String key) => _fetchedAt[key] = DateTime.now();

  void invalidatePrefix(String prefix) =>
      _fetchedAt.removeWhere((key, _) => key.startsWith(prefix));

  void clear() {
    _epoch += 1;
    _fetchedAt.clear();
  }
}
