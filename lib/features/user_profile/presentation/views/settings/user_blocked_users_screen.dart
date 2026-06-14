import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/user_profile/data/services/user_settings_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class _BlockedUser {
  final String userId;
  final String username;
  final String? picture;
  final DateTime blockedAt;
  _BlockedUser({
    required this.userId,
    required this.username,
    this.picture,
    required this.blockedAt,
  });

  factory _BlockedUser.fromMap(Map<String, dynamic> m) => _BlockedUser(
        userId: m['user_id']?.toString() ?? '',
        username: m['username']?.toString() ?? 'Unknown',
        picture: m['picture_path']?.toString(),
        blockedAt: DateTime.tryParse(m['blocked_at']?.toString() ?? '') ??
            DateTime.now(),
      );
}

class UserBlockedUsersScreen extends StatefulWidget {
  const UserBlockedUsersScreen({super.key});

  @override
  State<UserBlockedUsersScreen> createState() =>
      _UserBlockedUsersScreenState();
}

class _UserBlockedUsersScreenState extends State<UserBlockedUsersScreen> {
  final _ds = UserSettingsRemoteDataSource();
  final _searchCtrl = TextEditingController();

  List<_BlockedUser> _all = [];
  List<_BlockedUser> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _ds.getBlockedUsers();
      _all = data.map(_BlockedUser.fromMap).toList();
      _filtered = List.from(_all);
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _filter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_all)
          : _all
              .where((u) => u.username.toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> _unblock(_BlockedUser user) async {
    try {
      await _ds.unblockUser(user.userId);
      setState(() {
        _all.removeWhere((u) => u.userId == user.userId);
        _filtered.removeWhere((u) => u.userId == user.userId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 18),
                const SizedBox(width: 8),
                const Text('User unblocked successfully'),
              ],
            ),
            backgroundColor: const Color(0xFFF0FFF4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return 'blocked ${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours >= 1) return 'blocked ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return 'blocked just now';
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
          title: const Text('Blocked Users',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search block users',
                        hintStyle: const TextStyle(
                            color: Colors.black38, fontSize: 14),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.black45),
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_filtered.length} blocked user${_filtered.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _filtered.isEmpty
                        ? const Center(
                            child: Text('No blocked users',
                                style: TextStyle(color: Colors.black45)))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: Color(0xFFEEEEEE)),
                            itemBuilder: (_, i) {
                              final user = _filtered[i];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          const Color(0xFFE0E0E0),
                                      backgroundImage: user.picture != null
                                          ? NetworkImage(user.picture!)
                                          : null,
                                      child: user.picture == null
                                          ? const Icon(Icons.person,
                                              color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(user.username,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14)),
                                          Text(_timeAgo(user.blockedAt),
                                              style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _unblock(user),
                                      child: const Text('Unblock',
                                          style: TextStyle(
                                              color: _purple,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
