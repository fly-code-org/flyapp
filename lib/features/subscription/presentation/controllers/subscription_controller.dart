import 'package:fly/features/subscription/data/subscription_remote_data_source.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  final _ds = SubscriptionRemoteDataSource();

  final Rxn<ActiveSubscription> activeSub = Rxn<ActiveSubscription>();
  final RxBool isFetching = false.obs;

  bool get hasAnySub => activeSub.value != null && activeSub.value!.active;
  bool get hasAuraPlan => hasAnySub && activeSub.value!.planName == 'Aura';

  @override
  void onInit() {
    super.onInit();
    fetchSubscription();
  }

  Future<void> fetchSubscription() async {
    isFetching.value = true;
    try {
      activeSub.value = await _ds.getActiveSubscription();
    } catch (_) {
      activeSub.value = null;
    } finally {
      isFetching.value = false;
    }
  }

  /// Returns true if user has any active plan; otherwise navigates to subscription screen and returns false.
  bool requireAnyPlan() {
    if (hasAnySub) return true;
    Get.toNamed(AppRoutes.subscriptionPlans);
    return false;
  }

  /// Returns true if user has the Aura plan; otherwise navigates to subscription screen and returns false.
  bool requireAuraPlan() {
    if (hasAuraPlan) return true;
    Get.toNamed(AppRoutes.subscriptionPlans);
    return false;
  }
}
