import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';
import '../utils/platform_icons.dart';
import '../widgets/arabic_text_widget.dart';
import '../utils/responsive_metrics.dart';

const Color _accentGreen = Color(0xFF10B981);

bool _isLongArabicLine(String s) {
  final trimmed = s.trim();
  if (trimmed.length < 28) return false;
  final first = trimmed.runes.firstOrNull;
  if (first == null) return false;
  if (!((first >= 0x0600 && first <= 0x06FF) ||
      (first >= 0x0750 && first <= 0x077F))) {
    return false;
  }
  // Reject lines that contain Latin or Cyrillic — those are mixed transliteration lines
  for (final rune in trimmed.runes) {
    if ((rune >= 0x0041 && rune <= 0x007A) || // Latin A-z
        (rune >= 0x0400 && rune <= 0x04FF)) {
      // Cyrillic
      return false;
    }
  }
  return true;
}

class JanazaPrayerScreen extends StatefulWidget {
  const JanazaPrayerScreen({super.key});

  @override
  State<JanazaPrayerScreen> createState() => _JanazaPrayerScreenState();
}

class _JanazaPrayerScreenState extends State<JanazaPrayerScreen> {
  bool _isSecondTakbirExpanded = false;
  bool _isThirdTakbirExpanded = false;
  bool _isDuaVariationsExpanded = false;

  ResponsiveMetrics get _metrics => ResponsiveMetrics.of(context);

  Widget _buildSectionDivider(AppTheme theme) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Divider(color: theme.secondaryTextColor.withValues(alpha: 0.25)),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildArabicAwareText(String text, Color color) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final hasArabic = lines.any(_isLongArabicLine);
    if (!hasArabic) {
      return Text(
        text,
        style: TextStyle(
          fontSize: _metrics.listFontSize,
          color: color,
          height: 1.7,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines.length; i++) ...[
          if (_isLongArabicLine(lines[i]))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: ArabicTextWidget(
                text: lines[i],
                addHorizontalPadding: false,
              ),
            )
          else
            Text(
              lines[i],
              style: TextStyle(
                fontSize: _metrics.listFontSize,
                color: color,
                height: 1.7,
              ),
            ),
          if (i < lines.length - 1 && !_isLongArabicLine(lines[i]))
            const SizedBox(height: 8),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.titleJanazaGuide,
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor),
        ),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          final metrics = ResponsiveMetrics.of(context);
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 20, bottom: bottomPadding + 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.listScreenHPad,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        title: l10n.basicRules,
                        content: l10n.janazaBasicRules,
                        textColor: theme.textColor,
                        theme: theme,
                      ),
                      _buildSectionDivider(theme),
                      _buildTakbirSection(
                        l10n: l10n,
                        title: l10n.firstTakbirTitle,
                        content: l10n.firstTakbirText,
                        textColor: theme.textColor,
                        accentColor: _accentGreen,
                        theme: theme,
                      ),
                      _buildSectionDivider(theme),
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
                        textColor: theme.textColor,
                        accentColor: _accentGreen,
                        theme: theme,
                      ),
                      _buildSectionDivider(theme),
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
                        textColor: theme.textColor,
                        accentColor: _accentGreen,
                        theme: theme,
                      ),
                      _buildSectionDivider(theme),
                      _buildTakbirSection(
                        l10n: l10n,
                        title: l10n.fourthTakbirTitle,
                        content: l10n.fourthTakbirText,
                        textColor: theme.textColor,
                        accentColor: _accentGreen,
                        theme: theme,
                      ),
                      if (l10n.fourthTakbirAdditionalInfo.isNotEmpty) ...[
                        _buildSectionDivider(theme),
                        Text(
                          l10n.fourthTakbirAdditionalInfo,
                          style: TextStyle(
                            fontSize: _metrics.captionFontSize,
                            color: theme.textColor,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      _buildSectionDivider(theme),
                      _buildSection(
                        title: l10n.taslimTitle,
                        content: l10n.taslimText,
                        textColor: theme.textColor,
                        theme: theme,
                      ),
                      _buildSectionDivider(theme),
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
                        textColor: theme.textColor,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    Color? textColor,
    required AppTheme theme,
  }) {
    final color = textColor ?? Colors.black87;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _metrics.sectionTitleFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        _buildArabicAwareText(content, color),
      ],
    );
  }

  Widget _buildCollapsibleSection({
    required AppLocalizations l10n,
    required String title,
    required String content,
    bool isExpanded = false,
    ValueChanged<bool>? onExpandedChanged,
    Color? textColor,
    required AppTheme theme,
  }) {
    final color = textColor ?? Colors.black87;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onExpandedChanged?.call(!isExpanded),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: _metrics.sectionTitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(PlatformIcons.expandMore, color: color, size: 24),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: _buildArabicAwareText(content, color),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
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
    Color? textColor,
    Color? accentColor,
    required AppTheme theme,
  }) {
    final color = textColor ?? Colors.black87;
    final accent = accentColor ?? Colors.blue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _metrics.sectionTitleFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        _buildArabicAwareText(content, color),
        if (isExpandable &&
            expandedContent != null &&
            expandedContent.isNotEmpty) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => onExpandedChanged?.call(!isExpanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    l10n.translateText,
                    style: TextStyle(
                      fontSize: _metrics.captionFontSize,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      PlatformIcons.expandMore,
                      color: accent,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: _buildArabicAwareText(expandedContent, color),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ],
    );
  }
}
