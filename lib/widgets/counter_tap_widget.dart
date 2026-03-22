import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class CounterTapWidget extends StatefulWidget {
  final String prefsKey;
  final String? titleString;
  final String? labelString;
  final String? finishedString;
  final IconData icon;

  const CounterTapWidget({
    super.key,
    this.prefsKey = 'tawaf_counter',
    this.titleString,
    this.labelString,
    this.finishedString,
    this.icon = Icons.rotate_right,
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

    final isCompleted = _counter >= _target;
    final statusColor = isCompleted ? theme.secondaryColor : theme.primaryColor;
    final statusBg = statusColor.withValues(
      alpha: theme.isDark ? 0.20 : 0.12,
    );
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: theme.isEmerald ? null : theme.lightBackgroundColor,
          gradient: theme.cardGradient,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: theme.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.cardShadowColor,
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
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
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: theme.textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      // Статусная капсула
                      _StatusCapsule(
                        icon: isCompleted ? Icons.check_circle : widget.icon,
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
                      fontSize: isTablet ? 22 : 19,
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
                                    : theme.primaryColor.withValues(alpha: 0.85),
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
                          fontSize: isTablet ? 13 : 11,
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
                          borderRadius: BorderRadius.circular(buttonHeight / 2),
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
                                    color: theme.primaryColor
                                        .withValues(alpha: 0.24),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : Icons.add_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.addString,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
                          borderRadius:
                              BorderRadius.circular(buttonHeight / 2),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              color: theme.textColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.resetString,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: theme.textColor,
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
          ],
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
                fontSize: 14,
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
