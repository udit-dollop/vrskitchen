import '../models/subscription_model.dart';
import '../mock/mock_data.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPackageModel>> getPackages();
  Future<UserSubscriptionModel?> getCurrentSubscription();
}

class MockSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<List<SubscriptionPackageModel>> getPackages() async {
    return MockData.allPackages;
  }

  @override
  Future<UserSubscriptionModel?> getCurrentSubscription() async {
    return MockData.initialSubscription;
  }
}
