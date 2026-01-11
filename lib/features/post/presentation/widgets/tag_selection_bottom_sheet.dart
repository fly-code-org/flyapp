// presentation/widgets/tag_selection_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../features/interests/data/models/tag_mapping.dart';

class TagSelectionBottomSheet extends StatelessWidget {
  final Function(String tagName, int tagId) onTagSelected;

  const TagSelectionBottomSheet({
    super.key,
    required this.onTagSelected,
  });

  // Social tags with icons
  static final List<Map<String, dynamic>> socialTags = [
    {
      'name': 'Motivational',
      'icon': 'assets/icon/social-tags/motivational.svg',
    },
    {
      'name': 'Lifestyle',
      'icon': 'assets/icon/social-tags/lifestyle.svg',
    },
    {
      'name': 'Art & Creatives',
      'icon': 'assets/icon/social-tags/artAndCreativity.svg',
    },
    {
      'name': 'Awwdorable',
      'icon': 'assets/icon/social-tags/awdorable.svg',
    },
    {
      'name': 'Fun & Humor',
      'icon': 'assets/icon/social-tags/funAndHumor.svg',
    },
    {
      'name': 'Peace',
      'icon': 'assets/icon/social-tags/peace.svg',
    },
    {
      'name': 'Words of Wisdom',
      'icon': 'assets/icon/social-tags/wordsOfWisdom.svg',
    },
    {
      'name': 'News & Insights',
      'icon': 'assets/icon/social-tags/newsAndInsights.svg',
    },
    {
      'name': 'Movies & Shows',
      'icon': 'assets/icon/social-tags/moviesAndShows.svg',
    },
  ];

  // Support tags with icons
  static final List<Map<String, dynamic>> supportTags = [
    {
      'name': 'Emotional Healing',
      'icon': Icons.healing,
    },
    {
      'name': 'Anxiety & Stress',
      'icon': Icons.sentiment_dissatisfied,
    },
    {
      'name': 'Grief & Heartbreak',
      'icon': Icons.heart_broken,
    },
    {
      'name': 'Work & Career',
      'icon': Icons.work,
    },
    {
      'name': 'Trauma',
      'icon': Icons.local_hospital,
    },
    {
      'name': 'Family & Relations',
      'icon': Icons.family_restroom,
    },
    {
      'name': 'Self-Worth & Identity',
      'icon': Icons.person,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Select a Tag',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Social Tags Section
                      const Text(
                        'Social Tags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...socialTags.map((tag) {
                        final tagName = tag['name'] as String;
                        final tagId = TagMapping.getTagId(tagName);
                        if (tagId == null) return const SizedBox.shrink();

                        return _buildTagTile(
                          context: context,
                          tagName: tagName,
                          tagId: tagId,
                          icon: tag['icon'] as String,
                          isSvg: true,
                        );
                      }),

                      const SizedBox(height: 24),

                      // Support Tags Section
                      const Text(
                        'Support Tags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...supportTags.map((tag) {
                        final tagName = tag['name'] as String;
                        final tagId = TagMapping.getTagId(tagName);
                        if (tagId == null) return const SizedBox.shrink();

                        return _buildTagTile(
                          context: context,
                          tagName: tagName,
                          tagId: tagId,
                          icon: tag['icon'] as IconData,
                          isSvg: false,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagTile({
    required BuildContext context,
    required String tagName,
    required int tagId,
    required dynamic icon,
    required bool isSvg,
  }) {
    return InkWell(
      onTap: () {
        onTagSelected(tagName, tagId);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: isSvg
                  ? SvgPicture.asset(
                      icon as String,
                      width: 24,
                      height: 24,
                      fit: BoxFit.scaleDown,
                    )
                  : Icon(
                      icon as IconData,
                      size: 24,
                      color: const Color(0xFF855DFC),
                    ),
            ),
            const SizedBox(width: 16),
            // Tag name
            Expanded(
              child: Text(
                tagName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Arrow
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

