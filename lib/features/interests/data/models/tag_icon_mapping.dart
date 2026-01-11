// data/models/tag_icon_mapping.dart
// Mapping of tag names to SVG asset paths
import 'tag_mapping.dart';

class TagIconMapping {
  // Social tags icon mapping
  static const Map<String, String> socialTagIcons = {
    'Motivational': 'assets/icon/social-tags/motivational.svg',
    'Lifestyle': 'assets/icon/social-tags/lifestyle.svg',
    'Art & Creatives': 'assets/icon/social-tags/artAndCreativity.svg',
    'Art & Creativity': 'assets/icon/social-tags/artAndCreativity.svg', // Alias
    'Awwdorable': 'assets/icon/social-tags/awdorable.svg',
    'Fun & Humor': 'assets/icon/social-tags/funAndHumor.svg',
    'Peace': 'assets/icon/social-tags/peace.svg',
    'Words of Wisdom': 'assets/icon/social-tags/wordsOfWisdom.svg',
    'News & Insights': 'assets/icon/social-tags/newsAndInsights.svg',
    'Movies & Shows': 'assets/icon/social-tags/moviesAndShows.svg',
  };

  // Support tags icon mapping
  static const Map<String, String> supportTagIcons = {
    'Emotional Healing': 'assets/icon/support-tags/emotionalHealing.svg',
    'Anxiety & Stress': 'assets/icon/support-tags/anxietyAndStress.svg',
    'Grief & Heartbreak': 'assets/icon/support-tags/griefAndHeartbreak.svg',
    'Work & Career': 'assets/icon/support-tags/workAndCareer.svg',
    'Trauma': 'assets/icon/support-tags/traumaAndHealing.svg',
    'Family & Relations': 'assets/icon/support-tags/familyAndRelationship.svg',
    'Self-Worth & Identity': 'assets/icon/support-tags/selfWorthAndIdentity.svg',
  };

  /// Get SVG asset path for a tag name
  /// Returns the asset path if found, or empty string if not found
  static String getTagIconPath(String tagName) {
    // Check social tags first
    if (socialTagIcons.containsKey(tagName)) {
      return socialTagIcons[tagName]!;
    }
    // Check support tags
    if (supportTagIcons.containsKey(tagName)) {
      return supportTagIcons[tagName]!;
    }
    // Return empty string if not found
    return '';
  }

  /// Get SVG asset path by tag ID
  /// Returns the asset path if found, or empty string if not found
  static String getTagIconPathById(int tagId) {
    // Import tag_mapping to get tag name by ID
    final tagName = TagMapping.getTagNameById(tagId);
    if (tagName != null) {
      return getTagIconPath(tagName);
    }
    return '';
  }
}
