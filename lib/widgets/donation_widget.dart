import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/platform_icons.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/purchase_provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../models/donation_product.dart';
import '../utils/donation_error_helper.dart';
import '../theme/app_type.dart';
import 'app_card.dart';

/// Виджет для отображения вариантов пожертвований
class DonationWidget extends StatefulWidget {
  const DonationWidget({super.key});

  @override
  State<DonationWidget> createState() => _DonationWidgetState();
}

class _DonationWidgetState extends State<DonationWidget> {
  ProductDetails? _selectedProduct;
  PurchaseProvider? _purchaseProvider;
  bool _hasShownSuccessMessage = false;

  static const double _cardRadius = 18;

  List<BoxShadow> _shadows(AppTheme theme) => [
    BoxShadow(
      color: theme.isDark
          ? Colors.black.withValues(alpha: 0.2)
          : Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final purchaseProvider = Provider.of<PurchaseProvider>(
      context,
      listen: false,
    );
    if (_purchaseProvider != purchaseProvider) {
      _purchaseProvider?.removeListener(_onPurchaseProviderChanged);
      _purchaseProvider = purchaseProvider;
      _purchaseProvider?.addListener(_onPurchaseProviderChanged);
      _hasShownSuccessMessage = false;
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
    if (purchaseProvider != null &&
        purchaseProvider.purchaseSuccess &&
        !_hasShownSuccessMessage) {
      _hasShownSuccessMessage = true;
      final l10n = AppLocalizations.of(context)!;
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final theme = themeProvider.selectedTheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.donationSuccessMessage),
          backgroundColor: theme.successColor,
          duration: const Duration(seconds: 3),
        ),
      );
      purchaseProvider.clearPurchaseSuccess();
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          _hasShownSuccessMessage = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    // Если продукты загружены и не выбран продукт, выбираем самый дешёвый.
    if (!purchaseProvider.isLoading &&
        purchaseProvider.availableProducts.isNotEmpty &&
        _selectedProduct == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Только наши продукты, отсортированные по возрастанию цены (amount) —
        // как в _buildAmountSelector / _showProductSelector. Порядок из стора
        // не отсортирован, поэтому «первый доступный» мог оказаться дорогим
        // (99 € вместо 99 ¢). Через .where() без orElse-замыкания заодно не
        // возникает проблема типов StoreKit 2 (List<AppStoreProduct2Details>).
        final products =
            purchaseProvider.availableProducts
                .where(
                  (product) => DonationProduct.allProducts.any(
                    (dp) => dp.id == product.id,
                  ),
                )
                .toList()
              ..sort((a, b) {
                final aAmount = DonationProduct.allProducts
                    .firstWhere((dp) => dp.id == a.id)
                    .amount;
                final bAmount = DonationProduct.allProducts
                    .firstWhere((dp) => dp.id == b.id)
                    .amount;
                return aAmount.compareTo(bAmount);
              });
        if (products.isEmpty) return;
        setState(() {
          _selectedProduct = products.first;
        });
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.backgroundColor),
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

                        // Текст о пожертвовании — стиль как в настройках
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: AppCard(
                            theme: theme,
                            cornerRadius: _cardRadius,
                            shadows: _shadows(theme),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                l10n.contributionToApplicationDevelopment,
                                style: TextStyle(
                                  fontSize: AppType.of(context).caption,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textColor,
                                  height: 1.5,
                                ),
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
                              Flexible(
                                child: Text(
                                  l10n.selectTheAmount,
                                  style: TextStyle(
                                    fontSize: AppType.of(context).caption,
                                    color: theme.textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
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
                        if (purchaseProvider.errorCode != null)
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
                                    PlatformIcons.errorOutline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DonationErrorHelper.getLocalizedErrorMessage(
                                        purchaseProvider.errorCode,
                                        l10n,
                                      ),
                                      style: TextStyle(
                                        fontSize: AppType.of(context).caption,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(PlatformIcons.close, size: 18),
                                    tooltip: l10n.close,
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
                style: TextStyle(
                  fontSize: AppType.of(context).caption,
                  color: theme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AppCard(
                theme: theme,
                cornerRadius: _cardRadius,
                shadows: _shadows(theme),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        purchaseProvider.isPurchasing ||
                            purchaseProvider.isPurchasePending
                        ? null
                        : () {
                            if (_selectedProduct != null) {
                              purchaseProvider.purchaseProduct(
                                _selectedProduct!,
                              );
                            }
                          },
                    borderRadius: BorderRadius.circular(_cardRadius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child:
                          purchaseProvider.isPurchasing ||
                              purchaseProvider.isPurchasePending
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                if (purchaseProvider.isPurchasePending) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.donationProcessing,
                                    style: TextStyle(
                                      fontSize: AppType.of(context).caption,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textColor,
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : Text(
                              l10n.donateButton,
                              style: TextStyle(
                                fontSize: AppType.of(context).callout,
                                fontWeight: FontWeight.w600,
                                color: theme.textColor,
                              ),
                            ),
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
          fontSize: AppType.of(context).callout,
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
          fontSize: AppType.of(context).callout,
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
          color: theme.isDark ? theme.lightBackgroundColor : Colors.white,
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
              style: TextStyle(
                fontSize: AppType.of(context).callout,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4D99E6),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.expand_more_rounded,
              color: Color(0xFF4D99E6),
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
      isScrollControlled: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
        final maxHeight = MediaQuery.of(context).size.height * 0.8;

        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: theme.isEmerald ? null : theme.lightBackgroundColor,
            gradient: theme.cardGradient,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
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
                    fontSize: AppType.of(context).body,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortedProducts.length,
                  itemBuilder: (context, index) {
                    final product = sortedProducts[index];
                    final isSelected = _selectedProduct?.id == product.id;

                    return ListTile(
                      title: Text(
                        product.price,
                        style: TextStyle(
                          fontSize: AppType.of(context).callout,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: theme.textColor,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(PlatformIcons.check, color: theme.primaryColor)
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
              ),
              SizedBox(height: 16 + bottomPadding),
            ],
          ),
        );
      },
    );
  }
}
