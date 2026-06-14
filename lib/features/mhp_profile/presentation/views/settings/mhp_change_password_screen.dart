import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class MhpChangePasswordScreen extends StatefulWidget {
  const MhpChangePasswordScreen({super.key});

  @override
  State<MhpChangePasswordScreen> createState() => _MhpChangePasswordScreenState();
}

class _MhpChangePasswordScreenState extends State<MhpChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _saving = false;

  final _ds = MhpProfileRemoteDataSourceImpl();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentCtrl.text.trim();
    final newPw = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      _snack('Please fill in all fields');
      return;
    }
    if (newPw != confirm) {
      _snack('New passwords do not match');
      return;
    }
    if (newPw.length < 8) {
      _snack('New password must be at least 8 characters');
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
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
        appBar: _appBar(context, 'Change Password'),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current password',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              _passwordField(_currentCtrl, 'Enter current password', _showCurrent,
                  () => setState(() => _showCurrent = !_showCurrent)),
              const SizedBox(height: 20),
              const Text('New Password',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              _passwordField(_newCtrl, 'Enter new password', _showNew,
                  () => setState(() => _showNew = !_showNew)),
              const SizedBox(height: 12),
              _passwordField(_confirmCtrl, 'Re-enter new password', _showConfirm,
                  () => setState(() => _showConfirm = !_showConfirm)),
              const Spacer(),
              _saveButton(_saving ? null : _save, _saving),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField(
      TextEditingController ctrl, String hint, bool visible, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: !visible,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: _purple),
        ),
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.black45),
        ),
      ),
    );
  }
}

AppBar _appBar(BuildContext context, String title) => AppBar(
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
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
    );

Widget _saveButton(VoidCallback? onTap, bool loading) => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Save Changes',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
      ),
    );
