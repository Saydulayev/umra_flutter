import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/platform_icons.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../repositories/preferences_repository.dart';
import '../widgets/app_card.dart';
import '../theme/app_type.dart';

/// Счётчик кругов тавафа / проходов сая (0..7).
///
/// UX-решения (по аудиту):
/// - тап по любому месту карточки = +1 (во время тавафа удобнее, чем целиться
///   в кнопку одной рукой в толпе); кнопки перехватывают свои тапы сами;
/// - сброс — только через подтверждение (стоит рядом с «+1», случайный тап
///   на 6-м круге не должен стирать прогресс);
/// - цвета текста на акцентных заливках — через контрастные токены темы
///   (onPrimaryColor/onSecondaryColor/…AccentTextColor), см. app_theme.dart:
///   белый на mint/золоте не читается (~2:1), критично на солнце.
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

  final _prefsRepo = PreferencesRepository();
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final loaded = await _prefsRepo.getInt(widget.prefsKey) ?? 0;
    if (mounted) setState(() => _counter = loaded);
  }

  Future<void> _saveCounter(int value) async {
    await _prefsRepo.setInt(widget.prefsKey, value);
  }

  Future<void> _increment() async {
    if (_counter >= _target) return;
    setState(() => _counter++);
    await _saveCounter(_counter);
    // Завершение — ощутимо сильнее обычного шага.
    if (_counter == _target) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _confirmReset() async {
    if (_counter == 0) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.counterResetConfirmTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.feedbackDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.resetString),
          ),
        ],
      ),
    );
    if (confirmed == true) await _reset();
  }

  Future<void> _reset() async {
    if (_counter == 0) return;
    setState(() => _counter = 0);
    await _saveCounter(0);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final type = AppType.of(context);

    final isCompleted = _counter >= _target;
    // Заливки — яркими акцентами темы; текст на тонированной подложке —
    // контрастными текстовыми токенами (в nur золото/зелёный затемнены).
    final fillColor = isCompleted ? theme.secondaryColor : theme.primaryColor;
    final accentText = isCompleted
        ? theme.goldAccentTextColor
        : theme.primaryAccentTextColor;
    final statusBg = fillColor.withValues(alpha: theme.isDark ? 0.20 : 0.12);
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
      // Тап по карточке = +1: во время тавафа проще, чем целиться в кнопку.
      // Из semantics исключён — действие уже озвучивается кнопкой «Добавить»,
      // дублирующий tap-узел без label только мешал бы скринридеру.
      child: GestureDetector(
        onTap: isCompleted ? null : _increment,
        excludeFromSemantics: true,
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
                            color: accentText,
                            background: statusBg,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Счётчик X/7. liveRegion: скринридер озвучивает каждое
                    // изменение — можно считать круги не глядя на экран.
                    Semantics(
                      liveRegion: true,
                      label: isCompleted ? finished : label,
                      value: '$_counter/$_target',
                      child: Container(
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
                            color: accentText,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 14 : 10),

                // ── Кружки прогресса (декоративные: инфо дублируется X/7) ──
                ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_target, (i) {
                      final done = i < _counter;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 4 : 3,
                        ),
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
                                : Border.all(
                                    color: theme.borderColor,
                                    width: 1,
                                  ),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: type.overline,
                                fontWeight: FontWeight.w700,
                                // На градиенте к золоту (завершение) тёмный
                                // текст читается на обеих половинах градиента;
                                // белый на золоте — нет (~2:1).
                                color: done
                                    ? (isCompleted
                                          ? theme.onSecondaryColor
                                          : theme.onPrimaryColor)
                                    : theme.textColor.withValues(alpha: 0.66),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(height: isTablet ? 14 : 10),

                // ── Кнопки: [Добавить] [−1] [Сбросить] ──
                Row(
                  children: [
                    // «Добавить» — градиентная капсула
                    Expanded(
                      child: _CapsuleButton(
                        onTap: isCompleted ? null : _increment,
                        semanticLabel: l10n.addString,
                        height: buttonHeight,
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shadows: isCompleted
                            ? const []
                            : [
                                BoxShadow(
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.24,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                        child: _iconLabelRow(
                          context: context,
                          icon: isCompleted
                              ? PlatformIcons.checkCircle
                              : PlatformIcons.addCircle,
                          iconColor: theme.onPrimaryColor,
                          iconSize: 20,
                          label: l10n.addString,
                          labelStyle: TextStyle(
                            fontSize: type.caption,
                            fontWeight: FontWeight.w600,
                            color: theme.onPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 14 : 10),
                    // «Сбросить» — только через подтверждение
                    Expanded(
                      child: _CapsuleButton(
                        onTap: _counter == 0 ? null : _confirmReset,
                        semanticLabel: l10n.resetString,
                        height: buttonHeight,
                        color: theme.lightBackgroundColor,
                        border: Border.all(color: theme.borderColor, width: 1),
                        shadows: [
                          BoxShadow(
                            color: theme.cardShadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                  ],
                ),
              ],
            ),
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
        final fits =
            iconSize + spacing + textPainter.width <= constraints.maxWidth;

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

/// Капсульная кнопка счётчика: ink-отклик на нажатие, корректные semantics
/// (button + enabled) и приглушение в выключенном состоянии.
class _CapsuleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String semanticLabel;
  final double height;
  final Gradient? gradient;
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow> shadows;
  final Widget child;

  const _CapsuleButton({
    required this.onTap,
    required this.semanticLabel,
    required this.height,
    required this.child,
    this.gradient,
    this.color,
    this.border,
    this.shadows = const [],
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 200),
        // Тень — на внешнем контейнере: Ink рисует decoration на Material,
        // и boxShadow там обрезается.
        child: Container(
          decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                color: color,
                border: border,
                borderRadius: radius,
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                // Содержимое исключено из semantics: label даёт Semantics
                // выше (иначе подпись читалась бы дважды, а в icon-only
                // режиме _iconLabelRow не читалась бы вовсе).
                child: ExcludeSemantics(
                  child: SizedBox(
                    height: height,
                    child: Center(child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
