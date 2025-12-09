import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/purchase_service.dart';

/// Провайдер для управления состоянием покупок
class PurchaseProvider with ChangeNotifier {
  final PurchaseService _purchaseService = PurchaseService();

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isPurchasing = false;
  bool _isPurchasePending = false;
  String? _errorMessage;
  String? _errorCode; // Код ошибки для локализации
  List<ProductDetails> _availableProducts = [];
  bool _purchaseSuccess = false;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  bool get isPurchasePending => _isPurchasePending;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode; // Код ошибки для локализации
  List<ProductDetails> get availableProducts => _availableProducts;
  bool get isAvailable => _purchaseService.isAvailable;
  bool get purchaseSuccess => _purchaseSuccess;

  /// Инициализация сервиса покупок
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Устанавливаем callback для успешной покупки
      _purchaseService.setOnPurchaseSuccess(() {
        setPurchaseSuccess(true);
        _isPurchasePending = false;
        _isPurchasing = false;
        notifyListeners();
      });

      // Устанавливаем callback для ошибки покупки
      // Принимает код ошибки, локализация будет в виджете
      _purchaseService.setOnPurchaseError((errorCode) {
        _errorCode = errorCode;
        _errorMessage = errorCode; // Временно, будет заменено в виджете
        _isPurchasePending = false;
        _isPurchasing = false;
        notifyListeners();
      });

      // Устанавливаем callback для покупки в ожидании
      _purchaseService.setOnPurchasePending(() {
        _isPurchasePending = true;
        _errorMessage = null;
        notifyListeners();
      });

      final success = await _purchaseService.initialize();
      _isInitialized = success;

      if (success) {
        await loadProducts();
      } else {
        _errorCode = 'INIT_BILLING_UNAVAILABLE';
        _errorMessage = 'INIT_BILLING_UNAVAILABLE';
      }
    } catch (e) {
      _errorCode = 'INIT_ERROR';
      _errorMessage = 'INIT_ERROR';
      _isInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Загрузка доступных продуктов
  Future<void> loadProducts() async {
    if (!_isInitialized) {
      await initialize();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableProducts = await _purchaseService.loadProducts();

      if (_availableProducts.isEmpty) {
        // Проверяем, доступен ли Google Play Billing
        if (!_purchaseService.isAvailable) {
          _errorCode = 'INIT_BILLING_UNAVAILABLE';
          _errorMessage = 'INIT_BILLING_UNAVAILABLE';
        } else {
          _errorCode = 'PRODUCTS_NOT_FOUND';
          _errorMessage = 'PRODUCTS_NOT_FOUND';
        }
      }
    } catch (e) {
      _errorCode = 'LOAD_PRODUCTS_ERROR';
      _errorMessage = 'LOAD_PRODUCTS_ERROR';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Покупка продукта
  Future<bool> purchaseProduct(ProductDetails productDetails) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return false;
      }
    }

    _isPurchasing = true;
    _isPurchasePending = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _purchaseService.buyProduct(productDetails);
      if (!success) {
        _errorCode = 'PURCHASE_START_ERROR';
        _errorMessage = 'PURCHASE_START_ERROR';
        _isPurchasing = false;
        notifyListeners();
      }
      // Если успешно, статус будет обновлен через callback (pending/purchased/error)
      return success;
    } catch (e) {
      _errorCode = 'PURCHASE_START_ERROR';
      _errorMessage = 'PURCHASE_START_ERROR';
      _isPurchasing = false;
      _isPurchasePending = false;
      notifyListeners();
      return false;
    }
  }

  /// Получить продукт по ID
  ProductDetails? getProductById(String productId) {
    try {
      return _availableProducts.firstWhere(
        (product) => product.id == productId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Очистка ошибки
  void clearError() {
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }

  /// Установить успешную покупку
  void setPurchaseSuccess(bool success) {
    _purchaseSuccess = success;
    notifyListeners();
  }

  /// Сбросить флаг успешной покупки
  void clearPurchaseSuccess() {
    _purchaseSuccess = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}
