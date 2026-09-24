import '../models/wallet_transaction_model.dart';
import '../mock/mock_data.dart';

abstract class WalletRepository {
  Future<double> getBalance();
  Future<List<WalletTransactionModel>> getTransactions();
}

class MockWalletRepository implements WalletRepository {
  @override
  Future<double> getBalance() async {
    return 240.0;
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions() async {
    return MockData.initialWalletTransactions;
  }
}
