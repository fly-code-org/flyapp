import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/mhp_profile/data/datasources/connect_booking_remote_data_source.dart';
import 'package:fly/features/mhp_profile/data/models/connect_booking_models.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const _purple = Color(0xFF855DFC);
const _titleSize = 22.24;

/// Maps Connect tab UI labels to fly-be `preference` values.
String connectPreferenceUiToApi(String ui) {
  switch (ui.trim()) {
    case 'Video':
      return 'video';
    case 'Call':
      return 'call';
    case 'In-Person':
      return 'in-person';
    default:
      return ui.toLowerCase().trim().replaceAll(' ', '-');
  }
}

List<int> _durationsForOffer(ConnectOfferOption? offer, String preferenceUi) {
  if (offer == null) return [];
  final api = connectPreferenceUiToApi(preferenceUi);
  final set = <int>{};
  for (final m in offer.sessionModes) {
    if (m.mode.toLowerCase() == api) set.add(m.durationMinutes);
  }
  final list = set.toList()..sort();
  return list;
}

/// Connect tab when a **visitor** views another MHP's profile (not shown for MHP viewing self).
class MhpVisitorConnectBookingTab extends StatefulWidget {
  final String mhpUserId;
  final String? mhpDisplayName;
  /// Raw `picture_path` from MHP profile (CDN path or URL); optional for checkout avatar.
  final String? mhpPicturePath;

  const MhpVisitorConnectBookingTab({
    super.key,
    required this.mhpUserId,
    this.mhpDisplayName,
    this.mhpPicturePath,
  });

  @override
  State<MhpVisitorConnectBookingTab> createState() =>
      _MhpVisitorConnectBookingTabState();
}

class _MhpVisitorConnectBookingTabState extends State<MhpVisitorConnectBookingTab> {
  late DateTime _selectedDate;
  /// Sunday YYYY-MM-DD of the visible week (IST civil calendar, matches API `week_start`).
  late String _weekStartIstYmd;

  String _preference = 'Video';
  String? _selectedOfferId;
  int? _durationMinutes;
  ConnectSlotOption? _selectedSlot;

  List<ConnectOfferOption> _offers = [];
  ConnectAvailabilityResult? _availability;

  bool _loadingOffers = true;
  bool _loadingAvailability = false;
  bool _submittingHold = false;
  String? _loadError;

  static const _prefs = ['Video', 'Call', 'In-Person'];

  ConnectBookingRemoteDataSource get _api => sl<ConnectBookingRemoteDataSource>();

  ConnectOfferOption? get _selectedOffer {
    final id = _selectedOfferId;
    if (id == null) return null;
    for (final o in _offers) {
      if (o.offerId == id) return o;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _weekStartIstYmd = connectIstWeekStartSundayYmdFromLocalDay(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOffers());
  }

  List<DateTime> _daysInVisibleWeek() {
    final start = connectParseYmdLocal(_weekStartIstYmd);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  bool _isPastDay(DateTime d) {
    final t = DateTime.now();
    final today = DateTime(t.year, t.month, t.day);
    return d.isBefore(today);
  }

  bool _canGoToPreviousWeek() {
    final prevStart = connectParseYmdLocal(_weekStartIstYmd).subtract(const Duration(days: 7));
    final prevEnd = prevStart.add(const Duration(days: 6));
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return !prevEnd.isBefore(today);
  }

  String _weekStartKey() => _weekStartIstYmd;

  Future<void> _loadOffers() async {
    setState(() {
      _loadingOffers = true;
      _loadError = null;
    });
    try {
      final list = await _api.getOffers(widget.mhpUserId.trim());
      if (!mounted) return;
      String? firstId;
      if (list.isNotEmpty) {
        firstId = list.first.offerId;
      }
      setState(() {
        _offers = list;
        _selectedOfferId = firstId;
        _loadingOffers = false;
        _syncDurationAfterOfferOrPrefChange();
      });
      await _refreshAvailability();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingOffers = false;
        _loadError = e.toString();
      });
    }
  }

  void _syncDurationAfterOfferOrPrefChange() {
    final durs = _durationsForOffer(_selectedOffer, _preference);
    if (durs.isEmpty) {
      _durationMinutes = null;
      return;
    }
    final cur = _durationMinutes;
    if (cur == null || !durs.contains(cur)) {
      _durationMinutes = durs.first;
    }
  }

