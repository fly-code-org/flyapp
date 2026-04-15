// DTOs for fly-be connect module (`connect/external/v1`).

import 'package:intl/intl.dart';

// --- IST calendar (API `week_start` / `days[].date` use Asia/Kolkata civil dates) ---

const Duration _connectIstOffset = Duration(hours: 5, minutes: 30);

String connectFormatYmd(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime connectParseYmdLocal(String ymd) {
  final p = ymd.split('-');
  if (p.length != 3) return DateTime(1970);
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

DateTime _utcDateOnly(int y, int m, int d) => DateTime.utc(y, m, d);

/// IST calendar YYYY-MM-DD for a day the user picked (device-local civil date).
String connectIstYmdFromLocalDay(DateTime localDay) {
  final localMidnight = DateTime(localDay.year, localDay.month, localDay.day);
  final utc = localMidnight.toUtc();
  final istWallAsUtc = DateTime.fromMillisecondsSinceEpoch(
    utc.millisecondsSinceEpoch + _connectIstOffset.inMilliseconds,
    isUtc: true,
  );
  return connectFormatYmd(istWallAsUtc);
}

String connectIstWeekStartSundayYmdFromIstYmd(String istYmd) {
  final p = istYmd.split('-');
  if (p.length != 3) return istYmd;
  final u = _utcDateOnly(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  final w = u.weekday % 7;
  final sun = u.subtract(Duration(days: w));
  return connectFormatYmd(sun);
}

String connectIstWeekStartSundayYmdFromLocalDay(DateTime localDay) =>
    connectIstWeekStartSundayYmdFromIstYmd(connectIstYmdFromLocalDay(localDay));

int connectDayIndexInIstWeek(DateTime localDay, String istWeekStartYmd) {
  final istYmd = connectIstYmdFromLocalDay(localDay);
  final a = connectParseYmdLocal(istYmd);
  final b = connectParseYmdLocal(istWeekStartYmd);
  return a.difference(b).inDays;
}

String? connectCanonicalWeekdayShort(String raw) {
  final k = raw.trim().toLowerCase();
  switch (k) {
    case 'sun':
    case 'sunday':
      return 'Sun';
    case 'mon':
    case 'monday':
      return 'Mon';
    case 'tue':
    case 'tues':
    case 'tuesday':
      return 'Tue';
    case 'wed':
    case 'weds':
    case 'wednesday':
      return 'Wed';
    case 'thu':
    case 'thur':
    case 'thurs':
    case 'thursday':
      return 'Thu';
    case 'fri':
    case 'friday':
      return 'Fri';
    case 'sat':
    case 'saturday':
      return 'Sat';
  }
  if (k.length >= 3) {
    switch (k.substring(0, 3)) {
      case 'sun':
        return 'Sun';
      case 'mon':
        return 'Mon';
      case 'tue':
        return 'Tue';
      case 'wed':
        return 'Wed';
      case 'thu':
        return 'Thu';
      case 'fri':
        return 'Fri';
      case 'sat':
        return 'Sat';
    }
  }
  return null;
}

class ConnectSessionMode {
  final String mode;
  final int durationMinutes;
  final int feeInr;

  const ConnectSessionMode({
    required this.mode,
    required this.durationMinutes,
    required this.feeInr,
  });

  static ConnectSessionMode? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final mode = (json['mode'] ?? '').toString().trim();
    final dur = json['duration_minutes'];
    final fee = json['fee_inr'];
    final d = dur is int ? dur : int.tryParse('$dur') ?? 0;
    final f = fee is int ? fee : int.tryParse('$fee') ?? 0;
    if (mode.isEmpty || d <= 0) return null;
    return ConnectSessionMode(mode: mode, durationMinutes: d, feeInr: f);
  }
}

class ConnectOfferOption {
  final String offerId;
  final String therapyTypeId;
  final String label;
  final List<ConnectSessionMode> sessionModes;

  const ConnectOfferOption({
    required this.offerId,
    required this.therapyTypeId,
    required this.label,
    required this.sessionModes,
  });

  static ConnectOfferOption? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final id = (json['offer_id'] ?? json['offerId'] ?? '').toString().trim();
    if (id.isEmpty) return null;
    final tt = (json['therapy_type_id'] ?? json['therapyTypeId'] ?? '').toString();
    final label = (json['label'] ?? '').toString().trim();
    final rawModes = json['session_modes'] ?? json['sessionModes'];
    final modes = <ConnectSessionMode>[];
    if (rawModes is List) {
      for (final e in rawModes) {
        final m = ConnectSessionMode.fromJson(e);
        if (m != null) modes.add(m);
      }
    }
    return ConnectOfferOption(
      offerId: id,
      therapyTypeId: tt,
      label: label.isEmpty ? 'Therapy session' : label,
      sessionModes: modes,
    );
  }
}

class ConnectSlotOption {
  final String startAt;
  final String label;

  const ConnectSlotOption({required this.startAt, required this.label});

  static ConnectSlotOption? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final start = (json['start_at'] ?? json['startAt'] ?? '').toString().trim();
    final label = (json['label'] ?? '').toString().trim();
    if (start.isEmpty) return null;
    return ConnectSlotOption(
      startAt: start,
      label: label.isEmpty ? start : label,
    );
  }
}

