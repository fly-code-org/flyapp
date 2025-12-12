// data/models/tag_mapping.dart
// Mapping of tag names to tag IDs
// TODO: Update with actual tag IDs from database
class TagMapping {
  // Social tags mapping
  static const Map<String, int> socialTags = {
    'Motivational': 1,
    'Lifestyle': 2,
    'Art & Creatives': 3,
    'Awwdorable': 4,
    'Fun & Humor': 5,
    'Peace': 6,
    'Words of Wisdom': 7,
    'News & Insights': 8,
    'Movies & Shows': 9,
  };

  // Support tags mapping
  static const Map<String, int> supportTags = {
    'Emotional Healing': 1, // This should match the DB - Emotional Healing has tag_id: 1
    'Anxiety & Stress': 2,
    'Grief & Heartbreak': 3,
    'Work & Career': 4,
    'Trauma': 5,
    'Family & Relations': 6,
    'Self-Worth & Identity': 7,
  };

  static int? getTagId(String tagName) {
    // Check social tags first
    if (socialTags.containsKey(tagName)) {
      return socialTags[tagName];
    }
    // Check support tags
    if (supportTags.containsKey(tagName)) {
      return supportTags[tagName];
    }
    return null;
  }

  static List<String> getAllSocialTagNames() {
    return socialTags.keys.toList();
  }

  static List<String> getAllSupportTagNames() {
    return supportTags.keys.toList();
  }
}

