import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/platform_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_card.dart';
import '../theme/app_type.dart';

class CounterTapWidget extends StatefulWidget {
  final String prefsKey;
  final String? titleString;
  final String? labelString;
  final String? finishedString;
  final IconData? icon;

  const CounterTapWidget({
    super.key,
    this.prefsKey = 'tawaf_counter',
    this.titleString,
    this.labelString,
    this.finishedString,
    this.icon,
  });

  @override
  State<CounterTapWidget> createState() => _CounterTapWidgetState();
}

class _CounterTapWidgetState extends State<CounterTapWidget> {
  static const int _target = 7;

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = prefs.getInt(widget.prefsKey) ?? 0;
    if (mounted) setState(() => _counter = loaded);
  }

  Future<void> _saveCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(widget.prefsKey, value);
  }

  Future<void> _increment() async {
    if (_counter >= _target) return;
    setState(() => _counter++);
    await _saveCounter(_counter);
    _vibrate(_counter == _target ? 100 : 50);
  }

  Future<void> _reset() async {
    if (_counter == 0) return;
    setState(() => _counter = 0);
    await _saveCounter(0);
    _vibrate(40);
  }

  Future<void> _vibrate(int ms) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: ms);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final type = AppType.of(context);

    final isCompleted = _counter >= _target;
    final statusColor = isCompleted ? theme.secondaryColor : theme.primaryColor;
    final statusBg = statusColor.withValues(alpha: theme.isDark ? 0.20 : 0.12);
    final cardRadius = isTablet ? 30.0 : 24.0;
    final hPad = isTablet ? 28.0 : 22.0;
    final vPad = isTablet ? 26.0 : 20.0;
    final buttonHeight = isTablet ? 60.0 : 54.0;
    final circleSize = isTablet ? 34.0 : 28.0;

    final label = widget.labelString ?? l10n.circleString;
    final finished = widget.finishedString ?? l10n.sayFinishedString;
    final title = widget.titleString;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: AppCard(
        theme: theme,
        cornerRadius: cardRadius,
        shadows: [
          BoxShadow(
            color: theme.cardShadowColor,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Заголовок + счётчик X/7 ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null) ...[
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: type.callout,
                              fontWeight: FontWeight.w600,
                              color: theme.textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        // Статусная капсула
                        _StatusCapsule(
                          icon: isCompleted
                              ? PlatformIcons.checkCircle
                              : (widget.icon ?? PlatformIcons.rotateRight),
                          label: isCompleted ? finished : label,
                          color: statusColor,
                          background: statusBg,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Счётчик X/7
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 14 : 12,
                      vertical: isTablet ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$_counter/$_target',
                      style: TextStyle(
                        fontSize: type.section,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 14 : 10),

              // ── Кружки прогресса (фиксированный размер 28pt, spacing 6pt) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_target, (i) {
                  final done = i < _counter;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 4 : 3),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: done
                            ? LinearGradient(
                                colors: [
                                  theme.primaryColor,
                                  isCompleted
                                      ? theme.secondaryColor
                                      : theme.primaryColor.withValues(
                                          alpha: 0.85,
                                        ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: done ? null : theme.lightBackgroundColor,
                        border: done
                            ? null
                            : Border.all(color: theme.borderColor, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: type.overline,
                            fontWeight: FontWeight.w700,
                            color: done
                                ? Colors.white
                                : theme.textColor.withValues(alpha: 0.66),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: isTablet ? 14 : 10),

              // ── Кнопки ──
              Row(
                children: [
                  // Кнопка "Добавить" — градиентная капсула
                  Expanded(
                    child: GestureDetector(
                      onTap: isCompleted ? null : _increment,
                      child: AnimatedOpacity(
                        opacity: isCompleted ? 0.5 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          height: buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              buttonHeight / 2,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withValues(alpha: 0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: isCompleted
                                ? []
                                : [
                                    BoxShadow(
                                      color: theme.primaryColor.withValues(
                                        alpha: 0.24,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: _iconLabelRow(
                            context: context,
                            icon: isCompleted
                                ? PlatformIcons.checkCircle
                                : PlatformIcons.addCircle,
                            iconColor: Colors.white,
                            iconSize: 20,
                            label: l10n.addString,
                            labelStyle: TextStyle(
                              fontSize: type.caption,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 14 : 10),
                  // Кнопка "Сбросить" — карточный стиль
                  Expanded(
                    child: GestureDetector(
                      onTap: _counter == 0 ? null : _reset,
                      child: AnimatedOpacity(
                        opacity: _counter == 0 ? 0.4 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          height: buttonHeight,
                          decoration: BoxDecoration(
                            color: theme.lightBackgroundColor,
                            borderRadius: BorderRadius.circular(
                              buttonHeight / 2,
                            ),
                            border: Border.all(
                              color: theme.borderColor.withValues(
                                alpha: _counter == 0 ? 0.7 : 1.0,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.cardShadowColor,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _iconLabelRow(
                            context: context,
                            icon: PlatformIcons.refresh,
                            iconColor: theme.textColor,
                            iconSize: 18,
                            label: l10n.resetString,
                            labelStyle: TextStyle(
                              fontSize: type.caption,
                              fontWeight: FontWeight.w600,
                              color: theme.textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Показывает иконку с подписью, если подпись помещается по ширине,
  // иначе — только иконку (чтобы крупный системный шрифт не ломал раскладку).
  Widget _iconLabelRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required double iconSize,
    required String label,
    required TextStyle labelStyle,
  }) {
    const spacing = 8.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final fits = iconSize + spacing + textPainter.width <= constraints.maxWidth;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            if (fits) ...[
              const SizedBox(width: spacing),
              Text(label, style: labelStyle, maxLines: 1),
            ],
          ],
        );
      },
    );
  }
}

class _StatusCapsule extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  const _StatusCapsule({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppType.of(context).caption,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
