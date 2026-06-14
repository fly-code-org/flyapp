import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class MhpSessionPreferencesScreen extends StatefulWidget {
  const MhpSessionPreferencesScreen({super.key});

  @override
  State<MhpSessionPreferencesScreen> createState() =>
      _MhpSessionPreferencesScreenState();
}

class _MhpSessionPreferencesScreenState
    extends State<MhpSessionPreferencesScreen> {
  final _ds = MhpProfileRemoteDataSourceImpl();

  bool _video = true;
  bool _call = true;
  bool _inPerson = true;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _ds.getSessionPreferences();
      setState(() {
        _video = data['video_enabled'] as bool? ?? true;
        _call = data['call_enabled'] as bool? ?? true;
        _inPerson = data['in_person_enabled'] as bool? ?? true;
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _ds.updateSessionPreferences({
        'video_enabled': _video,
        'call_enabled': _call,
        'in_person_enabled': _inPerson,
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Preferences saved')));
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
          title: const Text('Session Preferences',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _toggleRow('For Video', _video,
                            (v) => setState(() => _video = v)),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _toggleRow('For Call', _call,
                            (v) => setState(() => _call = v)),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _toggleRow('For In-person', _inPerson,
                            (v) => setState(() => _inPerson = v)),
                      ],
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

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _purple,
          ),
        ],
      ),
    );
  }
}
