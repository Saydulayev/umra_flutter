import 'dart:io';

/// Модель продукта пожертвования
class DonationProduct {
  final String androidId; // Идентификатор товара в Google Play Console
  final String iosId; // Идентификатор товара в App Store Connect
  final String nameKey; // Ключ локализации для названия
  final String descriptionKey; // Ключ локализации для описания
  final double amount; // Сумма пожертвования (для отображения)

  const DonationProduct({
    required this.androidId,
    required this.iosId,
    required this.nameKey,
    required this.descriptionKey,
    required this.amount,
  });

  /// Возвращает актуальный ID продукта в зависимости от платформы
  String get id => Platform.isIOS ? iosId : androidId;

  /// Список всех доступных продуктов пожертвований
  static const List<DonationProduct> allProducts = [
    DonationProduct(
      androidId: 'donation_099',
      iosId: 'UmrahSunnah1',
      nameKey: 'donation0_99',
      descriptionKey: 'donation0_99Description',
      amount: 0.99,
    ),
    DonationProduct(
      androidId: 'donation_499',
      iosId: 'UmrahSunnah2',
      nameKey: 'donation4_99',
      descriptionKey: 'donation4_99Description',
      amount: 4.99,
    ),
    DonationProduct(
      androidId: 'donation_999',
      iosId: 'UmrahSunnah3',
      nameKey: 'donation9_99',
      descriptionKey: 'donation9_99Description',
      amount: 9.99,
    ),
    DonationProduct(
      androidId: 'donation_1999',
      iosId: 'UmrahSunnah4',
      nameKey: 'donation19_99',
      descriptionKey: 'donation19_99Description',
      amount: 19.99,
    ),
    DonationProduct(
      androidId: 'donation_4999',
      iosId: 'UmrahSunnah5',
      nameKey: 'donation49_99',
      descriptionKey: 'donation49_99Description',
      amount: 49.99,
    ),
    DonationProduct(
      androidId: 'donation_9999',
      iosId: 'UmrahSunnah6',
      nameKey: 'donation99_99',
      descriptionKey: 'donation99_99Description',
      amount: 99.99,
    ),
  ];
}
