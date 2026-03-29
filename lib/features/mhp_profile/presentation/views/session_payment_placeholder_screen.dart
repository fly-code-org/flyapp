import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/mhp_profile/data/datasources/connect_booking_remote_data_source.dart';
import 'package:fly/features/mhp_profile/data/models/connect_booking_models.dart';
import 'package:fly/features/mhp_profile/presentation/views/connect_razorpay/connect_razorpay_checkout.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const _purple = Color(0xFF855DFC);
const _avatarSize = 72.0;

/// Checkout after a connect **hold**: Razorpay opens from **Continue** after order is prepared server-side.
class SessionPaymentPlaceholderScreen extends StatefulWidget {
  const SessionPaymentPlaceholderScreen({super.key});

  @override
  State<SessionPaymentPlaceholderScreen> createState() =>
      _SessionPaymentPlaceholderScreenState();
}

class _SessionPaymentPlaceholderScreenState
    extends State<SessionPaymentPlaceholderScreen> {
  final ConnectRazorpaySession _razorpay = ConnectRazorpaySession();
  final TextEditingController _couponController = TextEditingController();

  bool _loadingOrder = true;
  String? _orderError;
  ConnectPreparePaymentResult? _prepare;

  bool _checkoutOpen = false;
  bool _confirming = false;

  String? _bookingId;
  /// Coupon code shown in "Code applied" after Apply (server validation TBD).
  String? _appliedCouponCode;
  int _discountInr = 0;

  Map<String, dynamic> _args = {};

  @override
  void initState() {
    super.initState();
    _args = Map<String, dynamic>.from(Get.arguments as Map? ?? {});
    _razorpay.init(
      onSuccess: _onPaymentSuccess,
      onError: _onPaymentError,
    );
    _bookingId = (_args['bookingId'] as String?)?.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPaymentOrder());
  }

  @override
  void dispose() {
    _couponController.dispose();
    _razorpay.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentOrder() async {
    final id = _bookingId;
    if (id == null || id.isEmpty) {
      setState(() {
        _loadingOrder = false;
        _orderError = 'Missing booking reference.';
      });
      return;
    }
    setState(() {
      _loadingOrder = true;
      _orderError = null;
      _prepare = null;
    });
    try {
      final ds = sl<ConnectBookingRemoteDataSource>();
      final prep = await ds.prepareRazorpayOrder(id);
      if (!mounted) return;
      setState(() {
        _prepare = prep;
        _loadingOrder = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingOrder = false;
        _orderError = e.toString();
      });
    }
  }

  int _baseSessionInrFromArgs() {
    final feeInr = _args['feeInr'];
    if (feeInr is int && feeInr > 0) return feeInr;
    if (feeInr is num && feeInr > 0) return feeInr.toInt();
    return 0;
  }

  /// Amount charged matches the server order (authoritative once prepared).
  int get _singleSessionInr {
    if (_prepare != null) return _prepare!.amountPaise ~/ 100;
    return _baseSessionInrFromArgs();
  }

  int get _finalPayableInr =>
      (_singleSessionInr - _discountInr).clamp(0, 1 << 30);

  void _onApplyCoupon() {
    final raw = _couponController.text.trim();
    FocusScope.of(context).unfocus();
    setState(() {
      if (raw.isEmpty) {
        _appliedCouponCode = null;
        _discountInr = 0;
        return;
      }
      _appliedCouponCode = raw;
      // TODO: call coupon API; adjust _discountInr and recreate Razorpay order when backend supports it.
      _discountInr = 0;
    });
    if (raw.isNotEmpty) {
      Get.snackbar(
        'Coupon',
        'Code recorded. Discount will apply when billing supports coupons.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _onPaymentSuccess(ConnectRazorpaySuccess response) async {
    setState(() => _checkoutOpen = false);
    final id = _bookingId;
    if (id == null || id.isEmpty) {
      if (!mounted) return;
      Get.snackbar(
        'Payment',
        'Missing booking reference.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }
    setState(() => _confirming = true);
    try {
      final ds = sl<ConnectBookingRemoteDataSource>();
      final result = await ds.confirmPayment(
        id,
        razorpayOrderId: response.orderId,
        razorpayPaymentId: response.paymentId,
        razorpaySignature: response.signature,
      );
      if (!mounted) return;
      setState(() => _confirming = false);
      final mhpName = _args['mhpDisplayName'] as String? ?? 'Professional';
      Get.offNamed(
        AppRoutes.connectPaymentSuccess,
        arguments: {
          'mhpDisplayName': mhpName,
          'mhpUserId': _args['mhpUserId'],
          'meetLink': result.meetLink,
          'bookingId': result.bookingId,
          'amountInr': _singleSessionInr,
          'paymentMethod': 'Razorpay',
          'paidAt': DateTime.now().toUtc().toIso8601String(),
          'razorpayPaymentId': response.paymentId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _confirming = false);
      Get.snackbar(
        'Confirm failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  void _onPaymentError(String message) {
    setState(() => _checkoutOpen = false);
    Get.snackbar(
      'Payment',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }

  void _onContinue() {
    final prep = _prepare;
    if (prep == null || _checkoutOpen || _confirming) return;
    setState(() => _checkoutOpen = true);
    _razorpay.openCheckout(
      key: prep.keyId,
      amountPaise: prep.amountPaise,
      currency: prep.currency,
      orderId: prep.orderId,
    );
  }

  Widget _elevatedCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _mhpAvatar(String? picturePath) {
    final url = ProfilePictureHelper.getProfilePictureUrl(picturePath);
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: url,
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: _avatarSize,
            height: _avatarSize,
            color: Colors.grey.shade200,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => _avatarFallback(),
        ),
      );
    }
    return _avatarFallback();
  }

  Widget _avatarFallback() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        'assets/images/communitydp.png',
        width: _avatarSize,
        height: _avatarSize,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mhpName = _args['mhpDisplayName'] as String? ?? 'MHP';
    final therapyLabel = (_args['therapyLabel'] as String?)?.trim();
    final pref = _args['preference'] as String? ?? '—';
    final slot = _args['slot'] as String? ?? '—';
    final picturePath = _args['mhpPicturePath'] as String?;
    final bookingId = _bookingId;

    DateTime? date;
    final raw = _args['date'] as String?;
    if (raw != null) {
      date = DateTime.tryParse(raw);
    }
    final dateStr = date != null
        ? DateFormat('EEEE, d MMMM y').format(date)
        : '—';

    final holdExp = _args['paymentHoldExpiresAt'] as String?;
    DateTime? holdExpDt;
    if (holdExp != null) {
      holdExpDt = DateTime.tryParse(holdExp);
    }

    final therapyLine = therapyLabel != null && therapyLabel.isNotEmpty
        ? '$therapyLabel with :'
        : 'Session with :';

    final canContinue = !_loadingOrder &&
        _orderError == null &&
        _prepare != null &&
        !_confirming &&
        bookingId != null &&
        bookingId.isNotEmpty &&
        _singleSessionInr > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => popOrGoHome(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontFamily: 'Lexend',
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _elevatedCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _mhpAvatar(picturePath),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        therapyLine,
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mhpName,
                                        style: const TextStyle(
                                          fontFamily: 'Lexend',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _detailRow('Date', dateStr),
                            _detailRow('Time', slot),
                            _detailRow('Preference', pref),
                            if (holdExpDt != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Pay before ${DateFormat('h:mm a').format(holdExpDt.toLocal())}',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _elevatedCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _couponController,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _onApplyCoupon(),
                                decoration: InputDecoration(
                                  hintText: 'Coupon code',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Lexend',
                                    color: Colors.grey.shade500,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _onApplyCoupon,
                              child: const Text(
                                'Apply',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w600,
                                  color: _purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _elevatedCard(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Info:',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _priceRow(
                              'Single session price',
                              _loadingOrder
                                  ? '…'
                                  : '₹${_singleSessionInr > 0 ? _singleSessionInr : '—'}',
                            ),
                            const SizedBox(height: 10),
                            _priceRow(
                              'Code applied',
                              _appliedCouponCode ?? 'N/A',
                              valueIsMuted: _appliedCouponCode == null,
                            ),
                            if (_discountInr > 0) ...[
                              const SizedBox(height: 8),
                              _priceRow(
                                'Discount',
                                '-₹$_discountInr',
                                valueStyle: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1, color: Colors.grey.shade300),
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Final amount',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  _loadingOrder
                                      ? '…'
                                      : '₹$_finalPayableInr',
                                  style: const TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (_orderError != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _orderError!,
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 13,
                                  color: Colors.red.shade800,
                                  height: 1.35,
                                ),
                              ),
                              TextButton(
                                onPressed: _loadingOrder ? null : _loadPaymentOrder,
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(fontFamily: 'Lexend'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FilledButton(
                onPressed: canContinue ? _onContinue : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  disabledBackgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: const StadiumBorder(),
                ),
                child: _confirming
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : _loadingOrder
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _priceRow(
    String label,
    String value, {
    bool valueIsMuted = false,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueIsMuted ? Colors.grey.shade500 : Colors.black87,
              ),
        ),
      ],
    );
  }
}
