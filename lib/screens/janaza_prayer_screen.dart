import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../models/app_theme.dart';

const Color _accentGreen = Color(0xFF10B981);

bool _isLongArabicLine(String s) {
  final trimmed = s.trim();
  if (trimmed.length < 40) return false;
  final first = trimmed.runes.firstOrNull;
  if (first == null) return false;
  return (first >= 0x0600 && first <= 0x06FF) || (first >= 0x0750 && first <= 0x077F);
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

  Widget _buildArabicAwareText(String text, Color color, AppTheme theme) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final hasArabic = lines.any(_isLongArabicLine);
    if (!hasArabic) {
      return Text(text, style: TextStyle(fontSize: 17, color: color, height: 1.6));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines.length; i++) ...[
          if (_isLongArabicLine(lines[i]))
            Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.isEmerald ? null : theme.lightBackgroundColor,
                      gradient: theme.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: theme.cardShadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      lines[i],
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      locale: const Locale('ar'),
                      style: TextStyle(
                        fontFamily: 'KFGQPCUthmanTahaNaskh',
                        fontFamilyFallback: const [
                          'Scheherazade New',
                          'Amiri',
                          'Arial'
                        ],
                        fontSize: 26,
                        color: theme.textColor,
                        height: 1.7,
                      ),
                    ),
                  )
          else
            Text(
              lines[i],
              style: TextStyle(fontSize: 17, color: color, height: 1.6),
            ),
          if (i < lines.length - 1 && !_isLongArabicLine(lines[i]))
            const SizedBox(height: 6),
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
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 16,
              bottom: bottomPadding + 16,
              left: 16,
              right: 16,
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
                Divider(color: theme.secondaryTextColor.withValues(alpha: 0.3)),
                _buildTakbirSection(
                  l10n: l10n,
                  title: l10n.firstTakbirTitle,
                  content: l10n.firstTakbirText,
                  textColor: theme.textColor,
                  accentColor: _accentGreen,
                  theme: theme,
                ),
                Divider(color: theme.secondaryTextColor.withValues(alpha: 0.3)),
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
                Divider(color: theme.secondaryTextColor.withValues(alpha: 0.3)),
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
                Divider(color: theme.secondaryTextColor.withValues(alpha: 0.3)),
                _buildTakbirSection(
                  l10n: l10n,
                  title: l10n.fourthTakbirTitle,
                  content: l10n.fourthTakbirText,
                  textColor: theme.textColor,
                  accentColor: _accentGreen,
                  theme: theme,
                ),
                Divider(color: theme.secondaryTextColor.withValues(alpha: 0.3)),
                if (l10n.fourthTakbirAdditionalInfo.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      l10n.fourthTakbirAdditionalInfo,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textColor,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Divider(
                    color: theme.secondaryTextColor.withValues(alpha: 0.3),
                  ),
                ],
                _buildSection(
                  title: l10n.taslimTitle,
                  content: l10n.taslimText,
                  textColor: theme.textColor,
                  theme: theme,
                ),
                Divider(color: theme.secondaryTextColor.withValues(alpha: 0.3)),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        _buildArabicAwareText(content, color, theme),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.expand_more, color: color, size: 24),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: _buildArabicAwareText(content, color, theme),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        _buildArabicAwareText(content, color, theme),
        if (isExpandable && expandedContent != null) ...[
          const SizedBox(height: 8),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, color: accent, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: _buildArabicAwareText(expandedContent, color, theme),
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
