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
