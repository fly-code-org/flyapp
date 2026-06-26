import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class MhpPaymentManagementScreen extends StatefulWidget {
  const MhpPaymentManagementScreen({super.key});

  @override
  State<MhpPaymentManagementScreen> createState() =>
      _MhpPaymentManagementScreenState();
}

class _MhpPaymentManagementScreenState
    extends State<MhpPaymentManagementScreen> {
  final _ds = MhpProfileRemoteDataSourceImpl();
  final _nameCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();

  bool _editing = false;
  bool _saving = false;
  bool _loading = true;
  bool _hasExisting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _ds.getPaymentMethod();
      final name = data['holder_name']?.toString() ?? '';
      final upi = data['upi_id']?.toString() ?? '';
      if (name.isNotEmpty || upi.isNotEmpty) {
        _nameCtrl.text = name;
        _upiCtrl.text = upi;
        _hasExisting = true;
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final upi = _upiCtrl.text.trim();
    if (upi.isEmpty) {
      _snack('UPI ID is required');
      return;
    }
    if (name.isEmpty) {
      _snack('Account holder name is required');
      return;
    }
    setState(() => _saving = true);
    try {
      await _ds.updatePaymentMethod({'holder_name': name, 'upi_id': upi});
      if (mounted) {
        setState(() {
          _hasExisting = true;
          _editing = false;
        });
        _snack('Payment method saved');
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
          title: const Text('Payment Management',
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
                          const Text(
                            'This account will be used as the default UPI ID to receive all payments for sessions conducted.',
                            style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('UPI Payment details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 15)),
                                const Divider(height: 20),
                                if (_hasExisting && !_editing) ...[
                                  _viewRow('Account Holder Name', _nameCtrl.text),
                                  const SizedBox(height: 10),
                                  _viewRow('UPI ID', _upiCtrl.text),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _editing = true),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset('assets/icon/edit.svg', width: 16, height: 16),
                                          SizedBox(width: 4),
                                          Text('Edit',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  _fieldLabel('Account Holder Name'),
                                  const SizedBox(height: 6),
                                  _inputField(
                                      _nameCtrl, 'Account Holder Name'),
                                  const SizedBox(height: 14),
                                  _fieldLabel('UPI ID'),
                                  const SizedBox(height: 6),
                                  _inputField(_upiCtrl,
                                      'e.g. name@upi or 9876543210@okaxis'),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!_hasExisting || _editing)
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

  Widget _viewRow(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(color: Colors.black45, fontSize: 14)),
        ],
      );

  Widget _fieldLabel(String label) => Text(label,
      style:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87));

  Widget _inputField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
