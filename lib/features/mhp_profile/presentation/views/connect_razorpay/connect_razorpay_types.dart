/// Success payload mirrored from Razorpay (used after server confirm).
class ConnectRazorpaySuccess {
  final String paymentId;
  final String orderId;
  final String signature;

  const ConnectRazorpaySuccess({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });
}

typedef ConnectRazorpayOnSuccess = void Function(ConnectRazorpaySuccess response);
typedef ConnectRazorpayOnError = void Function(String message);
