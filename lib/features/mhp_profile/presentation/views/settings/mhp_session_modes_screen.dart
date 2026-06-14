import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class MhpSessionModesScreen extends StatefulWidget {
  const MhpSessionModesScreen({super.key});

  @override
  State<MhpSessionModesScreen> createState() => _MhpSessionModesScreenState();
}

class _MhpSessionModesScreenState extends State<MhpSessionModesScreen> {
  final _ds = MhpProfileRemoteDataSourceImpl();

  int _videoFee = 0;
  int _callFee = 0;
  int _inPersonFee = 0;
  bool _videoEnabled = true;
  bool _callEnabled = true;
  bool _inPersonEnabled = true;
  bool _saving = false;
  bool _loading = true;

  static const int _maxFee = 5000;
  static const int _step = 100;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final fees = await _ds.getConsultationFees();
      final prefs = await _ds.getSessionPreferences();
      setState(() {
        _videoFee = (fees['video_fee_inr'] as int?) ?? 0;
        _callFee = (fees['call_fee_inr'] as int?) ?? 0;
        _inPersonFee = (fees['in_person_fee_inr'] as int?) ?? 0;
        _videoEnabled = prefs['video_enabled'] as bool? ?? true;
        _callEnabled = prefs['call_enabled'] as bool? ?? true;
        _inPersonEnabled = prefs['in_person_enabled'] as bool? ?? true;
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _ds.updateConsultationFees({
        'video_fee_inr': _videoFee,
        'call_fee_inr': _callFee,
        'in_person_fee_inr': _inPersonFee,
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Fees saved')));
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
          title: const Text('Session modes',
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
                        children: [
                          if (_videoEnabled)
                            _feeCard(
                              'For Video',
                              _videoFee,
                              (v) => setState(() => _videoFee = v),
                            ),
                          if (_callEnabled)
                            _feeCard(
                              'For Call',
                              _callFee,
                              (v) => setState(() => _callFee = v),
                              showPrice: false,
                            ),
                          if (_inPersonEnabled)
                            _feeCard(
                              'For In-person',
                              _inPersonFee,
                              (v) => setState(() => _inPersonFee = v),
                            ),
                          if (!_videoEnabled && !_callEnabled && !_inPersonEnabled)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Enable session types in Session Preferences to set fees.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black45),
                              ),
                            ),
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
              ),
      ),
    );
  }

  Widget _feeCard(String title, int fee, ValueChanged<int> onChanged,
      {bool showPrice = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              if (showPrice)
                Row(
                  children: [
                    const Text('₹', style: TextStyle(color: Colors.black45)),
                    const SizedBox(width: 4),
                    Text(fee.toString(),
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 15)),
                  ],
                ),
            ],
          ),
          if (showPrice) ...[
            const SizedBox(height: 4),
            const Text('Price',
                style: TextStyle(color: Colors.black45, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _purple,
              inactiveTrackColor: const Color(0xFFE0E0E0),
              thumbColor: _purple,
              overlayColor: _purple.withOpacity(0.15),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: fee.toDouble(),
              min: 0,
              max: _maxFee.toDouble(),
              divisions: _maxFee ~/ _step,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Text('Suggested price – ₹1000',
              style: TextStyle(color: Colors.black38, fontSize: 12)),
        ],
      ),
    );
  }
}
