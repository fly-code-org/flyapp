import '../repositories/mhp_profile_repository.dart';

class MhpBookedSessionsPage {
  final List<Map<String, dynamic>> items;
  final bool hasMore;

  const MhpBookedSessionsPage({required this.items, required this.hasMore});
}

/// GET /mhp/external/v1/booked-sessions (MHP JWT).
class GetMhpBookedSessions {
  final MhpProfileRepository repository;

  GetMhpBookedSessions(this.repository);

  Future<MhpBookedSessionsPage> call({int skip = 0, int limit = 20}) async {
    final raw = await repository.getBookedSessions(skip: skip, limit: limit);
    final data = raw['data'];
    if (data is! Map<String, dynamic>) {
      return const MhpBookedSessionsPage(items: [], hasMore: false);
    }
    final itemsRaw = data['items'];
    final List<Map<String, dynamic>> items = [];
    if (itemsRaw is List) {
      for (final e in itemsRaw) {
        if (e is Map<String, dynamic>) {
          items.add(Map<String, dynamic>.from(e));
        }
      }
    }
    final hasMore = data['has_more'] == true;
    return MhpBookedSessionsPage(items: items, hasMore: hasMore);
  }
}
