/// Модель продукта пожертвования
class DonationProduct {
  final String id;
  final String nameKey; // Ключ локализации для названия
  final String descriptionKey; // Ключ локализации для описания

  const DonationProduct({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
  });

  /// Список всех доступных продуктов пожертвований
  static const List<DonationProduct> allProducts = [
    DonationProduct(
      id: 'donation_small',
      nameKey: 'donationSmall',
      descriptionKey: 'donationSmallDescription',
    ),
    DonationProduct(
      id: 'donation_medium',
      nameKey: 'donationMedium',
      descriptionKey: 'donationMediumDescription',
    ),
    DonationProduct(
      id: 'donation_large',
      nameKey: 'donationLarge',
      descriptionKey: 'donationLargeDescription',
    ),
  ];
}
