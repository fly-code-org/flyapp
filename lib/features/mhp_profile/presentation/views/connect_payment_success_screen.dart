import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/mhp_profile/data/datasources/connect_booking_remote_data_source.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _backHomePurple = Color(0xFF3B16A7);

String _connectMeetFailureCopy(String? code) {
  switch (code) {
    case 'google_auth_missing':
      return 'Your professional may need to connect Google Calendar in Fly before video links work. Your payment went through—support can help.';
    case 'google_token':
      return 'We could not use the calendar connection (token). Your payment was successful—contact support with the code below.';
    case 'calendar_api':
      return 'Google Calendar was unavailable when creating the meeting. Your payment was successful—try again later or contact support.';
    case 'meet_response':
      return 'Google did not return a meeting link. Your payment was successful—contact support with the code below.';
    case 'no_meet_link':
      return 'A video link could not be created. Your payment was successful—contact support with the code below.';
    case 'server_config':
      return 'Something is misconfigured on our side. Your payment was successful—contact support with the code below.';
    default:
      return 'We could not create your video meeting link. Your payment was successful—contact support with your reference and the code below.';
  }
}

/// Ticket clip: rounded rectangle with semicircular bites on left/right at [notchCenterFromTop].
/// Cuts reveal the background (not filled white).
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({
    this.notchCenterFromTop = 158,
    this.notchRadius = 10,
    this.cornerRadius = 16,
  });

  final double notchCenterFromTop;
  final double notchRadius;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final cy = notchCenterFromTop.clamp(
      notchRadius + cornerRadius + 2,
      h - notchRadius - cornerRadius - 2,
    );

    final main = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, w, h),
          topLeft: Radius.circular(cornerRadius),
          topRight: Radius.circular(cornerRadius),
          bottomLeft: Radius.circular(cornerRadius),
          bottomRight: Radius.circular(cornerRadius),
        ),
      );

    final leftBite = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, cy), radius: notchRadius));
    final rightBite = Path()
      ..addOval(Rect.fromCircle(center: Offset(w, cy), radius: notchRadius));

    var out = Path.combine(PathOperation.difference, main, leftBite);
    out = Path.combine(PathOperation.difference, out, rightBite);
    return out;
  }

  @override
  bool shouldReclip(covariant _TicketClipper oldClipper) =>
      oldClipper.notchCenterFromTop != notchCenterFromTop ||
      oldClipper.notchRadius != notchRadius ||
      oldClipper.cornerRadius != cornerRadius;
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({this.color = const Color(0xFFBDBDBD)});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const dash = 7.0;
    const gap = 5.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      final end = math.min(x + dash, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PulsingCheck extends StatefulWidget {
  const _PulsingCheck();

  @override
  State<_PulsingCheck> createState() => _PulsingCheckState();
}

class _PulsingCheckState extends State<_PulsingCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_c.value);
        final blur = 6.0 + t * 14.0;
        final spread = t * 3.0;
        final opacity = 0.35 + t * 0.25;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: opacity),
                blurRadius: blur,
                spreadRadius: spread,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF2E7D32),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
      ),
    );
  }
}

class ConnectPaymentSuccessScreen extends StatelessWidget {
  const ConnectPaymentSuccessScreen({super.key});

  Map<String, dynamic> get _args =>
      Map<String, dynamic>.from(Get.arguments as Map? ?? {});

  bool get _meetGenerationFailed => _args['meetGenerationFailed'] == true;

  String? get _meetGenerationCode {
    final c = _args['meetGenerationCode'];
    return c is String && c.trim().isNotEmpty ? c.trim() : null;
  }

  String _referenceLabel() {
    final pay = (_args['razorpayPaymentId'] as String?)?.trim();
    if (pay != null && pay.isNotEmpty) return pay;
    final bid = _args['bookingId'];
    if (bid == null) return '—';
    return bid.toString();
  }

