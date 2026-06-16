import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/services/share_service.dart';
import 'package:fly/features/community/domain/usecases/unfollow_community.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class CommunityMenuSheet extends StatefulWidget {
  final String communityId;
  final String communityName;

  const CommunityMenuSheet({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  State<CommunityMenuSheet> createState() => _CommunityMenuSheetState();
}

class _CommunityMenuSheetState extends State<CommunityMenuSheet> {
  bool _isLeaving = false;

  Future<void> _handleLeaveCommunity() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Community'),
        content: Text(
          'Are you sure you want to leave ${widget.communityName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLeaving = true);

    try {
      await sl<UnfollowCommunity>().call(widget.communityId);
      if (mounted) {
        Navigator.pop(context);
        Get.until((route) => route.settings.name == AppRoutes.Home || route.isFirst);
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('You left ${widget.communityName}.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLeaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to leave community. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            icon: Icons.rule,
            text: "Community Guidelines",
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.CommunityGuidelines);
            },
          ),
          _divider(),
          _buildMenuItem(
            icon: Icons.notifications,
            text: "Manage notifications",
            onTap: () {
              Navigator.pop(context);
              // Phase 2.3: TODO — per-community notification preferences
            },
          ),
          _divider(),
          Builder(
            builder: (shareCtx) => _buildMenuItem(
              icon: Icons.share,
              text: "Share",
              onTap: () {
                Navigator.pop(context);
                ShareService.shareCommunity(
                  communityId: widget.communityId,
                  communityName: widget.communityName,
                  context: shareCtx,
                );
              },
            ),
          ),
          _divider(),
          _isLeaving
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildMenuItem(
                  icon: Icons.exit_to_app,
                  text: "Leave Community",
                  color: Colors.red,
                  onTap: _handleLeaveCommunity,
                ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 16,
          color: color,
          fontWeight:
              text == "Leave Community" ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(
      color: Colors.grey,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
    );
  }
}
