import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/purchase_provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../models/donation_product.dart';

/// Виджет для отображения вариантов пожертвований
class DonationWidget extends StatefulWidget {
  const DonationWidget({super.key});

  @override
  State<DonationWidget> createState() => _DonationWidgetState();
}

class _DonationWidgetState extends State<DonationWidget> {
  ProductDetails? _selectedProduct;
  PurchaseProvider? _purchaseProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Слушаем изменения в провайдере для показа уведомления
    final purchaseProvider = Provider.of<PurchaseProvider>(
      context,
      listen: false,
    );
    if (_purchaseProvider != purchaseProvider) {
      _purchaseProvider?.removeListener(_onPurchaseProviderChanged);
      _purchaseProvider = purchaseProvider;
      _purchaseProvider?.addListener(_onPurchaseProviderChanged);
    }
  }

  @override
  void dispose() {
    _purchaseProvider?.removeListener(_onPurchaseProviderChanged);
    super.dispose();
  }

  void _onPurchaseProviderChanged() {
    if (!mounted) return;

    final purchaseProvider = _purchaseProvider;
    if (purchaseProvider != null && purchaseProvider.purchaseSuccess) {
      // Показываем уведомление
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.donationSuccessMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      // Сбрасываем флаг
      purchaseProvider.clearPurchaseSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    // Если продукты загружены и не выбран продукт, выбираем первый доступный
    if (!purchaseProvider.isLoading &&
        purchaseProvider.availableProducts.isNotEmpty &&
        _selectedProduct == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final firstProduct = purchaseProvider.availableProducts.firstWhere(
          (product) =>
              DonationProduct.allProducts.any((dp) => dp.id == product.id),
          orElse: () => purchaseProvider.availableProducts.first,
        );
        setState(() {
          _selectedProduct = firstProduct;
        });
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.lightBackgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Прокручиваемый контент
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // Текст о пожертвовании в рамке (стиль как у арабского текста)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.isDark
                                      ? Colors.black.withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(20, 20),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Фоновый цвет
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: theme.textBackgroundColor,
                                    ),
                                  ),
                                  // Белый прямоугольник с blur эффектом (смещенный)
                                  Positioned(
                                    left: -8,
                                    top: -8,
                                    right: 8,
                                    bottom: 8,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 4,
                                          sigmaY: 4,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: theme.isDark
                                                ? theme.lightBackgroundColor
                                                      .withValues(alpha: 0.9)
                                                : Colors.white.withValues(
                                                    alpha: 0.9,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Градиентный слой с padding
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          theme.gradientTopColor,
                                          theme.lightBackgroundColor,
                                        ],
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        l10n.contributionToApplicationDevelopment,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.textColor,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 68),

                        // Выбор суммы
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                l10n.selectTheAmount,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              _buildAmountSelector(
                                context,
                                purchaseProvider,
                                theme,
                                l10n,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Сообщение об ошибке
                        if (purchaseProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      purchaseProvider.errorMessage!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () =>
                                        purchaseProvider.clearError(),
                                    color: Colors.red[700],
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Кнопка пожертвования (внизу экрана)
          if (purchaseProvider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (purchaseProvider.availableProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                l10n.donationProductsNotAvailable,
                style: TextStyle(fontSize: 14, color: theme.secondaryTextColor),
                textAlign: TextAlign.center,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Opacity(
                opacity: _selectedProduct == null ? 0.5 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _selectedProduct == null
                        ? []
                        : [
                            BoxShadow(
                              color: theme.isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(20, 20),
                              spreadRadius: 0,
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Фоновый цвет
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.textBackgroundColor,
                          ),
                        ),
                        // Белый прямоугольник с blur эффектом (смещенный)
                        Positioned(
                          left: -8,
                          top: -8,
                          right: 8,
                          bottom: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.isDark
                                      ? theme.lightBackgroundColor.withValues(
                                          alpha: 0.9,
                                        )
                                      : Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Градиентный слой с padding
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.gradientTopColor,
                                theme.lightBackgroundColor,
                              ],
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                                  purchaseProvider.isPurchasing ||
                                      _selectedProduct == null
                                  ? null
                                  : () => purchaseProvider.purchaseProduct(
                                      _selectedProduct!,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                alignment: Alignment.center,
                                child: purchaseProvider.isPurchasing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        l10n.donateButton,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedProduct == null
                                              ? theme.secondaryTextColor
                                              : theme.textColor,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountSelector(
    BuildContext context,
    PurchaseProvider purchaseProvider,
    AppTheme theme,
    AppLocalizations l10n,
  ) {
    if (purchaseProvider.isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (purchaseProvider.availableProducts.isEmpty) {
      return Text(
        '-',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.textColor,
        ),
      );
    }

    final availableProducts = purchaseProvider.availableProducts
        .where(
          (product) =>
              DonationProduct.allProducts.any((dp) => dp.id == product.id),
        )
        .toList();

    if (availableProducts.isEmpty) {
      return Text(
        '-',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.textColor,
        ),
      );
    }

    // Сортируем продукты по возрастанию цены
    availableProducts.sort((a, b) {
      final aProduct = DonationProduct.allProducts.firstWhere(
        (dp) => dp.id == a.id,
      );
      final bProduct = DonationProduct.allProducts.firstWhere(
        (dp) => dp.id == b.id,
      );
      return aProduct.amount.compareTo(bProduct.amount);
    });

    // Если продукт не выбран, выбираем первый
    if (_selectedProduct == null ||
        !availableProducts.any((p) => p.id == _selectedProduct!.id)) {
      _selectedProduct = availableProducts.first;
    }

    return GestureDetector(
      onTap: () =>
          _showProductSelector(context, availableProducts, theme, l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.isDark ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.isDark
                ? const Color(0xFF4A5568)
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedProduct?.price ?? '-',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4D99E6), // Фиксированный синий цвет
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF4D99E6), // Фиксированный синий цвет
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSelector(
    BuildContext context,
    List<ProductDetails> availableProducts,
    AppTheme theme,
    AppLocalizations l10n,
  ) {
    // Сортируем продукты по возрастанию цены
    final sortedProducts = List<ProductDetails>.from(availableProducts);
    sortedProducts.sort((a, b) {
      final aProduct = DonationProduct.allProducts.firstWhere(
        (dp) => dp.id == a.id,
      );
      final bProduct = DonationProduct.allProducts.firstWhere(
        (dp) => dp.id == b.id,
      );
      return aProduct.amount.compareTo(bProduct.amount);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.lightBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.selectTheAmount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: sortedProducts.length,
              itemBuilder: (context, index) {
                final product = sortedProducts[index];
                final isSelected = _selectedProduct?.id == product.id;

                return ListTile(
                  title: Text(
                    product.price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: theme.textColor,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: theme.primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedProduct = product;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
