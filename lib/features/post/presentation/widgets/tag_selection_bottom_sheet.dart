// presentation/widgets/tag_selection_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/core/di/service_locator.dart';
import '../../../../features/interests/data/models/tag_icon_mapping.dart';
import '../../../../features/interests/data/server_tag_catalog.dart';

class TagSelectionBottomSheet extends StatefulWidget {
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

  // Support tag names — icons resolved via [TagIconMapping] (same assets as explore/feed)
  static const List<String> supportTagNames = [
    'Emotional Healing',
    'Anxiety & Stress',
    'Grief & Heartbreak',
    'Work & Career',
    'Trauma',
    'Family & Relations',
    'Self-Worth & Identity',
  ];

  @override
  State<TagSelectionBottomSheet> createState() =>
      _TagSelectionBottomSheetState();
}

class _TagSelectionBottomSheetState extends State<TagSelectionBottomSheet> {
  bool _catalogReady = false;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      await sl<ServerTagCatalog>().ensureLoaded();
    } catch (_) {}
    if (mounted) setState(() => _catalogReady = true);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        if (!_catalogReady) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Social Tags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...TagSelectionBottomSheet.socialTags.map((tag) {
                        final tagName = tag['name'] as String;
                        final tagId =
                            sl<ServerTagCatalog>().tagIdForName(tagName);
                        if (tagId == null) return const SizedBox.shrink();

                        return _buildTagTile(
                          context: context,
                          tagName: tagName,
                          tagId: tagId,
                          iconPath: tag['icon'] as String,
                        );
                      }),
                      const SizedBox(height: 24),
                      const Text(
                        'Support Tags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...TagSelectionBottomSheet.supportTagNames.map((tagName) {
                        final tagId =
                            sl<ServerTagCatalog>().tagIdForName(tagName);
                        if (tagId == null) return const SizedBox.shrink();

                        final iconPath = TagIconMapping.getTagIconPath(tagName);
                        if (iconPath.isEmpty) return const SizedBox.shrink();

                        return _buildTagTile(
                          context: context,
                          tagName: tagName,
                          tagId: tagId,
                          iconPath: iconPath,
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
    required String iconPath,
  }) {
    return InkWell(
      onTap: () {
        widget.onTagSelected(tagName, tagId);
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                fit: BoxFit.scaleDown,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                tagName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
