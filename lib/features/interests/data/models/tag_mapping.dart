// data/models/tag_mapping.dart
// Fallback tag name → tag_id when the app has not loaded GET /community/external/v1/tag yet.
// Authoritative IDs live in MongoDB `tags` (e.g. support "Grief & Heartbreak" uses tag_id 3).
// Social vs support used overlapping small integers here; follow/unfollow must use the real
// tag_id from the server (see Explore `_serverTagIdByName` / `_resolveTagId`).
class TagMapping {
  // Social tags mapping
  // Note: "Art & Creatives" in TagMapping matches "Art & Creativity" in explore.dart
  // Using "Art & Creatives" as it's more consistent with the naming pattern
  static const Map<String, int> socialTags = {
    'Motivational': 1,
    'Lifestyle': 2,
    'Art & Creatives': 3, // Also matches "Art & Creativity" in explore.dart
    'Art & Creativity': 3, // Alias for consistency
    'Awwdorable': 4,
    'Fun & Humor': 5,
    'Peace': 6,
    'Words of Wisdom': 7,
    'News & Insights': 8,
    'Movies & Shows': 9,
  };

  // Support tags mapping (must match MongoDB `tags.tag_id` per name)
  static const Map<String, int> supportTags = {
    'Emotional Healing': 1, // This should match the DB - Emotional Healing has tag_id: 1
    'Anxiety & Stress': 2,
    'Grief & Heartbreak': 3, // MongoDB: type support, tag_id 3
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
  
  static String? getTagType(String tagName) {
    // Check if it's a social tag
    if (socialTags.containsKey(tagName)) {
      return 'social';
    }
    // Check if it's a support tag
    if (supportTags.containsKey(tagName)) {
      return 'support';
    }
    return null;
  }

  /// Get tag name by tag ID
  static String? getTagNameById(int tagId) {
    // Search in social tags
    for (final entry in socialTags.entries) {
      if (entry.value == tagId) {
        return entry.key;
      }
    }
    // Search in support tags if not found in social tags
    for (final entry in supportTags.entries) {
      if (entry.value == tagId) {
        return entry.key;
      }
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

