import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.privacyPolicyTitle,
          style: TextStyle(color: theme.textColor),
        ),
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.privacyPolicyLastUpdated,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.privacyPolicyIntroductionTitle,
                content: l10n.privacyPolicyIntroduction,
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.privacyPolicyDataCollectionTitle,
                content: l10n.privacyPolicyDataCollection,
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.privacyPolicyDataUsageTitle,
                content: l10n.privacyPolicyDataUsage,
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.privacyPolicyThirdPartyTitle,
                content: l10n.privacyPolicyThirdParty,
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.privacyPolicyDataStorageTitle,
                content: l10n.privacyPolicyDataStorage,
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.privacyPolicyUserRightsTitle,
                content: l10n.privacyPolicyUserRights,
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.privacyPolicyChildrenTitle,
                content: l10n.privacyPolicyChildren,
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.privacyPolicyChangesTitle,
                content: l10n.privacyPolicyChanges,
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.privacyPolicyContactTitle,
                content: l10n.privacyPolicyContact,
                theme: theme,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required AppTheme theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }
}
