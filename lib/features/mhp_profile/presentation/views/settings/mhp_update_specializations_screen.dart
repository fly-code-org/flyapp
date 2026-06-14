import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);
const _purpleLight = Color(0xFFEDE9FB);

class MhpUpdateSpecializationsScreen extends StatefulWidget {
  const MhpUpdateSpecializationsScreen({super.key});

  @override
  State<MhpUpdateSpecializationsScreen> createState() =>
      _MhpUpdateSpecializationsScreenState();
}

class _MhpUpdateSpecializationsScreenState
    extends State<MhpUpdateSpecializationsScreen> {
  final _ds = MhpProfileRemoteDataSourceImpl();
  final _searchCtrl = TextEditingController();

  List<String> _selected = [];
  List<String> _suggestions = [];
  bool _searching = false;
  bool _saving = false;
  bool _loading = true;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await _ds.getMhpProfile();
      final specs = profile['specializations'];
      if (specs is List) {
        setState(() => _selected = specs.cast<String>());
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await _ds.searchSpecializations(q.trim());
      setState(() => _suggestions = results);
    } catch (_) {
      setState(() => _suggestions = []);
    }
    setState(() => _searching = false);
  }

  void _add(String spec) {
    spec = spec.trim();
    if (spec.isEmpty || _selected.contains(spec)) return;
    setState(() {
      _selected.add(spec);
      _suggestions = [];
      _searchCtrl.clear();
      _showSearch = false;
    });
  }

  void _remove(String spec) => setState(() => _selected.remove(spec));

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _ds.updateSpecializations(_selected);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Specializations updated')));
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
        appBar: _buildAppBar(context),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : _showSearch
                ? _searchView()
                : _tagsView(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () {
              if (_showSearch) {
                setState(() {
                  _showSearch = false;
                  _suggestions = [];
                  _searchCtrl.clear();
                });
              } else {
                popOrGoHome(context);
              }
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFF2F2F2)),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
        ),
        title: const Text('Update Specializations',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
      );

  Widget _searchView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Specialization',
              hintStyle: const TextStyle(color: Colors.black38),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: _purple),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: _purple, width: 2),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.black45),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.black45),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _suggestions = []);
                      })
                  : null,
            ),
          ),
        ),
        if (_searching)
          const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: _purple),
          ),
        Expanded(
          child: ListView(
            children: [
              if (_suggestions.isNotEmpty)
                ..._suggestions.map((s) => ListTile(
                      title: Text(s),
                      onTap: () => _add(s),
                    )),
              if (_searchCtrl.text.trim().isNotEmpty &&
                  !_suggestions.contains(_searchCtrl.text.trim()))
                ListTile(
                  leading: const Icon(Icons.add, color: _purple),
                  title: Text('Add "${_searchCtrl.text.trim()}"'),
                  onTap: () => _add(_searchCtrl.text.trim()),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: _saveButton(_saving ? null : _save, _saving),
        ),
      ],
    );
  }

  Widget _tagsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selected.isNotEmpty) ...[
                  const Text('Specializations',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selected
                        .map((s) => _chip(s, _selected.indexOf(s) == 0))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                GestureDetector(
                  onTap: () => setState(() => _showSearch = true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Add other specializations',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 14)),
                        Icon(Icons.add, color: Colors.black45),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: _saveButton(_saving ? null : _save, _saving),
        ),
      ],
    );
  }

  Widget _chip(String label, bool first) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: first ? _purpleLight : Colors.white,
          border: Border.all(color: first ? _purple : const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    color: first ? _purple : Colors.black87,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _remove(label),
              child: Icon(Icons.close,
                  size: 14, color: first ? _purple : Colors.black54),
            ),
          ],
        ),
      );
}

Widget _saveButton(VoidCallback? onTap, bool loading) => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: loading
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
    );
