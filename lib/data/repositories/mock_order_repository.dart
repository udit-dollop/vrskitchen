import '../models/order_model.dart';
import '../mock/mock_data.dart';

abstract class OrderRepository {
  Future<List<OrderItemModel>> getOrders();
}

class MockOrderRepository implements OrderRepository {
  @override
  Future<List<OrderItemModel>> getOrders() async {
    return MockData.initialOrders;
  }
}
