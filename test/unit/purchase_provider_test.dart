import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:umra_flutter/providers/purchase_provider.dart';
import 'package:umra_flutter/services/purchase_service.dart';

import '../helpers/fake_purchase_service.dart';

ProductDetails _product([String id = 'donation_099']) => ProductDetails(
  id: id,
  title: 'Donation',
  description: 'Test donation',
  price: '0.99 \$',
  rawPrice: 0.99,
  currencyCode: 'USD',
);

void main() {
  late FakePurchaseService service;
  late PurchaseProvider provider;

  setUp(() {
    service = FakePurchaseService();
    provider = PurchaseProvider(purchaseService: service);
  });

  group('initialize', () {
    test('успех → isInitialized, продукты загружены, ошибок нет', () async {
      service.products = [_product()];
      await provider.initialize();

      expect(provider.isInitialized, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.availableProducts, hasLength(1));
      expect(provider.errorCode, isNull);
    });

    test('биллинг недоступен → INIT_BILLING_UNAVAILABLE', () async {
      service.initResult = false;
      await provider.initialize();

      expect(provider.isInitialized, isFalse);
      expect(provider.errorCode, 'INIT_BILLING_UNAVAILABLE');
      expect(provider.isLoading, isFalse);
    });

    test('повторный вызов не инициализирует заново', () async {
      service.products = [_product()];
      await provider.initialize();
      await provider.initialize();

      expect(service.initializeCalls, 1);
    });

    test('пустой список продуктов при доступном биллинге → PRODUCTS_NOT_FOUND',
        () async {
      service.products = [];
      await provider.initialize();

      expect(provider.errorCode, 'PRODUCTS_NOT_FOUND');
    });
  });

  group('покупка: события от сервиса', () {
    setUp(() async {
      service.products = [_product()];
      await provider.initialize();
    });

    test('успешная покупка → purchaseSuccess, isPurchasing сброшен', () async {
      await provider.purchaseProduct(_product());
      expect(provider.isPurchasing, isTrue);

      service.onSuccess!();

      expect(provider.purchaseSuccess, isTrue);
      expect(provider.isPurchasing, isFalse);
      expect(provider.isPurchasePending, isFalse);
      expect(provider.errorCode, isNull);
    });

    test('ошибка (не отмена) → errorCode заполнен, isPurchasing сброшен',
        () async {
      await provider.purchaseProduct(_product());

      service.onError!('BillingResponse.itemUnavailable');

      expect(provider.errorCode, 'BillingResponse.itemUnavailable');
      expect(provider.isPurchasing, isFalse);
      expect(provider.purchaseSuccess, isFalse);
    });

    test('отмена пользователем → errorCode НЕ выставляется', () async {
      await provider.purchaseProduct(_product());

      service.onCanceled!();

      expect(provider.errorCode, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.isPurchasing, isFalse);
      expect(provider.purchaseSuccess, isFalse);
    });

    test('buyProduct вернул false → PURCHASE_START_ERROR', () async {
      service.buyResult = false;
      final ok = await provider.purchaseProduct(_product());

      expect(ok, isFalse);
      expect(provider.errorCode, 'PURCHASE_START_ERROR');
      expect(provider.isPurchasing, isFalse);
    });

    test('purchaseProduct вызывает buyProduct сервиса', () async {
      await provider.purchaseProduct(_product());
      expect(service.buyCalls, 1);
    });
  });

  group('таймауты (fakeAsync)', () {
    test('покупка без ответа платформы тихо сбрасывается через 15 секунд', () {
      fakeAsync((async) {
        service.products = [_product()];
        provider.initialize();
        async.flushMicrotasks();

        provider.purchaseProduct(_product());
        async.flushMicrotasks();
        expect(provider.isPurchasing, isTrue);

        async.elapse(const Duration(seconds: 14));
        expect(provider.isPurchasing, isTrue);

        async.elapse(const Duration(seconds: 2));
        expect(provider.isPurchasing, isFalse);
        // Тихий сброс: пользователь закрыл окно оплаты — это не ошибка.
        expect(provider.errorCode, isNull);
      });
    });

    test('pending дольше 60 секунд → PURCHASE_TIMEOUT', () {
      fakeAsync((async) {
        service.products = [_product()];
        provider.initialize();
        async.flushMicrotasks();

        provider.purchaseProduct(_product());
        async.flushMicrotasks();

        service.onPending!();
        expect(provider.isPurchasePending, isTrue);

        async.elapse(const Duration(seconds: 59));
        expect(provider.isPurchasePending, isTrue);
        expect(provider.errorCode, isNull);

        async.elapse(const Duration(seconds: 2));
        expect(provider.isPurchasePending, isFalse);
        expect(provider.isPurchasing, isFalse);
        expect(provider.errorCode, 'PURCHASE_TIMEOUT');
      });
    });

    test('успех отменяет таймер: спустя 60 секунд ошибки нет', () {
      fakeAsync((async) {
        service.products = [_product()];
        provider.initialize();
        async.flushMicrotasks();

        provider.purchaseProduct(_product());
        async.flushMicrotasks();

        service.onPending!();
        service.onSuccess!();

        async.elapse(const Duration(seconds: 120));
        expect(provider.purchaseSuccess, isTrue);
        expect(provider.errorCode, isNull);
      });
    });
  });

  group('PurchaseService.isCancellationError', () {
    test('реальные коды отмены: iOS "2", Android "1" и USER_CANCELED', () {
      expect(PurchaseService.isCancellationError('2'), isTrue);
      expect(PurchaseService.isCancellationError('1'), isTrue);
      expect(PurchaseService.isCancellationError('USER_CANCELED'), isTrue);
      expect(
        PurchaseService.isCancellationError('BillingResponse.userCanceled'),
        isTrue,
      );
      expect(PurchaseService.isCancellationError('paymentCancelled'), isTrue);
    });

    test('реальные ошибки НЕ считаются отменой', () {
      expect(PurchaseService.isCancellationError('unknown'), isFalse);
      expect(
        PurchaseService.isCancellationError('BillingResponse.itemUnavailable'),
        isFalse,
      );
      expect(
        PurchaseService.isCancellationError(
          'BillingResponse.billingUnavailable',
        ),
        isFalse,
      );
      expect(PurchaseService.isCancellationError('7'), isFalse);
      expect(PurchaseService.isCancellationError(''), isFalse);
    });
  });

  group('вспомогательные методы', () {
    test('getProductById находит продукт и возвращает null для чужого id',
        () async {
      service.products = [_product('donation_099')];
      await provider.initialize();

      expect(provider.getProductById('donation_099'), isNotNull);
      expect(provider.getProductById('nope'), isNull);
    });

    test('clearError и clearPurchaseSuccess сбрасывают состояние', () async {
      service.initResult = false;
      await provider.initialize();
      expect(provider.errorCode, isNotNull);

      provider.clearError();
      expect(provider.errorCode, isNull);
      expect(provider.errorMessage, isNull);

      provider.setPurchaseSuccess(true);
      provider.clearPurchaseSuccess();
      expect(provider.purchaseSuccess, isFalse);
    });
  });
}
