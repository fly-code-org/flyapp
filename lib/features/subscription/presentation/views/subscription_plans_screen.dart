import 'package:flutter/material.dart';
import 'package:fly/features/mhp_profile/presentation/views/connect_razorpay/connect_razorpay_checkout.dart';
import 'package:fly/features/subscription/data/subscription_remote_data_source.dart';
import 'package:fly/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:get/get.dart';

const _kPurple = Color(0xFF7C3AED);
const _kDeepPurple = Color(0xFF3B1178);
const _kOrange = Color(0xFFF97316);

/// Proxy that keeps all plan metadata but overrides the charge amount for prorated upgrades.
class _UpgradePlanProxy extends SubscriptionPlan {
  _UpgradePlanProxy(SubscriptionPlan base, int chargeINR)
      : super(
          name: base.name,
          tagline: base.tagline,
          amountInr: chargeINR,
          durationDays: base.durationDays,
          streakRestores: base.streakRestores,
          features: base.features,
        );
}

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  final _ds = SubscriptionRemoteDataSource();
  final ConnectRazorpaySession _razorpay = ConnectRazorpaySession();

  int _selectedPlanIndex = 0;
  ActiveSubscription? _activeSub;
  bool _loadingStatus = true;
  bool _purchasing = false;
  String? _error;
  SubscriptionPlan? _pendingPlan;
  UpgradePreview? _upgradePreview;
  bool _loadingUpgradePreview = false;

  static const _plans = [kSoulPlan, kAuraPlan];

  SubscriptionPlan get _selectedPlan => _plans[_selectedPlanIndex];

  @override
  void initState() {
    super.initState();
    _razorpay.init(onSuccess: _onPaymentSuccess, onError: _onPaymentError);
    _loadStatus();
  }

  @override
  void dispose() {
    _razorpay.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() => _loadingStatus = true);
    final sub = await _ds.getActiveSubscription();
    if (mounted) {
      setState(() { _activeSub = sub; _loadingStatus = false; });
      // Auto-fetch upgrade preview if user is already on Soul and Aura tab is visible
      if (_isUpgradeScenario) _fetchUpgradePreview();
    }
  }

  Future<void> _fetchUpgradePreview() async {
    if (_loadingUpgradePreview) return;
    setState(() { _loadingUpgradePreview = true; _upgradePreview = null; });
    try {
      final preview = await _ds.getUpgradePreview();
      if (mounted) setState(() => _upgradePreview = preview);
    } catch (_) {
      // Non-fatal: fall back to full price if preview fails
      if (mounted) setState(() => _upgradePreview = null);
    } finally {
      if (mounted) setState(() => _loadingUpgradePreview = false);
    }
  }

  bool get _isUpgradeScenario =>
      _activeSub != null && _activeSub!.active && _activeSub!.planName == 'Soul' && _selectedPlanIndex == 1;

  Future<void> _onContinue() async {
    if (_purchasing) return;
    setState(() { _purchasing = true; _error = null; _pendingPlan = _selectedPlan; });
    try {
      // For upgrades use the prorated charge; for fresh purchases use the plan price.
      final effectivePlan = _isUpgradeScenario && _upgradePreview != null
          ? _UpgradePlanProxy(_selectedPlan, _upgradePreview!.chargeINR)
          : _selectedPlan;
      final order = await _ds.createSubscriptionOrder(effectivePlan);
      if (!mounted) return;
      final description = _isUpgradeScenario
          ? 'Upgrade to Fly ${_selectedPlan.name} Plan'
          : 'Fly ${_selectedPlan.name} Plan — ₹${_selectedPlan.amountInr}/month';
      _razorpay.openCheckout(
        key: order.keyId,
        amountPaise: order.amountInr * 100,
        currency: order.currency,
        orderId: order.razorpayOrderId,
        description: description,
      );
    } catch (e) {
      if (mounted) {
        setState(() { _purchasing = false; _pendingPlan = null; _error = 'Failed to start checkout. Please try again.'; });
      }
    }
  }

  Future<void> _onPaymentSuccess(ConnectRazorpaySuccess response) async {
    final plan = _pendingPlan ?? _selectedPlan;
    try {
      await _ds.verifyPayment(
        razorpayOrderId: response.orderId,
        paymentId: response.paymentId,
        signature: response.signature,
      );
      await _ds.activateSubscription(plan);
      if (!mounted) return;
      setState(() { _purchasing = false; _pendingPlan = null; _upgradePreview = null; });
      _showSuccessDialog(plan);
      _loadStatus();
      _refreshSubscriptionController();
    } catch (e) {
      if (mounted) {
        setState(() {
          _purchasing = false;
          _pendingPlan = null;
          _error = 'Payment received but activation failed. Contact support.';
        });
      }
    }
  }

  void _onPaymentError(String message) {
    if (mounted) setState(() { _purchasing = false; _pendingPlan = null; _error = message; });
  }

  void _showSuccessDialog(SubscriptionPlan plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_kDeepPurple, _kPurple]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to ${plan.name} Plan!',
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              plan.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: _kPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isSubscribed => _activeSub != null && _activeSub!.active;

  void _refreshSubscriptionController() {
    if (Get.isRegistered<SubscriptionController>()) {
      Get.find<SubscriptionController>().fetchSubscription();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDeepPurple,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kDeepPurple, _kPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildWhiteCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 28),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Image.asset(
              'assets/images/fly_logo.png',
              height: 42,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (_, __, ___) => const Icon(Icons.flutter_dash, color: Colors.white, size: 42),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteCard() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: _loadingStatus
          ? const Center(child: CircularProgressIndicator(color: _kPurple))
          : Column(
              children: [
                const SizedBox(height: 24),
                _buildTabSwitcher(),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      children: [
                        if (_isSubscribed) ...[
                          _buildActiveBanner(),
                          const SizedBox(height: 16),
                        ],
                        _buildPlanCard(),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13,
                              fontFamily: 'Lexend',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _buildBottomButton(),
              ],
            ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBFF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Soul Plan'),
          _buildTab(1, 'Aura Plan'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedPlanIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() { _selectedPlanIndex = index; _error = null; });
          // Fetch upgrade preview when Soul subscriber taps Aura tab
          if (_activeSub?.planName == 'Soul' && _activeSub!.active && index == 1 && _upgradePreview == null) {
            _fetchUpgradePreview();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(46),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _kPurple : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard() {
    return _selectedPlanIndex == 0 ? _buildSoulCard() : _buildAuraCard();
  }

  Widget _buildSoulCard() {
    const headerBg = Color(0xFFEDE9FE);
    const headerText = Color(0xFF5B21B6);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
        boxShadow: [
          BoxShadow(color: _kPurple.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              color: headerBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Soul Plan',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: headerText,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '₹99',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: headerText,
                          ),
                        ),
                        Text(
                          'per month',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 12,
                            color: headerText.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  kSoulPlan.tagline,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 13,
                    color: headerText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FEATURES PROVIDED',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                ...kSoulPlan.features.map((f) => _buildFeatureRow(f)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuraCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
        boxShadow: [
          BoxShadow(color: _kPurple.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B21E8), _kOrange],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aura Plan',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '₹189',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'per month',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  kAuraPlan.tagline,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FEATURES PROVIDED',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                ...kAuraPlan.features.map((f) => _buildFeatureRow(f)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF16A34A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                color: Color(0xFF1F2937),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBanner() {
    final exp = _activeSub?.expiresAt;
    final expStr = exp != null ? '${exp.day}/${exp.month}/${exp.year}' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPurple.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: _kPurple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_activeSub?.planName ?? 'Plan'} active — renews $expStr',
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _kPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final alreadyOnThisPlan = (_activeSub != null && _activeSub!.active) &&
        ((_selectedPlanIndex == 0 && _activeSub!.planName == 'Soul') ||
         (_selectedPlanIndex == 1 && _activeSub!.planName == 'Aura'));

    String buttonLabel;
    if (alreadyOnThisPlan) {
      buttonLabel = 'Already Subscribed';
    } else if (_isUpgradeScenario) {
      final charge = _upgradePreview?.chargeINR ?? kAuraPlan.amountInr;
      buttonLabel = 'Upgrade to Aura — ₹$charge';
    } else {
      buttonLabel = 'Continue to Payment';
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isUpgradeScenario) _buildUpgradeBreakdown(),
            if (_isUpgradeScenario) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (alreadyOnThisPlan || _purchasing || _loadingUpgradePreview) ? null : _onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: _kPurple,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                child: (_purchasing || (_isUpgradeScenario && _loadingUpgradePreview))
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cancel anytime. Billed monthly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Lexend', fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeBreakdown() {
    if (_upgradePreview == null) {
      return const SizedBox.shrink();
    }
    final p = _upgradePreview!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _breakdownRow('Aura Plan (full price)', '₹${kAuraPlan.amountInr}', isTotal: false),
          const SizedBox(height: 6),
          _breakdownRow(
            'Soul credit (${p.remainingDays} days remaining)',
            '−₹${p.creditINR}',
            isCredit: true,
          ),
          const Divider(height: 16),
          _breakdownRow('You pay today', '₹${p.chargeINR}', isTotal: true),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String amount, {bool isTotal = false, bool isCredit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isCredit ? const Color(0xFF16A34A) : const Color(0xFF374151),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isCredit ? const Color(0xFF16A34A) : (isTotal ? _kPurple : const Color(0xFF374151)),
          ),
        ),
      ],
    );
  }
}
