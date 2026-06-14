import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/interests/data/models/tag_icon_mapping.dart';
import 'package:fly/features/user_profile/data/services/user_settings_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class _Tag {
  final int id;
  final String name;
  final String type;
  bool selected;
  _Tag({required this.id, required this.name, required this.type, this.selected = false});
}

class UserManagePreferencesScreen extends StatefulWidget {
  const UserManagePreferencesScreen({super.key});

  @override
  State<UserManagePreferencesScreen> createState() =>
      _UserManagePreferencesScreenState();
}

class _UserManagePreferencesScreenState
    extends State<UserManagePreferencesScreen> {
  final _ds = UserSettingsRemoteDataSource();

  List<_Tag> _socialTags = [];
  List<_Tag> _supportTags = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final allTagsFuture = _ds.getAllTags();
      final profileFuture = _ds.getProfile();
      final results = await Future.wait([allTagsFuture, profileFuture]);

      final allTags = results[0] as List<Map<String, dynamic>>;
      final profile = results[1] as Map<String, dynamic>;

      final followed = (profile['followed_interests'] as List? ?? [])
          .map((e) => (e as Map<String, dynamic>)['tag_id'])
          .toSet();

      final social = <_Tag>[];
      final support = <_Tag>[];
      for (final t in allTags) {
        final id = (t['tag_id'] as num?)?.toInt() ?? 0;
        final name = t['name']?.toString() ?? '';
        final type = t['type']?.toString() ?? 'social';
        final tag = _Tag(
          id: id,
          name: name,
          type: type,
          selected: followed.contains(id) || followed.contains(id.toString()),
        );
        if (type == 'support') {
          support.add(tag);
        } else {
          social.add(tag);
        }
      }
      _socialTags = social;
      _supportTags = support;
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final selected = [..._socialTags, ..._supportTags]
          .where((t) => t.selected)
          .map((t) => {'tag_id': t.id, 'name': t.name})
          .toList();
      await _ds.saveInterests(selected.cast<Map<String, dynamic>>());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferences saved')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () => popOrGoHome(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFF2F2F2)),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),
          title: const Text('Manage Preferences',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_socialTags.isNotEmpty) ...[
                            const Text('Social tags',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _socialTags.map(_tagChip).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (_supportTags.isNotEmpty) ...[
                            const Text('Support tags',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _supportTags.map(_tagChip).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _tagChip(_Tag tag) {
    final iconPath = TagIconMapping.getTagIconPath(tag.name);
    final hasIcon = iconPath.isNotEmpty;
    return GestureDetector(
      onTap: () => setState(() => tag.selected = !tag.selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: tag.selected
              ? _purple.withValues(alpha: 0.1)
              : const Color(0xFFF2F2F2),
          border: Border.all(
              color: tag.selected ? _purple : Colors.transparent),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIcon) ...[
              SvgPicture.asset(iconPath, width: 22, height: 22),
              const SizedBox(width: 6),
            ],
            Text(tag.name,
                style: TextStyle(
                    fontSize: 13,
                    color: tag.selected ? _purple : Colors.black87,
                    fontWeight: tag.selected ? FontWeight.w600 : FontWeight.w400)),
            if (tag.selected) ...[
              const SizedBox(width: 4),
              Icon(Icons.close, size: 14, color: _purple),
            ],
          ],
        ),
      ),
    );
  }
}
