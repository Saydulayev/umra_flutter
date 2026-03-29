import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/donation_product.dart';

/// Сервис для работы с покупками (In-App Purchases)
class PurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  VoidCallback? _onPurchaseSuccess;
  Function(String)? _onPurchaseError; // Передает код ошибки
  VoidCallback? _onPurchaseCanceled;
  VoidCallback? _onPurchasePending;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  /// Установить callback для успешной покупки
  void setOnPurchaseSuccess(VoidCallback? callback) {
    _onPurchaseSuccess = callback;
  }

  /// Установить callback для ошибки покупки
  /// Принимает код ошибки (например, "BillingResponse.billingUnavailable")
  void setOnPurchaseError(Function(String)? callback) {
    _onPurchaseError = callback;
  }

  /// Установить callback для отмены покупки пользователем (без показа ошибки)
  void setOnPurchaseCanceled(VoidCallback? callback) {
    _onPurchaseCanceled = callback;
  }

  /// Установить callback для покупки в ожидании
  void setOnPurchasePending(VoidCallback? callback) {
    _onPurchasePending = callback;
  }

  /// Инициализация сервиса покупок
  Future<bool> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();

    if (_isAvailable) {
      // Слушаем обновления покупок
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          // Обработка ошибок
        },
      );
    }

    return _isAvailable;
  }

  /// Загрузка доступных продуктов
  Future<List<ProductDetails>> loadProducts() async {
    if (!_isAvailable) {
      return [];
    }

    final Set<String> productIds = DonationProduct.allProducts
        .map((product) => product.id)
        .toSet();

    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails(productIds);

    return response.productDetails;
  }

  /// Покупка продукта (consumable)
  Future<bool> buyProduct(ProductDetails productDetails) async {
    if (!_isAvailable) {
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    // Используем buyConsumable для consumable products (пожертвований)
    return await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  /// Обработка обновлений покупок
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _onPurchasePending?.call();
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Покупка успешна — уведомляем ПЕРЕД потреблением
        _onPurchaseSuccess?.call();
        _consumePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.restored) {
        // Для consumable-пожертвований restored = незавершённая транзакция
        // из прошлой сессии. Просто завершаем её без уведомления об успехе,
        // чтобы не имитировать новую оплату при следующем нажатии "Пожертвовать".
        _consumePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        final error = purchaseDetails.error;
        final errorCode = error != null ? (error.code.toString()) : 'unknown';
        // Если пользователь сам отменил — не показываем ошибку
        // iOS: SKErrorPaymentCancelled = "2", Android: "1" (USER_CANCELED)
        if (_isCancellationError(errorCode)) {
          _onPurchaseCanceled?.call();
        } else {
          _onPurchaseError?.call(errorCode);
        }
      }

      if (purchaseDetails.pendingCompletePurchase &&
          purchaseDetails.status != PurchaseStatus.purchased &&
          purchaseDetails.status != PurchaseStatus.restored) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Потребление покупки (для consumable products)
  Future<void> _consumePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// Восстановление покупок
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      return;
    }
    await _inAppPurchase.restorePurchases();
  }

  /// Определяет, является ли ошибка отменой пользователя
  bool _isCancellationError(String errorCode) {
    final code = errorCode.toLowerCase();
    // iOS: SKErrorPaymentCancelled = 2
    // Android: BillingResponseCode.USER_CANCELED = 1
    return code == '2' ||
        code == '1' ||
        code.contains('cancel') ||
        code.contains('user_canceled') ||
        code.contains('usercanceled');
  }

  /// Очистка ресурсов
  void dispose() {
    _subscription?.cancel();
  }
}
