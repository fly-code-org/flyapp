import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'connect_razorpay_types.dart';

/// Android / iOS native Checkout.
class ConnectRazorpaySession {
  final Razorpay _rz = Razorpay();
  ConnectRazorpayOnSuccess? _onSuccess;
  ConnectRazorpayOnError? _onError;

  void init({
    required ConnectRazorpayOnSuccess onSuccess,
    required ConnectRazorpayOnError onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _rz.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _rz.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _rz.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _rz.clear();
    _onSuccess = null;
    _onError = null;
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    final payId = response.paymentId?.trim() ?? '';
    final orderId = response.orderId?.trim() ?? '';
    final sig = response.signature?.trim() ?? '';
    if (payId.isEmpty || orderId.isEmpty || sig.isEmpty) {
      _onError?.call('Incomplete payment response from Razorpay.');
      return;
    }
    _onSuccess?.call(ConnectRazorpaySuccess(
      paymentId: payId,
      orderId: orderId,
      signature: sig,
    ));
  }

  void _handleError(PaymentFailureResponse response) {
    _onError?.call(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay external wallet: ${response.walletName}');
  }

  void openCheckout({
    required String key,
    required int amountPaise,
    required String currency,
    required String orderId,
    String name = 'Fly',
    String description = 'Therapy session',
    int timeoutSeconds = 300,
  }) {
    _rz.open({
      'key': key,
      'amount': amountPaise,
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': orderId,
      'timeout': timeoutSeconds,
      'retry': {'enabled': true, 'max_count': 1},
    });
  }
}
