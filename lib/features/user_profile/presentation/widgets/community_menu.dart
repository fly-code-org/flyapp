import 'package:flutter/material.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/instance_manager.dart';
import 'package:get/get.dart';

class CommunityMenuSheet extends StatelessWidget {
  const CommunityMenuSheet({super.key});

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
            text: "Block u",
            onTap: () {
              Navigator.pop(context);
              // TODO: Handle navigation
              Get.toNamed(AppRoutes.CommunityGuidelines);
            },
          ),
          _divider(),
          _buildMenuItem(
            icon: Icons.notifications,
            text: "Manage notifications",
            onTap: () {
              Navigator.pop(context);
              // TODO: Handle navigation
            },
          ),
          _divider(),
          _buildMenuItem(
            icon: Icons.share,
            text: "Share",
            onTap: () {
              Navigator.pop(context);
              // TODO: Share action
            },
          ),
          _divider(),
          _buildMenuItem(
            icon: Icons.exit_to_app,
            text: "Leave Community",
            color: Colors.red, // 🔴 red text + icon
            onTap: () {
              Navigator.pop(context);
              // TODO: Leave action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.black, // default black unless overridden
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 16,
          color: color,
          fontWeight: text == "Leave Community"
              ? FontWeight
                    .w600 // emphasize destructive action
              : FontWeight.normal,
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
