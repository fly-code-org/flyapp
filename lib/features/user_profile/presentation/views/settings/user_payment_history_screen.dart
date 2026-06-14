import 'package:flutter/material.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/user_profile/data/services/user_settings_remote_data_source.dart';

const _purple = Color(0xFF6C4EE4);

class _PaymentItem {
  final String id;
  final String mhpName;
  final String specialty;
  final DateTime sessionDate;
  final int amountINR;
  final String status;

  _PaymentItem({
    required this.id,
    required this.mhpName,
    required this.specialty,
    required this.sessionDate,
    required this.amountINR,
    required this.status,
  });

  factory _PaymentItem.fromMap(Map<String, dynamic> m) => _PaymentItem(
        id: m['id']?.toString() ?? '',
        mhpName: m['mhp_name']?.toString() ?? 'MHP',
        specialty: m['specialty']?.toString() ?? '',
        sessionDate:
            DateTime.tryParse(m['session_date']?.toString() ?? '') ?? DateTime.now(),
        amountINR: (m['amount_inr'] as num?)?.toInt() ?? 0,
        status: m['status']?.toString() ?? 'pending',
      );
}

class UserPaymentHistoryScreen extends StatefulWidget {
  const UserPaymentHistoryScreen({super.key});

  @override
  State<UserPaymentHistoryScreen> createState() =>
      _UserPaymentHistoryScreenState();
}

class _UserPaymentHistoryScreenState extends State<UserPaymentHistoryScreen> {
  final _ds = UserSettingsRemoteDataSource();

  int _totalSpentINR = 0;
  int _sessionsBooked = 0;
  List<_PaymentItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _ds.getPaymentHistory();
      _totalSpentINR = (data['total_spent_inr'] as num?)?.toInt() ?? 0;
      _sessionsBooked = (data['sessions_booked'] as num?)?.toInt() ?? 0;
      final rawItems = data['items'];
      if (rawItems is List) {
        _items = rawItems
            .whereType<Map<String, dynamic>>()
            .map(_PaymentItem.fromMap)
            .toList();
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Map<String, List<_PaymentItem>> get _grouped {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final m = <String, List<_PaymentItem>>{};
    for (final item in _items) {
      final key = months[item.sessionDate.month - 1];
      (m[key] ??= []).add(item);
    }
    return m;
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]}${d.day}${d.year}';
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
          title: const Text('Payment history',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Expanded(child: _statCard('Total Spent', '₹ $_totalSpentINR')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _statCard(
                                'Sessions booked', '$_sessionsBooked')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _items.isEmpty
                        ? const Center(
                            child: Text('No payment history',
                                style: TextStyle(color: Colors.black45)))
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: _grouped.entries
                                .expand((e) => [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Text(e.key,
                                            style: const TextStyle(
                                                color: Colors.black45,
                                                fontSize: 13)),
                                      ),
                                      ...e.value.map(_paymentRow),
                                    ])
                                .toList(),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _statCard(String label, String value) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EFFF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: _purple, fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _paymentRow(_PaymentItem item) {
    Color statusColor;
    switch (item.status) {
      case 'paid':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }
    final statusLabel = item.status[0].toUpperCase() + item.status.substring(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Session with ${item.mhpName}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      '${item.specialty.isNotEmpty ? '${item.specialty} · ' : ''}${_formatDate(item.sessionDate)}',
                      style: const TextStyle(
                          color: Colors.black45, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹ ${item.amountINR}',
                      style: const TextStyle(
                          color: _purple,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            color: statusColor, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
