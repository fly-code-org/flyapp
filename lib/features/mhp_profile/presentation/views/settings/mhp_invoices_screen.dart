import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);
const _purpleLight = Color(0xFFEDE9FB);

class _InvoiceItem {
  final String id;
  final String seekerName;
  final String sessionKind;
  final int amountINR;
  final int durationMinutes;
  final DateTime sessionDate;
  final String paymentId;
  final String status;

  _InvoiceItem({
    required this.id,
    required this.seekerName,
    required this.sessionKind,
    required this.amountINR,
    required this.durationMinutes,
    required this.sessionDate,
    required this.paymentId,
    required this.status,
  });

  factory _InvoiceItem.fromMap(Map<String, dynamic> m) {
    return _InvoiceItem(
      id: m['id']?.toString() ?? '',
      seekerName: m['seeker_name']?.toString() ?? 'Unknown',
      sessionKind: m['session_kind']?.toString() ?? '',
      amountINR: (m['amount_inr'] as int?) ?? 0,
      durationMinutes: (m['duration_minutes'] as int?) ?? 50,
      sessionDate: DateTime.tryParse(m['session_date']?.toString() ?? '') ??
          DateTime.now(),
      paymentId: m['payment_id']?.toString() ?? '',
      status: m['status']?.toString() ?? 'paid',
    );
  }
}

class MhpInvoicesScreen extends StatefulWidget {
  const MhpInvoicesScreen({super.key});

  @override
  State<MhpInvoicesScreen> createState() => _MhpInvoicesScreenState();
}

class _MhpInvoicesScreenState extends State<MhpInvoicesScreen> {
  final _ds = MhpProfileRemoteDataSourceImpl();

  int _totalEarned = 0;
  int _thisMonth = 0;
  List<_InvoiceItem> _items = [];
  bool _loading = true;
  _InvoiceItem? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _ds.getInvoices();
      _totalEarned = (data['total_earned_inr'] as int?) ?? 0;
      _thisMonth = (data['this_month_inr'] as int?) ?? 0;
      final rawItems = data['items'];
      if (rawItems is List) {
        _items = rawItems
            .whereType<Map<String, dynamic>>()
            .map(_InvoiceItem.fromMap)
            .toList();
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Map<int, List<_InvoiceItem>> get _grouped {
    final m = <int, List<_InvoiceItem>>{};
    for (final item in _items) {
      final y = item.sessionDate.year;
      (m[y] ??= []).add(item);
    }
    return Map.fromEntries(
        m.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return _invoiceDetail(context, _selected!);
    }
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
          title: const Text('Invoices / Payout History',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Expanded(child: _statCard('Total Earned', _totalEarned)),
                        const SizedBox(width: 12),
                        Expanded(child: _statCard('This Month', _thisMonth)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _purpleLight,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text('All',
                            style: TextStyle(
                                color: _purple, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _items.isEmpty
                        ? const Center(
                            child: Text('No invoices yet',
                                style: TextStyle(color: Colors.black45)))
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: _grouped.entries
                                .expand((e) => [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Text(e.key.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14)),
                                      ),
                                      ...e.value.map(_invoiceRow),
                                    ])
                                .toList(),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _statCard(String label, int amount) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
            const SizedBox(height: 4),
            Text('₹$amount',
                style: const TextStyle(
                    color: _purple, fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _invoiceRow(_InvoiceItem item) {
    final date = _formatDate(item.sessionDate);
    return GestureDetector(
      onTap: () => setState(() => _selected = item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session with - ${item.seekerName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    '${item.sessionKind.isNotEmpty ? '${item.sessionKind.capitalize()} · ' : ''}$date · ${item.durationMinutes} mins',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${item.amountINR}',
                    style: const TextStyle(
                        color: _purple, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    item.status.capitalize(),
                    style: const TextStyle(color: Colors.green, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceDetail(BuildContext context, _InvoiceItem item) {
    return SafePopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () => setState(() => _selected = null),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFF2F2F2)),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),
          title: const Text('Invoices / Payout History',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.description_outlined,
                          size: 80, color: Color(0xFFD0D0D0)),
                      Positioned(
                        right: 90,
                        bottom: 40,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFF66BB6A),
                          child: Icon(Icons.check, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Invoice paid',
                  style: TextStyle(color: Colors.black54, fontSize: 14)),
              const SizedBox(height: 8),
              Text('₹${item.amountINR}',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('View invoice and payment details',
                        style: TextStyle(color: Colors.black54, fontSize: 13)),
                    Icon(Icons.chevron_right, color: Colors.black54, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _detailRow('Invoice number',
                  item.id.length > 12 ? '${item.id.substring(0, 12)}...' : item.id),
              _detailRow('Payment date', _formatDateLong(item.sessionDate)),
              _detailRow('Payment method',
                  item.paymentId.isNotEmpty ? 'UPI  ···· ${item.paymentId.length > 6 ? item.paymentId.substring(item.paymentId.length - 6) : item.paymentId}' : 'UPI'),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _downloadBtn('Download invoice'),
                  _downloadBtn('Download receipt'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            Text(value,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      );

  Widget _downloadBtn(String label) => GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.download_outlined, size: 16, color: Colors.black87),
          ],
        ),
      );

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day}${months[d.month - 1]}${d.year}';
  }

  String _formatDateLong(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
