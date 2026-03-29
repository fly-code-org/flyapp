import 'connect_razorpay_types.dart';

/// Web: no `dart:io` — Razorpay native SDK is not available.
class ConnectRazorpaySession {
  ConnectRazorpayOnError? _onError;

  void init({
    required ConnectRazorpayOnSuccess onSuccess,
    required ConnectRazorpayOnError onError,
  }) {
    _onError = onError;
  }

  void dispose() {
    _onError = null;
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
    _onError?.call(
      'Razorpay Checkout runs on the Android or iOS app. '
      'Use a device or emulator to pay.',
    );
  }
}
