import 'package:dio/dio.dart';
import 'package:fly/core/network/api_client.dart';

class SubscriptionPlan {
  final String name;
  final String tagline;
  final int amountInr;
  final int durationDays;
  final int streakRestores;
  final List<String> features;

  const SubscriptionPlan({
    required this.name,
    required this.tagline,
    required this.amountInr,
    required this.durationDays,
    required this.streakRestores,
    required this.features,
  });
}

const kSoulPlan = SubscriptionPlan(
  name: 'Soul',
  tagline: 'Give your emotions space to breathe.',
  amountInr: 99,
  durationDays: 30,
  streakRestores: 7,
  features: [
    'Access to NIRA (24/7)',
    '7 Streak Restores',
    'Customize App Icon',
    'Add Your Display Picture',
    'Certified Blue Tick',
  ],
);

const kAuraPlan = SubscriptionPlan(
  name: 'Aura',
  tagline: 'Fully expressive. Fully you.',
  amountInr: 189,
  durationDays: 30,
  streakRestores: 15,
  features: [
    'Access to NIRA (24/7)',
    '15 Streak Restores/month',
    'Customize App Icon',
    'Add Your Display Picture',
    'Multicolored Certified Tick',
    'My Journal Writing Access',
    'Send DM to MHPs',
  ],
);

class SubscriptionOrderResult {
  final String internalOrderId;
  final String razorpayOrderId;
  final int amountInr;
  final String currency;
  final String keyId;

  const SubscriptionOrderResult({
    required this.internalOrderId,
    required this.razorpayOrderId,
    required this.amountInr,
    required this.currency,
    required this.keyId,
  });

  factory SubscriptionOrderResult.fromJson(Map<String, dynamic> json) {
    return SubscriptionOrderResult(
      internalOrderId: json['id']?.toString() ?? '',
      razorpayOrderId: json['razorpay_order_id']?.toString() ?? '',
      amountInr: (json['amount_inr'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      keyId: json['key_id']?.toString() ?? '',
    );
  }
}

class ActiveSubscription {
  final String id;
  final String planName;
  final bool active;
  final DateTime expiresAt;

  const ActiveSubscription({
    required this.id,
    required this.planName,
    required this.active,
    required this.expiresAt,
  });

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    return ActiveSubscription(
      id: json['id']?.toString() ?? '',
      planName: json['plan_name']?.toString() ?? '',
      active: json['active'] == true,
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class UpgradePreview {
  final String currentPlan;
  final String targetPlan;
  final int remainingDays;
  final int creditINR;
  final int chargeINR;
  final DateTime currentExpiresAt;
  final DateTime newExpiresAt;

  const UpgradePreview({
    required this.currentPlan,
    required this.targetPlan,
    required this.remainingDays,
    required this.creditINR,
    required this.chargeINR,
    required this.currentExpiresAt,
    required this.newExpiresAt,
  });

  factory UpgradePreview.fromJson(Map<String, dynamic> json) {
    return UpgradePreview(
      currentPlan: json['current_plan']?.toString() ?? '',
      targetPlan: json['target_plan']?.toString() ?? '',
      remainingDays: (json['remaining_days'] as num?)?.toInt() ?? 0,
      creditINR: (json['credit_inr'] as num?)?.toInt() ?? 0,
      chargeINR: (json['charge_inr'] as num?)?.toInt() ?? 0,
      currentExpiresAt: DateTime.tryParse(json['current_expires_at']?.toString() ?? '') ?? DateTime.now(),
      newExpiresAt: DateTime.tryParse(json['new_expires_at']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 30)),
    );
  }
}

class SubscriptionRemoteDataSource {
  final Dio _client;
  SubscriptionRemoteDataSource({Dio? dio}) : _client = dio ?? ApiClient.dio;

  Future<SubscriptionOrderResult> createSubscriptionOrder(SubscriptionPlan plan) async {
    final response = await _client.post(
      '/orders/external/v1/order',
      data: {'order_type': 'subscription', 'amount_inr': plan.amountInr},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return SubscriptionOrderResult.fromJson(data);
  }

  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String paymentId,
    required String signature,
  }) async {
    await _client.post(
      '/orders/external/v1/order/verify',
      data: {
        'razorpay_order_id': razorpayOrderId,
        'payment_id': paymentId,
        'signature': signature,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  Future<void> activateSubscription(SubscriptionPlan plan) async {
    await _client.post(
      '/subscriptions/external/v1/subscription',
      data: {
        'plan_name': plan.name,
        'duration_days': plan.durationDays,
        'usage_metadata': {
          'streak_restores': plan.streakRestores,
          'session_credits': 0,
        },
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  Future<UpgradePreview> getUpgradePreview() async {
    final response = await _client.get('/subscriptions/external/v1/subscription/upgrade-preview');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return UpgradePreview.fromJson(data);
  }

  Future<ActiveSubscription?> getActiveSubscription() async {
    try {
      final response = await _client.get('/subscriptions/external/v1/subscription/active');
      final data = (response.data as Map<String, dynamic>)['data'];
      if (data == null) return null;
      return ActiveSubscription.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
