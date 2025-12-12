// domain/entities/interests.dart
class Tag {
  final int tagId;
  final String name;

  Tag({
    required this.tagId,
    required this.name,
  });
}

class Interests {
  final List<Tag> tags;
  final List<String>? communities;

  Interests({
    required this.tags,
    this.communities,
  });
}

