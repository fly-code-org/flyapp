/// Result of GET /community/external/v1/explore/search
class ExploreSearchResult {
  final List<ExploreSearchMhp> mhps;
  final List<ExploreSearchCommunity> communities;

  const ExploreSearchResult({
    required this.mhps,
    required this.communities,
  });
}

class ExploreSearchMhp {
  final String userId;
  final String displayName;
  final String subtitle;
  final String picturePath;

  const ExploreSearchMhp({
    required this.userId,
    required this.displayName,
    required this.subtitle,
    required this.picturePath,
  });
}

/// Result of GET /community/external/v1/explore/mhps (paginated "Discover MHPs").
class DiscoverMhpsResult {
  final List<ExploreSearchMhp> mhps;
  final int total;
  final int skip;
  final int limit;

  const DiscoverMhpsResult({
    required this.mhps,
    required this.total,
    required this.skip,
    required this.limit,
  });

  /// Whether more pages remain after this one.
  bool get hasMore => skip + mhps.length < total;
}

class ExploreSearchCommunity {
  final String id;
  final String name;
  final String type;
  final String logoPath;

  const ExploreSearchCommunity({
    required this.id,
    required this.name,
    required this.type,
    required this.logoPath,
  });
}
