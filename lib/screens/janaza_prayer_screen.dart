import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class JanazaPrayerScreen extends StatefulWidget {
  const JanazaPrayerScreen({super.key});

  @override
  State<JanazaPrayerScreen> createState() => _JanazaPrayerScreenState();
}

class _JanazaPrayerScreenState extends State<JanazaPrayerScreen> {
  bool _isSecondTakbirExpanded = false;
  bool _isThirdTakbirExpanded = false;
  bool _isDuaVariationsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.titleJanazaGuide,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              _buildSection(
                title: l10n.basicRules,
                content: l10n.janazaBasicRules,
              ),
              const Divider(),
              _buildTakbirSection(
                l10n: l10n,
                title: l10n.firstTakbirTitle,
                content: l10n.firstTakbirText,
              ),
              const Divider(),
              _buildTakbirSection(
                l10n: l10n,
                title: l10n.secondTakbirTitle,
                content: l10n.secondTakbirText,
                isExpandable: true,
                isExpanded: _isSecondTakbirExpanded,
                expandedContent: l10n.translateSecondTakbirText,
                onExpandedChanged: (value) {
                  setState(() {
                    _isSecondTakbirExpanded = value;
                  });
                },
              ),
              const Divider(),
              _buildTakbirSection(
                l10n: l10n,
                title: l10n.thirdTakbirTitle,
                content: l10n.thirdTakbirText,
                isExpandable: true,
                isExpanded: _isThirdTakbirExpanded,
                expandedContent: l10n.translateThirdTakbirText,
                onExpandedChanged: (value) {
                  setState(() {
                    _isThirdTakbirExpanded = value;
                  });
                },
              ),
              const Divider(),
              _buildTakbirSection(
                l10n: l10n,
                title: l10n.fourthTakbirTitle,
                content: l10n.fourthTakbirText,
              ),
              const Divider(),
              if (l10n.fourthTakbirAdditionalInfo.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    l10n.fourthTakbirAdditionalInfo,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const Divider(),
              ],
              _buildSection(
                title: l10n.taslimTitle,
                content: l10n.taslimText,
              ),
              const Divider(),
              _buildCollapsibleSection(
                l10n: l10n,
                title: l10n.duaVariationsTitle,
                content: l10n.duaVariationsText,
                isExpanded: _isDuaVariationsExpanded,
                onExpandedChanged: (value) {
                  setState(() {
                    _isDuaVariationsExpanded = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsibleSection({
    required AppLocalizations l10n,
    required String title,
    required String content,
    bool isExpanded = false,
    ValueChanged<bool>? onExpandedChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpandedChanged,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTakbirSection({
    required AppLocalizations l10n,
    required String title,
    required String content,
    bool isExpandable = false,
    bool isExpanded = false,
    String? expandedContent,
    ValueChanged<bool>? onExpandedChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
          textDirection: TextDirection.ltr,
        ),
        if (isExpandable && expandedContent != null) ...[
          const SizedBox(height: 8),
          ExpansionTile(
            title: Text(
              l10n.translateText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            initiallyExpanded: isExpanded,
            onExpansionChanged: onExpandedChanged,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  expandedContent,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
