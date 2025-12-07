import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/purchase_provider.dart';
import '../widgets/donation_widget.dart';

/// Экран пожертвований
class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  @override
  void initState() {
    super.initState();
    // Инициализируем сервис покупок при открытии экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final purchaseProvider = Provider.of<PurchaseProvider>(
        context,
        listen: false,
      );
      purchaseProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.donationScreenTitle,
          style: TextStyle(color: theme.textColor),
        ),
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.donationScreenTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Виджет пожертвований
              const DonationWidget(),

              // Информация о пожертвованиях
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.donationInfo,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
