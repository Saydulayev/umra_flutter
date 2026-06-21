import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../utils/responsive_metrics.dart';
import '../theme/app_type.dart';

/// Сегментированный контрол в неоморфном стиле
class IOSSegmentedControl<T> extends StatelessWidget {
  final List<SegmentItem<T>> segments;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final AppTheme? theme;

  const IOSSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onValueChanged,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.theme,
  });

  /// Получить градиент для внешнего контейнера в зависимости от темы
  List<Color> _getContainerGradient() {
    if (theme == null) {
      return [const Color(0xFFe8ecf4), const Color(0xFFf5f8fc)];
    }

    if (theme!.isDark) {
      return [const Color(0xFF2D3748), const Color(0xFF1F2937)];
    }

    // Легкие, не яркие цвета для светлых тем - используем более приглушенные версии
    final baseColor = theme!.gradientTopColor;
    final lightColor = theme!.lightBackgroundColor;

    // Делаем цвета менее насыщенными, смешивая с белым
    return [
      Color.lerp(baseColor, Colors.white, 0.4) ?? baseColor,
      Color.lerp(lightColor, Colors.white, 0.3) ?? lightColor,
    ];
  }

  /// Получить градиент для активного сегмента в зависимости от темы
  List<Color> _getActiveGradient() {
    if (theme == null) {
      return [const Color(0xFFffffff), const Color(0xFFf0f4fa)];
    }

    if (theme!.isDark) {
      return [const Color(0xFF374151), const Color(0xFF1F2937)];
    }

    // Легкий белый градиент для активного сегмента
    return [Colors.white, theme!.lightBackgroundColor];
  }

  /// Получить цвет темной тени в зависимости от темы
  Color _getDarkShadowColor() {
    if (theme == null) {
      return const Color(0xFFc5cdd9);
    }

    if (theme!.isDark) {
      return Colors.black.withValues(alpha: 0.6);
    }

    // Более темная тень на основе цвета темы для лучшей видимости
    return theme!.backgroundColor.withValues(alpha: 0.8);
  }

  /// Получить цвет обводки для активного сегмента
  Color _getActiveBorderColor() {
    if (theme == null) {
      return const Color(0xFF8E9AAF);
    }

    if (theme!.isDark) {
      return Colors.white.withValues(alpha: 0.3);
    }

    // Темная обводка на основе цвета темы
    return theme!.backgroundColor.withValues(alpha: 0.7);
  }

  /// Получить цвет светлой тени в зависимости от темы
  Color _getLightShadowColor() {
    if (theme == null) {
      return const Color(0xFFffffff);
    }

    if (theme!.isDark) {
      return Colors.white.withValues(alpha: 0.05);
    }

    // Легкая светлая тень
    return Colors.white.withValues(alpha: 0.9);
  }

  /// Получить цвет для активного сегмента
  Color _getActiveColor() {
    if (activeColor != null) return activeColor!;
    return const Color(0xFF007AFF); // Синий цвет
  }

  /// Получить цвет для неактивного сегмента
  Color _getInactiveColor() {
    if (inactiveColor != null) return inactiveColor!;
    return const Color(0xFF000000); // Черный цвет
  }

  @override
  Widget build(BuildContext context) {
    final activeIconColor = _getActiveColor();
    final inactiveIconColor = _getInactiveColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getContainerGradient(),
        ),
        boxShadow: [
          BoxShadow(
            color: _getDarkShadowColor(),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          // Убираем светлую тень, чтобы убрать белое свечение
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments.map((segment) {
          final isSelected = segment.value == selectedValue;
          final iconColor = isSelected ? activeIconColor : inactiveIconColor;

          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(segment.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getActiveGradient(),
                        )
                      : null,
                  border: isSelected
                      ? Border.all(color: _getActiveBorderColor(), width: 1.5)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getDarkShadowColor(),
                            offset: const Offset(4, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: _getLightShadowColor(),
                            offset: const Offset(-4, -4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Иконка (буква в круге)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          segment.icon,
                          style: TextStyle(
                            color: Colors.white,
                            // Глиф в фиксированном круге 36pt — масштабируем
                            // общим fontScale.
                            fontSize: ResponsiveMetrics.of(context).scaled(18),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Текст
                    Flexible(
                      child: Text(
                        segment.label,
                        style: TextStyle(
                          fontSize: AppType.of(context).caption,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lato',
                          color: theme?.isDark == true
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF000000),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Элемент сегмента
class SegmentItem<T> {
  final T value;
  final String label;
  final String icon;

  const SegmentItem({
    required this.value,
    required this.label,
    required this.icon,
  });
}
