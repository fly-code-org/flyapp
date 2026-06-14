import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/core/utils/app_logout.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
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
          title: const Text('Settings',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SvgPicture.asset('assets/images/sos.svg',
                  width: 36, height: 36),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _sectionLabel('Account Settings'),
            _settingsGroup([
              _tile('Edit Profile', () => Get.toNamed(AppRoutes.UserEditProfile)),
              _divider(),
              _tile('Manage Preferences',
                  () => Get.toNamed(AppRoutes.UserManagePreferences)),
              _divider(),
              _tile('Blocked Users', () => Get.toNamed(AppRoutes.UserBlockedUsers)),
              _divider(),
              _tile('Change Password',
                  () => Get.toNamed(AppRoutes.UserChangePassword)),
            ]),
            const SizedBox(height: 24),
            _sectionLabel('Session'),
            _settingsGroup([
              _tile('Manage Sessions',
                  () => Get.toNamed(AppRoutes.UserManageSessions)),
            ]),
            const SizedBox(height: 24),
            _sectionLabel('Payments & Billing'),
            _settingsGroup([
              _tile('Payment history',
                  () => Get.toNamed(AppRoutes.UserPaymentHistory)),
            ]),
            const SizedBox(height: 24),
            _sectionLabel('Support & Feedback'),
            _settingsGroup([
              _tile('Terms and conditions',
                  () => Get.toNamed(AppRoutes.UserTermsConditions)),
              _divider(),
              _tile('Contact us', () => Get.toNamed(AppRoutes.UserContactUs)),
            ]),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => confirmAndLogout(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 32),
                child: Text('Log out',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      );

  Widget _settingsGroup(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      );

  Widget _divider() => const Divider(
      height: 1, indent: 16, endIndent: 16, color: Color(0xFFE0E0E0));

  Widget _tile(String title, VoidCallback onTap) => ListTile(
        title: Text(title,
            style: const TextStyle(fontSize: 15, color: Colors.black87)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.black45),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      );
}