  DateTime? _paidAt() {
    final s = _args['paidAt'] as String?;
    if (s == null || s.isEmpty) return DateTime.now();
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  void _closeLoadingDialogIfOpen() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  String? _serverMessageIfJsonBody(Uint8List bytes) {
    final text = utf8.decode(bytes, allowMalformed: true).trimLeft();
    if (!text.startsWith('{')) return null;
    try {
      final dynamic obj = jsonDecode(text);
      if (obj is Map<String, dynamic>) {
        final msg = obj['msg'];
        if (msg is String && msg.isNotEmpty) return msg;
        final err = obj['error'];
        if (err is String && err.isNotEmpty) return err;
      }
    } catch (_) {}
    return 'Unexpected server response.';
  }

  void _assertPdfBytes(Uint8List bytes) {
    if (bytes.length < 5) {
      throw const FormatException('Receipt download was empty.');
    }
    final head = String.fromCharCodes(bytes.sublist(0, 5));
    if (head.startsWith('%PDF-')) return;
    final msg = _serverMessageIfJsonBody(bytes);
    throw FormatException(msg ?? 'Server did not return a PDF file.');
  }

  Future<void> _openLocalPdfFile({
    required String filePath,
    required String fileName,
  }) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.done) return;
      await Share.shareXFiles(
        [
          XFile(
            filePath,
            mimeType: 'application/pdf',
            name: fileName,
          ),
        ],
        subject: 'Fly payment receipt',
        text: 'Open or save your Fly payment receipt.',
      );
      return;
    }
    final opened = await launchUrl(
      Uri.file(filePath),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      throw Exception('Could not open the receipt file.');
    }
  }

  void _onClose(BuildContext context) {
    final mhpId = (_args['mhpUserId'] as String?)?.trim();
    if (mhpId != null && mhpId.isNotEmpty) {
      Get.offNamed(AppRoutes.mhpProfile, arguments: {'userId': mhpId});
    } else {
      Get.back();
    }
  }

  Future<void> _onShare(BuildContext shareButtonContext) async {
    final ref = _referenceLabel();
    final paid = _paidAt() ?? DateTime.now();
    final dateStr = DateFormat('d MMM y').format(paid.toLocal());
    final timeStr = DateFormat('h:mm a').format(paid.toLocal());
    final method = (_args['paymentMethod'] as String?)?.trim() ?? 'Razorpay';
    final amt = _args['amountInr'];
    final amountStr = amt is int
        ? '₹$amt'
        : (amt is num ? '₹${amt.toInt()}' : '—');
    final mhp = _args['mhpDisplayName'] as String? ?? 'Fly professional';
    final meet = (_args['meetLink'] as String?)?.trim();
    final meetFail = _args['meetGenerationFailed'] == true;
    final meetCode = _meetGenerationCode;

    final buf = StringBuffer()
      ..writeln('Fly — Payment successful')
      ..writeln('Reference: $ref')
      ..writeln('Date: $dateStr')
      ..writeln('Time: $timeStr')
      ..writeln('Payment method: $method')
      ..writeln('Amount: $amountStr')
      ..writeln('Session with: $mhp');
    if (meet != null && meet.isNotEmpty) {
      buf.writeln('Meet link: $meet');
    } else if (meetFail) {
      buf.writeln('Video link: not created — contact support');
      buf.writeln('Support code: ${meetCode ?? "unknown"}');
    }
    final text = buf.toString().trim();

    Rect? sharePositionOrigin;
    if (shareButtonContext.mounted) {
      try {
        final box = shareButtonContext.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final p = box.localToGlobal(Offset.zero);
          sharePositionOrigin = Rect.fromLTWH(
            p.dx,
            p.dy,
            box.size.width,
            box.size.height,
          );
        }
      } catch (_) {}
    }

    try {
      await Share.share(
        text,
        subject: 'Fly — Payment receipt',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (_) {
      try {
        await Share.share(text, sharePositionOrigin: sharePositionOrigin);
      } catch (e) {
        Get.snackbar(
          'Share',
          'Could not open share sheet. $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  Future<void> _onPdfReceipt() async {
    final bookingId = (_args['bookingId'] as String?)?.trim();
    if (bookingId == null || bookingId.isEmpty) {
      Get.snackbar(
        'Receipt',
        'Missing booking reference.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final ds = sl<ConnectBookingRemoteDataSource>();
      final receipt = await ds.getReceipt(bookingId);

      _closeLoadingDialogIfOpen();

      final redirectUrl = receipt.redirectUrl?.trim();
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        final uri = Uri.tryParse(redirectUrl);
        if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
          throw const FormatException('Invalid receipt URL');
        }
        final opened = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!opened) {
          throw Exception('Could not open receipt URL.');
        }
        return;
      }

      final bytes = receipt.pdfBytes;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Receipt file is empty.');
      }

      _assertPdfBytes(bytes);

      final fileName = 'fly-connect-receipt-$bookingId.pdf';
      final file = File('${Directory.systemTemp.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      await _openLocalPdfFile(filePath: file.path, fileName: fileName);
    } catch (e) {
      _closeLoadingDialogIfOpen();
      Get.snackbar(
        'Receipt',
        'Could not fetch receipt. $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _onHelp() {
    if (_meetGenerationFailed) {
      final code = _meetGenerationCode;
      Get.snackbar(
        'Video link',
        '${_connectMeetFailureCopy(code)} Code: ${code ?? "—"}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.deepOrange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 6),
      );
      return;
    }
    Get.snackbar(
      'Help',
      'Help center is coming soon. For urgent issues, contact support from Settings.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade800,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> _openMeetLink(String raw) async {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      Get.snackbar(
        'Link',
        'This link cannot be opened.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar(
        'Link',
        'Could not open the browser.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paid = _paidAt() ?? DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM y').format(paid.toLocal());
    final timeStr = DateFormat('h:mm a').format(paid.toLocal());
    final method = (_args['paymentMethod'] as String?)?.trim() ?? 'Razorpay';
    final amt = _args['amountInr'];
    final amountStr = amt is int
        ? '₹$amt'
        : (amt is num ? '₹${amt.toInt()}' : '—');
    final meet = (_args['meetLink'] as String?)?.trim();
    final meetFail = _meetGenerationFailed;
    final meetCode = _meetGenerationCode;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: SizedBox(
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Logo under the bar so it does not steal taps from close/share.
                        IgnorePointer(
                          child: Image.asset(
                            'assets/images/fly_logo.png',
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _GlassCircleButton(
                              onPressed: () => _onClose(context),
                              child: const Text(
                                '✕',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                            ),
                            Builder(
                              builder: (shareBtnCtx) => _GlassCircleButton(
                                onPressed: () => _onShare(shareBtnCtx),
                                child: const Icon(
                                  Icons.share_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PhysicalShape(
                          clipper: const _TicketClipper(
                            notchCenterFromTop: 158,
                            notchRadius: 10,
                            cornerRadius: 16,
                          ),
                          color: Colors.white,
                          elevation: 14,
                          shadowColor: Colors.black.withValues(alpha: 0.35),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Center(child: _PulsingCheck()),
                                const SizedBox(height: 18),
                                const Text(
                                  'Payment Success',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  height: 12,
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: _DashedLinePainter(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _ticketRow(
                                  'Reference Number',
                                  _referenceLabel(),
                                ),
                                _ticketRow('Date', dateStr),
                                _ticketRow('Time', timeStr),
                                _ticketRow('Payment Method', method),
                                _ticketRow('Amount', amountStr),
                                if (meet != null && meet.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () => _openMeetLink(meet),
                                      icon: Icon(
                                        Icons.videocam_outlined,
                                        color: Colors.deepPurple.shade700,
                                        size: 22,
                                      ),
                                      label: Text(
                                        'Open video link',
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.deepPurple.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                if (meetFail) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.amber.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color: Colors.amber.shade900,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Video link unavailable',
                                                style: TextStyle(
                                                  fontFamily: 'Lexend',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: Colors.amber.shade900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _connectMeetFailureCopy(meetCode),
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            fontSize: 12.5,
                                            height: 1.35,
                                            color: Colors.brown.shade800,
                                          ),
                                        ),
                                        if (meetCode != null) ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SelectableText(
                                                  'Code: $meetCode',
                                                  style: TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        Colors.brown.shade900,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                tooltip: 'Copy code',
                                                onPressed: () async {
                                                  await Clipboard.setData(
                                                    ClipboardData(
                                                      text: meetCode,
                                                    ),
                                                  );
                                                  Get.snackbar(
                                                    'Copied',
                                                    'Support code copied',
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey.shade800,
                                                    colorText: Colors.white,
                                                    margin:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.copy_rounded,
                                                  size: 20,
                                                  color: Colors.brown.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _onPdfReceipt,
                                  icon: Icon(
                                    Icons.download_outlined,
                                    color: Colors.grey.shade800,
                                    size: 22,
                                  ),
                                  label: const Text(
                                    'Get PDF Receipt',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _onHelp,
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 4,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.help_outline_rounded,
                                    color: Colors.white.withValues(alpha: 0.95),
                                    size: 26,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Trouble with your payment?',
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(
                                              alpha: 0.98,
                                            ),
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Let us know on help center now!',
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white.withValues(
                                              alpha: 0.75,
                                            ),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Get.offAllNamed(AppRoutes.Home),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: const Text(
                                'Back to Home',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _backHomePurple,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _ticketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }
}
