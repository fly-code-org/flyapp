import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/community/domain/usecases/get_tags.dart';
import 'package:fly/features/interests/data/models/tag_mapping.dart';

/// Canonical tag_id ↔ name from GET /tag. Hardcoded [TagMapping] overlaps social/support
/// numeric ids; always prefer this catalog after [ensureLoaded] for follow/create flows.
class ServerTagCatalog {
  ServerTagCatalog();

  Map<String, int> _nameToId = {};
  Map<int, String> _idToName = {};
  bool _loaded = false;
  Future<void>? _loadFuture;

  void invalidate() {
    _loaded = false;
    _nameToId = {};
    _idToName = {};
    _loadFuture = null;
  }

  Future<void> refresh() {
    invalidate();
    return ensureLoaded();
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loadFuture ??= _load();
    await _loadFuture;
  }

  Future<void> _load() async {
    try {
      final getTags = sl<GetTags>();
      final rows = await getTags.call();
      final n2i = <String, int>{};
      final i2n = <int, String>{};
      for (final row in rows) {
        final name = (row['name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;
        final id = _parseTagId(row['tag_id']);
        if (id == 0) continue;
        n2i[name] = id;
        i2n[id] = name;
      }
      _nameToId = n2i;
      _idToName = i2n;
      _loaded = true;
    } finally {
      _loadFuture = null;
    }
  }

  int _parseTagId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is Map && value.containsKey('\$numberLong')) {
      final v = value['\$numberLong'];
      if (v is String) return int.tryParse(v) ?? 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
    }
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Resolved tag_id for a display name, or [TagMapping] fallback if catalog not loaded / unknown.
  int? tagIdForName(String name) {
    final t = name.trim();
    final fromServer = _nameToId[t];
    if (fromServer != null) return fromServer;
    for (final e in _nameToId.entries) {
      if (e.key.toLowerCase() == t.toLowerCase()) return e.value;
    }
    return TagMapping.getTagId(t);
  }

  /// Display name for a tag_id from server, or [TagMapping.getTagNameById] fallback.
  String? displayNameForTagId(int tagId) {
    final fromServer = _idToName[tagId];
    if (fromServer != null) return fromServer;
    return TagMapping.getTagNameById(tagId);
  }
}
