import 'package:umra_flutter/l10n/app_localizations.dart';

/// Утилита для преобразования кодов ошибок Google Play Billing в локализованные сообщения
class DonationErrorHelper {
  /// Получить локализованное сообщение об ошибке на основе кода ошибки
  static String getLocalizedErrorMessage(
    String? errorCode,
    AppLocalizations l10n,
  ) {
    if (errorCode == null) {
      return l10n.donationErrorUnknown;
    }

    // Проверяем специальные коды ошибок инициализации
    if (errorCode.startsWith('INIT_BILLING_UNAVAILABLE')) {
      return l10n.donationErrorBillingUnavailableInit;
    } else if (errorCode.startsWith('INIT_ERROR')) {
      return l10n.donationErrorInitializationFailed;
    } else if (errorCode.startsWith('LOAD_PRODUCTS_ERROR')) {
      return l10n.donationErrorLoadProductsFailed;
    } else if (errorCode.startsWith('PURCHASE_START_ERROR')) {
      return l10n.donationErrorPurchaseStartFailed;
    } else if (errorCode.startsWith('PRODUCTS_NOT_FOUND')) {
      return l10n.donationErrorProductsNotFound;
    }

    // Преобразуем код ошибки в ключ локализации
    final errorKey = _getErrorKey(errorCode);

    switch (errorKey) {
      case 'billingUnavailable':
        return l10n.donationErrorBillingUnavailable;
      case 'developerError':
        return l10n.donationErrorDeveloperError;
      case 'featureNotSupported':
        return l10n.donationErrorFeatureNotSupported;
      case 'itemAlreadyOwned':
        return l10n.donationErrorItemAlreadyOwned;
      case 'itemUnavailable':
        return l10n.donationErrorItemUnavailable;
      case 'serviceDisconnected':
        return l10n.donationErrorServiceDisconnected;
      case 'serviceUnavailable':
        return l10n.donationErrorServiceUnavailable;
      case 'userCanceled':
        return l10n.donationErrorUserCanceled;
      case 'networkError':
        return l10n.donationErrorNetworkError;
      default:
        return l10n.donationErrorUnknown;
    }
  }

  /// Преобразовать код ошибки в ключ для switch
  static String _getErrorKey(String errorCode) {
    // Убираем префикс "BillingResponse." если он есть
    final code = errorCode.replaceAll('BillingResponse.', '').toLowerCase();

    // Проверяем различные варианты написания
    if (code.contains('billingunavailable') || code == 'billing_unavailable') {
      return 'billingUnavailable';
    } else if (code.contains('developerror') || code == 'developer_error') {
      return 'developerError';
    } else if (code.contains('featurenotsupported') ||
        code == 'feature_not_supported') {
      return 'featureNotSupported';
    } else if (code.contains('itemalreadyowned') ||
        code == 'item_already_owned') {
      return 'itemAlreadyOwned';
    } else if (code.contains('itemunavailable') || code == 'item_unavailable') {
      return 'itemUnavailable';
    } else if (code.contains('servicedisconnected') ||
        code == 'service_disconnected') {
      return 'serviceDisconnected';
    } else if (code.contains('serviceunavailable') ||
        code == 'service_unavailable') {
      return 'serviceUnavailable';
    } else if (code.contains('usercanceled') ||
        code == 'user_canceled' ||
        code.contains('cancel')) {
      return 'userCanceled';
    } else if (code.contains('networkerror') ||
        code == 'network_error' ||
        code.contains('network')) {
      return 'networkError';
    }

    return 'unknown';
  }
}