class ConnectDayAvailability {
  final String date;
  final String weekday;
  final List<ConnectSlotOption> slots;

  const ConnectDayAvailability({
    required this.date,
    required this.weekday,
    required this.slots,
  });

  static ConnectDayAvailability? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final date = (json['date'] ?? '').toString().trim();
    if (date.isEmpty) return null;
    final wd = (json['weekday'] ?? '').toString();
    final raw = json['slots'];
    final slots = <ConnectSlotOption>[];
    if (raw is List) {
      for (final e in raw) {
        final s = ConnectSlotOption.fromJson(e);
        if (s != null) slots.add(s);
      }
    }
    return ConnectDayAvailability(date: date, weekday: wd, slots: slots);
  }
}

class ConnectAvailabilityResult {
  final bool hasAvailability;
  final String timezone;
  final List<ConnectDayAvailability> days;

  const ConnectAvailabilityResult({
    required this.hasAvailability,
    required this.timezone,
    required this.days,
  });

  static ConnectAvailabilityResult fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return const ConnectAvailabilityResult(
        hasAvailability: false,
        timezone: 'Asia/Kolkata',
        days: [],
      );
    }
    final has = json['has_availability'] == true;
    final tz = (json['timezone'] ?? 'Asia/Kolkata').toString();
    final rawDays = json['days'];
    final days = <ConnectDayAvailability>[];
    if (rawDays is List) {
      for (final e in rawDays) {
        final d = ConnectDayAvailability.fromJson(e);
        if (d != null) days.add(d);
      }
    }
    return ConnectAvailabilityResult(
      hasAvailability: has,
      timezone: tz,
      days: days,
    );
  }

  List<ConnectSlotOption> slotsForDateKey(String yyyyMmDd) {
    for (final d in days) {
      if (d.date == yyyyMmDd) return d.slots;
    }
    return const [];
  }

  /// Resolves slots for the picked day using IST `days[].date` first, then weekday
  /// (covers device-local vs IST calendar mismatch).
  List<ConnectSlotOption> slotsForSelection({required DateTime selectedLocalDay}) {
    final keyIst = connectIstYmdFromLocalDay(selectedLocalDay);
    for (final d in days) {
      if (d.date == keyIst) return d.slots;
    }
    final wd = DateFormat('EEE', 'en_US').format(selectedLocalDay);
    final c1 = connectCanonicalWeekdayShort(wd);
    if (c1 != null) {
      for (final d in days) {
        final c2 = connectCanonicalWeekdayShort(d.weekday);
        if (c2 == c1) return d.slots;
      }
    }
    return const [];
  }
}

