import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/purchase_service.dart';

/// Провайдер для управления состоянием покупок
class PurchaseProvider with ChangeNotifier {
  final PurchaseService _purchaseService = PurchaseService();

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _errorMessage;
  List<ProductDetails> _availableProducts = [];
  bool _purchaseSuccess = false;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get errorMessage => _errorMessage;
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
      });

      final success = await _purchaseService.initialize();
      _isInitialized = success;

      if (success) {
        await loadProducts();
      } else {
        _errorMessage = 'Google Play Billing недоступен';
      }
    } catch (e) {
      _errorMessage = 'Ошибка инициализации: $e';
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
          _errorMessage =
              'Google Play Billing недоступен. Убедитесь, что устройство поддерживает Google Play Services.';
        } else {
          _errorMessage =
              'Продукты не найдены. Возможные причины:\n'
              '1. Продукты еще не активированы в Google Play Console (может занять несколько часов)\n'
              '2. Приложение не опубликовано в тестовом треке\n'
              '3. Неправильные ID продуктов\n'
              '4. Необходимо войти в Google Play под тестовым аккаунтом';
        }
      }
    } catch (e) {
      _errorMessage = 'Ошибка загрузки продуктов: $e';
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
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _purchaseService.buyProduct(productDetails);
      if (!success) {
        _errorMessage = 'Не удалось начать покупку';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Ошибка покупки: $e';
      return false;
    } finally {
      _isPurchasing = false;
      notifyListeners();
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
