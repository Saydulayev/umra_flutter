import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/purchase_provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../models/donation_product.dart';

/// Виджет для отображения вариантов пожертвований
class DonationWidget extends StatelessWidget {
  const DonationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Описание пожертвований
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.contributionToApplicationDevelopment,
            style: TextStyle(
              fontSize: 14,
              color: theme.secondaryTextColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Список продуктов
        if (purchaseProvider.isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (purchaseProvider.availableProducts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.donationProductsNotAvailable,
              style: TextStyle(fontSize: 14, color: theme.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...DonationProduct.allProducts.map((donationProduct) {
            final productDetails = purchaseProvider.getProductById(
              donationProduct.id,
            );
            if (productDetails == null) return const SizedBox.shrink();

            return _DonationProductCard(
              productDetails: productDetails,
              donationProduct: donationProduct,
              theme: theme,
              l10n: l10n,
              isPurchasing: purchaseProvider.isPurchasing,
              onPurchase: () =>
                  purchaseProvider.purchaseProduct(productDetails),
            );
          }).toList(),

        // Сообщение об ошибке
        if (purchaseProvider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      purchaseProvider.errorMessage!,
                      style: TextStyle(fontSize: 12, color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => purchaseProvider.clearError(),
                    color: Colors.red[700],
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Карточка продукта пожертвования
class _DonationProductCard extends StatelessWidget {
  final ProductDetails productDetails;
  final DonationProduct donationProduct;
  final AppTheme theme;
  final AppLocalizations l10n;
  final bool isPurchasing;
  final VoidCallback onPurchase;

  const _DonationProductCard({
    required this.productDetails,
    required this.donationProduct,
    required this.theme,
    required this.l10n,
    required this.isPurchasing,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: isPurchasing ? null : onPurchase,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.gradientTopColor, theme.lightBackgroundColor],
              ),
            ),
            child: Row(
              children: [
                // Иконка
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Информация о продукте
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.supportTheDeveloperString,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        productDetails.price,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Кнопка покупки
                if (isPurchasing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: theme.primaryColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