class ConnectHoldResult {
  final String bookingId;
  final bool isPaid;
  final String status;
  final DateTime? paymentHoldExpiresAt;
  final String? meetLink;

  const ConnectHoldResult({
    required this.bookingId,
    required this.isPaid,
    required this.status,
    this.paymentHoldExpiresAt,
    this.meetLink,
  });

  static ConnectHoldResult fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid hold response');
    }
    final id = (json['booking_id'] ?? json['bookingId'] ?? '').toString();
    if (id.isEmpty) throw const FormatException('Missing booking_id');
    final paid = json['is_paid'] == true || json['isPaid'] == true;
    final st = (json['status'] ?? '').toString();
    DateTime? exp;
    final rawExp = json['payment_hold_expires_at'] ?? json['paymentHoldExpiresAt'];
    if (rawExp is String && rawExp.isNotEmpty) {
      exp = DateTime.tryParse(rawExp);
    }
    final meet = json['meet_link'] ?? json['meetLink'];
    final meetStr = meet is String && meet.isNotEmpty ? meet : null;
    return ConnectHoldResult(
      bookingId: id,
      isPaid: paid,
      status: st,
      paymentHoldExpiresAt: exp,
      meetLink: meetStr,
    );
  }
}

/// Response from `POST .../bookings/:id/razorpay-order` (opens Razorpay Checkout).
class ConnectPreparePaymentResult {
  final String keyId;
  final String orderId;
  final int amountPaise;
  final String currency;

  const ConnectPreparePaymentResult({
    required this.keyId,
    required this.orderId,
    required this.amountPaise,
    required this.currency,
  });

  static ConnectPreparePaymentResult? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final key = (json['key_id'] ?? json['keyId'] ?? '').toString().trim();
    final order = (json['order_id'] ?? json['orderId'] ?? '').toString().trim();
    final cur = (json['currency'] ?? 'INR').toString().trim();
    final rawAmt = json['amount'];
    final amt = rawAmt is int ? rawAmt : int.tryParse('$rawAmt') ?? 0;
    if (key.isEmpty || order.isEmpty || amt <= 0) return null;
    return ConnectPreparePaymentResult(
      keyId: key,
      orderId: order,
      amountPaise: amt,
      currency: cur.isEmpty ? 'INR' : cur,
    );
  }
}

class ConnectConfirmResult {
  final String bookingId;
  final bool isPaid;
  final String status;
  final String? meetLink;
  /// Video session only: backend set when Meet could not be created after successful payment.
  final bool meetGenerationFailed;
  /// Short support code (e.g. `google_token`, `calendar_api`); null if not failed or old API.
  final String? meetGenerationCode;

  const ConnectConfirmResult({
    required this.bookingId,
    required this.isPaid,
    required this.status,
    this.meetLink,
    this.meetGenerationFailed = false,
    this.meetGenerationCode,
  });

  static ConnectConfirmResult fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid confirm response');
    }
    final id = (json['booking_id'] ?? json['bookingId'] ?? '').toString();
    if (id.isEmpty) throw const FormatException('Missing booking_id');
    final paid = json['is_paid'] == true || json['isPaid'] == true;
    final st = (json['status'] ?? '').toString();
    final meet = json['meet_link'] ?? json['meetLink'];
    final meetStr = meet is String && meet.isNotEmpty ? meet : null;
    final meetGenFailed =
        json['meet_generation_failed'] == true || json['meetGenerationFailed'] == true;
    final codeRaw = json['meet_generation_code'] ?? json['meetGenerationCode'];
    final codeStr = codeRaw is String && codeRaw.trim().isNotEmpty
        ? codeRaw.trim()
        : null;
    return ConnectConfirmResult(
      bookingId: id,
      isPaid: paid,
      status: st,
      meetLink: meetStr,
      meetGenerationFailed: meetGenFailed,
      meetGenerationCode: codeStr,
    );
  }
}