  Future<void> _refreshAvailability() async {
    final offer = _selectedOffer;
    final dur = _durationMinutes;
    if (offer == null || dur == null) {
      setState(() => _availability = null);
      return;
    }
    setState(() {
      _loadingAvailability = true;
      _selectedSlot = null;
    });
    try {
      final result = await _api.getAvailability(
        mhpUserId: widget.mhpUserId.trim(),
        weekStartYyyyMmDd: _weekStartKey(),
        therapyOfferId: offer.offerId,
        durationMinutes: dur,
        preferenceApi: connectPreferenceUiToApi(_preference),
      );
      if (!mounted) return;
      setState(() {
        _availability = result;
        _loadingAvailability = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingAvailability = false;
        _availability = null;
      });
      Get.snackbar(
        'Availability',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  void _shiftWeek(int delta) {
    setState(() {
      final idx = connectDayIndexInIstWeek(_selectedDate, _weekStartIstYmd).clamp(0, 6);
      final start = connectParseYmdLocal(_weekStartIstYmd);
      final newStart = start.add(Duration(days: 7 * delta));
      _weekStartIstYmd = connectFormatYmd(newStart);
      var newSelected = newStart.add(Duration(days: idx));
      if (_isPastDay(newSelected)) {
        final days = _daysInVisibleWeek();
        final future = days.where((d) => !_isPastDay(d)).toList();
        newSelected = future.isNotEmpty ? future.first : newSelected;
      }
      _selectedDate = newSelected;
      _selectedSlot = null;
    });
    _refreshAvailability();
  }

  List<ConnectSlotOption> _slotsForSelectedDay() {
    if (_isPastDay(_selectedDate)) return [];
    final av = _availability;
    if (av == null) return [];
    return av.slotsForSelection(selectedLocalDay: _selectedDate);
  }

  int? _feeInrForSelection() {
    final o = _selectedOffer;
    final dur = _durationMinutes;
    if (o == null || dur == null) return null;
    final api = connectPreferenceUiToApi(_preference);
    for (final m in o.sessionModes) {
      if (m.mode.toLowerCase() == api && m.durationMinutes == dur) {
        return m.feeInr;
      }
    }
    return null;
  }

  String _summaryDateShort() => DateFormat('d MMM').format(_selectedDate);

  String _summaryLine1() {
    final therapy = _selectedOffer?.label ?? '—';
    final p = _preference;
    final d = _durationMinutes != null ? '$_durationMinutes min' : '—';
    return '$therapy · ${_summaryDateShort()} · $p · $d';
  }

  String _summaryLine2() {
    if (_selectedSlot == null) return 'Pick a time slot';
    return _selectedSlot!.label;
  }

  Future<void> _onLetsConnect() async {
    final slot = _selectedSlot;
    final offer = _selectedOffer;
    final dur = _durationMinutes;
    if (slot == null || offer == null || dur == null) return;

    setState(() => _submittingHold = true);
    try {
      final hold = await _api.createHold(
        mhpUserId: widget.mhpUserId.trim(),
        therapyOfferId: offer.offerId,
        therapyTypeId: offer.therapyTypeId.isNotEmpty ? offer.therapyTypeId : null,
        preferenceApi: connectPreferenceUiToApi(_preference),
        durationMinutes: dur,
        startAtRfc3339: slot.startAt,
      );
      if (!mounted) return;
      setState(() => _submittingHold = false);
      Get.toNamed(
        AppRoutes.sessionPayment,
        arguments: {
          'mhpUserId': widget.mhpUserId.trim(),
          'mhpDisplayName': widget.mhpDisplayName ?? 'Professional',
          'mhpPicturePath': widget.mhpPicturePath,
          'date': _selectedDate.toIso8601String(),
          'preference': _preference,
          'duration': '$dur min',
          'slot': slot.label,
          'startAt': slot.startAt,
          'bookingId': hold.bookingId,
          'paymentHoldExpiresAt': hold.paymentHoldExpiresAt?.toIso8601String(),
          'feeInr': _feeInrForSelection(),
          'therapyLabel': offer.label,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submittingHold = false);
      Get.snackbar(
        'Booking',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingOffers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: _purple),
        ),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Lexend', color: Colors.grey.shade800),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadOffers,
                style: FilledButton.styleFrom(backgroundColor: _purple),
                child: const Text('Retry', style: TextStyle(fontFamily: 'Lexend')),
              ),
            ],
          ),
        ),
      );
    }

    if (_offers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'This professional has not published any therapy offers yet. Check back later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lexend',
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    final slots = _slotsForSelectedDay();
    final durs = _durationsForOffer(_selectedOffer, _preference);
    final canConnect = _selectedSlot != null &&
        !_isPastDay(_selectedDate) &&
        !_submittingHold &&
        durs.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _dateHeaderRow(),
                const SizedBox(height: 12),
                _weekStrip(),
                const SizedBox(height: 28),
                _sectionTitle('Therapy type'),
                const SizedBox(height: 8),
                Text(
                  'Choose the session package. Duration and fees follow the offer.',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 12,
                    height: 1.35,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                _therapyOffersWrap(),
                const SizedBox(height: 28),
                _sectionTitle('Preference'),
                const SizedBox(height: 6),
                Text(
                  _preference == 'Video'
                      ? 'You’ll get a link or details before your video session.'
                      : _preference == 'Call'
                          ? 'You’ll receive call details before your session.'
                          : 'Meeting location or address will be shared after booking.',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 12,
                    height: 1.35,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                _preferenceRow(),
                const SizedBox(height: 28),
                _sectionTitle('Duration'),
                const SizedBox(height: 12),
                if (durs.isEmpty)
                  Text(
                    'No ${_preference.toLowerCase()} slots in this offer. Try another therapy type or preference.',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 13,
                      color: Colors.orange.shade800,
                    ),
                  )
                else
                  _durationWrap(durs),
                const SizedBox(height: 28),
                _sectionTitle('Available slots'),
                const SizedBox(height: 8),
                if (_loadingAvailability)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _purple),
                      ),
                    ),
                  )
                else if (durs.isEmpty)
                  const SizedBox.shrink()
                else if (slots.isEmpty)
                  _emptySlotsState()
                else
                  _slotsWrap(slots),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _stickySummaryBar(enabled: canConnect),
      ],
    );
  }

  Widget _therapyOffersWrap() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _offers.map((o) {
        final sel = _selectedOfferId == o.offerId;
        return _choiceChip(
          label: o.label,
          selected: sel,
          onTap: () {
            setState(() {
              _selectedOfferId = o.offerId;
              _syncDurationAfterOfferOrPrefChange();
              _selectedSlot = null;
            });
            _refreshAvailability();
          },
        );
      }).toList(),
    );
  }

  Widget _dateHeaderRow() {
    final formatted = DateFormat('d MMMM, y').format(_selectedDate);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            formatted,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: _titleSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
        ),
        IconButton(
          onPressed: _canGoToPreviousWeek() ? () => _shiftWeek(-1) : null,
          icon: Icon(
            Icons.chevron_left,
            color: _canGoToPreviousWeek()
                ? Colors.black87
                : Colors.grey.shade400,
          ),
        ),
        IconButton(
          onPressed: () => _shiftWeek(1),
          icon: const Icon(Icons.chevron_right, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _weekStrip() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final days = _daysInVisibleWeek();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map(
                (l) => SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      l,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((d) {
            final selected = d.year == _selectedDate.year &&
                d.month == _selectedDate.month &&
                d.day == _selectedDate.day;
            final past = _isPastDay(d);
            return GestureDetector(
              onTap: past
                  ? null
                  : () {
                      setState(() {
                        _selectedDate = d;
                        _selectedSlot = null;
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: past
                      ? Colors.grey.shade200
                      : selected
                          ? _purple
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: past
                        ? Colors.grey.shade300
                        : selected
                            ? _purple
                            : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  '${d.day}',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: past
                        ? Colors.grey.shade500
                        : selected
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(
        fontFamily: 'Lexend',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _preferenceRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _prefs.map((p) {
        final sel = _preference == p;
        IconData icon;
        if (p == 'Video') {
          icon = Icons.videocam_outlined;
        } else if (p == 'Call') {
          icon = Icons.call_outlined;
        } else {
          icon = Icons.location_on_outlined;
        }
        return _choiceChip(
          label: p,
          icon: icon,
          selected: sel,
          onTap: () {
            setState(() {
              _preference = p;
              _syncDurationAfterOfferOrPrefChange();
              _selectedSlot = null;
            });
            _refreshAvailability();
          },
        );
      }).toList(),
    );
  }

  Widget _durationWrap(List<int> durs) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: durs.map((m) {
        return _choiceChip(
          label: '$m min',
          selected: _durationMinutes == m,
          onTap: () {
            setState(() => _durationMinutes = m);
            _refreshAvailability();
          },
        );
      }).toList(),
    );
  }

  Widget _slotsWrap(List<ConnectSlotOption> slots) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((s) {
        final sel = _selectedSlot?.startAt == s.startAt;
        return _choiceChip(
          label: s.label,
          selected: sel,
          onTap: () => setState(() => _selectedSlot = s),
        );
      }).toList(),
    );
  }

  Widget _emptySlotsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_busy, color: Colors.grey.shade600, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No slots this day',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Try another day in this week or use the arrows to check the next week.',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 13,
              height: 1.35,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: icon != null ? 14 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected ? _purple : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _purple : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stickySummaryBar({required bool enabled}) {
    final busy = _submittingHold;
    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _summaryLine1(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _summaryLine2(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (enabled && !busy) ? _onLetsConnect : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _purple,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Let's connect",
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
