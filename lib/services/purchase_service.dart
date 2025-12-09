import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/donation_product.dart';

/// Сервис для работы с Google Play Billing
class PurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  VoidCallback? _onPurchaseSuccess;
  Function(String)? _onPurchaseError; // Передает код ошибки
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
      debugPrint('PurchaseService: Google Play Billing недоступен');
      return [];
    }

    final Set<String> productIds = DonationProduct.allProducts
        .map((product) => product.id)
        .toSet();

    debugPrint(
      'PurchaseService: Запрос продуктов с ID: ${productIds.join(", ")}',
    );

    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails(productIds);

    if (response.error != null) {
      debugPrint(
        'PurchaseService: Ошибка загрузки продуктов: ${response.error}',
      );
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'PurchaseService: Продукты не найдены: ${response.notFoundIDs.join(", ")}',
      );
    }

    debugPrint(
      'PurchaseService: Загружено продуктов: ${response.productDetails.length} из ${productIds.length}',
    );

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
        // Покупка ожидает подтверждения (для медленных тестовых карт)
        _onPurchasePending?.call();
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Покупка успешна - потребляем продукт для возможности повторной покупки
        _consumePurchase(purchaseDetails);
        // Уведомляем об успешной покупке (только для новых покупок, не для восстановленных)
        _onPurchaseSuccess?.call();
      } else if (purchaseDetails.status == PurchaseStatus.restored) {
        // Восстановленная покупка - потребляем, но не показываем уведомление
        _consumePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Ошибка покупки - извлекаем код ошибки для локализации
        final error = purchaseDetails.error;
        final errorCode = error != null ? (error.code.toString()) : 'unknown';
        // Уведомляем об ошибке ПЕРЕД завершением покупки
        _onPurchaseError?.call(errorCode);
      }

      // Завершаем покупку для всех статусов, включая ошибки
      // Это важно для правильной очистки состояния
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Потребление покупки (для consumable products)
  Future<void> _consumePurchase(PurchaseDetails purchaseDetails) async {
    // Для consumable products нужно потреблять покупку после успешной транзакции
    // чтобы пользователь мог купить продукт снова
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      // Потребляем покупку
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

  /// Очистка ресурсов
  void dispose() {
    _subscription?.cancel();
  }
}
