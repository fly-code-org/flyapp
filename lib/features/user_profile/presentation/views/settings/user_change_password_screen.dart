import 'package:flutter/material.dart';
import 'package:fly/core/storage/token_storage.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/user_profile/data/services/user_settings_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class UserChangePasswordScreen extends StatefulWidget {
  const UserChangePasswordScreen({super.key});

  @override
  State<UserChangePasswordScreen> createState() =>
      _UserChangePasswordScreenState();
}

class _UserChangePasswordScreenState
    extends State<UserChangePasswordScreen> {
  final _ds = UserSettingsRemoteDataSource();

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _saving = false;

  // null = still checking, true = Google user (no password), false = email/password user
  bool? _isGoogleUser;

  @override
  void initState() {
    super.initState();
    _checkAuthProvider();
  }

  Future<void> _checkAuthProvider() async {
    // Check the stored auth provider instead of Google Sign-In state
    final isGoogle = await TokenStorage.isGoogleUser();
    setState(() => _isGoogleUser = isGoogle);
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentCtrl.text;
    final newPw = _newCtrl.text;
    final confirm = _confirmCtrl.text;
    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      _snack('All fields are required');
      return;
    }
    if (newPw != confirm) {
      _snack('New passwords do not match');
      return;
    }
    if (newPw.length < 8) {
      _snack('Password must be at least 8 characters');
      return;
    }
    setState(() => _saving = true);
    try {
      await _ds.changePassword(current, newPw);
      if (mounted) {
        _snack('Password changed successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      _snack(e.toString());
    }
    if (mounted) setState(() => _saving = false);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
          title: const Text('Change Password',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: _isGoogleUser == null
            ? const Center(
                child: CircularProgressIndicator(color: _purple),
              )
            : _isGoogleUser!
                ? _buildGoogleUserInfo()
                : _buildPasswordForm(),
      ),
    );
  }

  Widget _buildGoogleUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/google.png',
                    width: 28,
                    height: 28,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Signed in with Google',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your account uses Google Sign-In. Password management is handled through your Google account.',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'To change your Google account password, visit myaccount.google.com.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current password',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _pwField(_currentCtrl, 'Enter current password',
                    _showCurrent, () => setState(() => _showCurrent = !_showCurrent)),
                const SizedBox(height: 20),
                const Text('New Password',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _pwField(_newCtrl, 'Enter new password', _showNew,
                    () => setState(() => _showNew = !_showNew)),
                const SizedBox(height: 12),
                _pwField(_confirmCtrl, 'Re-enter new password',
                    _showConfirm,
                    () => setState(() => _showConfirm = !_showConfirm)),
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
    );
  }

  Widget _pwField(TextEditingController ctrl, String hint, bool visible,
          VoidCallback toggle) =>
      TextField(
        controller: ctrl,
        obscureText: !visible,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          suffixIcon: IconButton(
            icon: Icon(
                visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.black45,
                size: 20),
            onPressed: toggle,
          ),
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
            borderSide: const BorderSide(color: _purple),
          ),
        ),
      );
}
