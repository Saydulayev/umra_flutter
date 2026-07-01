import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:umra_flutter/services/purchase_service.dart';

/// Рукописный fake без mocking-библиотек: захватывает callbacks, которые
/// устанавливает провайдер, и позволяет тесту имитировать события
/// purchase stream (успех / ошибка / отмена / pending).
///
/// Используется и в юнит-тестах покупок, и в widget smoke-тестах (чтобы
/// PurchaseProvider не создавал реальный PurchaseService, который трогает
/// InAppPurchase.instance).
class FakePurchaseService implements PurchaseService {
  VoidCallback? onSuccess;
  Function(String)? onError;
  VoidCallback? onCanceled;
  VoidCallback? onPending;

  bool initResult = true;
  bool buyResult = true;
  List<ProductDetails> products = [];

  int initializeCalls = 0;
  int buyCalls = 0;
  int restoreCalls = 0;
  bool _available = false;

  @override
  bool get isAvailable => _available;

  @override
  void setOnPurchaseSuccess(VoidCallback? callback) => onSuccess = callback;

  @override
  void setOnPurchaseError(Function(String)? callback) => onError = callback;

  @override
  void setOnPurchaseCanceled(VoidCallback? callback) => onCanceled = callback;

  @override
  void setOnPurchasePending(VoidCallback? callback) => onPending = callback;

  @override
  Future<bool> initialize() async {
    initializeCalls++;
    _available = initResult;
    return initResult;
  }

  @override
  Future<List<ProductDetails>> loadProducts() async => products;

  @override
  Future<bool> buyProduct(ProductDetails productDetails) async {
    buyCalls++;
    return buyResult;
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalls++;
  }

  @override
  void dispose() {}
}
