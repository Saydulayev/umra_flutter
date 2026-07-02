import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/platform_icons.dart';
import '../providers/purchase_provider.dart';
import '../widgets/donation_widget.dart';

/// Функция для показа полноэкранного окна пожертвований
void showDonationBottomSheet(BuildContext context) {
  // Инициализируем сервис покупок при открытии окна
  final purchaseProvider = Provider.of<PurchaseProvider>(
    context,
    listen: false,
  );
  purchaseProvider.initialize();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DonationScreen(),
      fullscreenDialog: true,
    ),
  );
}

/// Экран пожертвований (для обратной совместимости)
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

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PlatformIcons.arrowBack, color: theme.textColor),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: const DonationWidget(),
          );
        },
      ),
    );
  }
}
