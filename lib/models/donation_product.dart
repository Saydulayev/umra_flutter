/// Модель продукта пожертвования
class DonationProduct {
  final String id;
  final String nameKey; // Ключ локализации для названия
  final String descriptionKey; // Ключ локализации для описания
  final double amount; // Сумма пожертвования (для отображения)

  const DonationProduct({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.amount,
  });

  /// Список всех доступных продуктов пожертвований
  static const List<DonationProduct> allProducts = [
    DonationProduct(
      id: 'donation_099', // Идентификатор товара в Google Play Console
      nameKey: 'donation0_99',
      descriptionKey: 'donation0_99Description',
      amount: 0.99,
    ),
    DonationProduct(
      id: 'donation_499', // Идентификатор товара в Google Play Console
      nameKey: 'donation4_99',
      descriptionKey: 'donation4_99Description',
      amount: 4.99,
    ),
    DonationProduct(
      id: 'donation_999', // Идентификатор товара в Google Play Console
      nameKey: 'donation9_99',
      descriptionKey: 'donation9_99Description',
      amount: 9.99,
    ),
    DonationProduct(
      id: 'donation_1999', // Идентификатор товара в Google Play Console
      nameKey: 'donation19_99',
      descriptionKey: 'donation19_99Description',
      amount: 19.99,
    ),
    DonationProduct(
      id: 'donation_4999', // Идентификатор товара в Google Play Console
      nameKey: 'donation49_99',
      descriptionKey: 'donation49_99Description',
      amount: 49.99,
    ),
    DonationProduct(
      id: 'donation_9999', // Идентификатор товара в Google Play Console
      nameKey: 'donation99_99',
      descriptionKey: 'donation99_99Description',
      amount: 99.99,
    ),
  ];
}
