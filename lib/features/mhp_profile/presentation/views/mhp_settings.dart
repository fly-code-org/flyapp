import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/core/utils/safe_navigation.dart';

class MhpSettingsScreen extends StatelessWidget {
  const MhpSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> settingsOptions = [
      'Edit Profile',
      'Manage Session',
      'Change Password',
      'Blocked Users',
      'Manage Tags',
      'Community Guidelines',
      'Privacy Policy',
      'Terms & Conditions',
      'Delete Account',
      'Logout',
    ];

    return SafePopScope(
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () => popOrGoHome(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF2F2F2), // light grey background
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF2F2F2),
              ),
              // Placeholder for SVG icon
              child: SvgPicture.asset(
                'assets/images/sos.svg', // replace with your path
                width: 30,
                height: 30,
                // color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: settingsOptions.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
        itemBuilder: (context, index) {
          final option = settingsOptions[index];
          return ListTile(
            title: Text(
              option,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
            onTap: () {
              // TODO: Navigate to respective screen
              // Example:
              // Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen()));
            },
          );
        },
      ),
    ),
    );
  }
}
