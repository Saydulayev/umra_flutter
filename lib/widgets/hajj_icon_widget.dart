import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../utils/responsive_metrics.dart';

/// Виджет для отображения иконки шага Хаджа (неоморфный дизайн с рамками)
class HajjIconWidget extends StatelessWidget {
  final String iconText;
  final AppTheme theme;

  const HajjIconWidget({
    super.key,
    required this.iconText,
    required this.theme,
  });

  /// Получить цвета для градиента квадрата в зависимости от темы
  List<Color> _getSquareGradient() {
    if (theme.isDark) {
      return [const Color(0xFF2D3748), const Color(0xFF1F2937)];
    }

    // Делаем градиент ближе к фону главного экрана текущей темы
    // (меньше контраст/насыщенность, чем от primaryColor).
    final top =
        Color.lerp(theme.gradientTopColor, Colors.white, 0.35) ??
        theme.gradientTopColor;
    final bottom =
        Color.lerp(theme.lightBackgroundColor, Colors.white, 0.2) ??
        theme.lightBackgroundColor;
    return [top, bottom];
  }

  /// Получить цвет темной тени в зависимости от темы
  Color _getDarkShadowColor() {
    if (theme.isDark) {
      return Colors.black.withValues(alpha: 0.4);
    }
    // Для светлых тем тень должна оставаться темной (а не серой).
    return Colors.black.withValues(alpha: 0.18);
  }

  /// Получить цвет светлой тени в зависимости от темы
  Color _getLightShadowColor() {
    if (theme.isDark) {
      return Colors.white.withValues(alpha: 0.05);
    }
    return Colors.white.withValues(alpha: 0.65);
  }

  /// Получить цвет тени для круга в зависимости от темы
  Color _getCircleShadowColor({required double opacity}) {
    if (theme.isDark) {
      return Colors.white.withValues(alpha: opacity * 0.3);
    }
    return Colors.black.withValues(alpha: opacity);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = theme.isDark
        ? Colors.white
        : theme.lightBackgroundColor;
    final textColor = theme.isDark ? Colors.black87 : Colors.black87;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getSquareGradient(),
        ),
        border: Border.all(
          color: theme.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : theme.backgroundColor.withValues(alpha: 0.22),
          width: 1,
        ),
        boxShadow: [
          // Дополнительная более четкая тень, чтобы лучше читалась граница рамки
          if (!theme.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(3, 3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          // Темная тень справа-внизу
          BoxShadow(
            color: _getDarkShadowColor(),
            offset: const Offset(7, 7),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          // Светлая тень слева-вверху
          BoxShadow(
            color: _getLightShadowColor(),
            offset: const Offset(-7, -7),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              // Основная тень снизу
              BoxShadow(
                color: _getCircleShadowColor(opacity: 0.1),
                offset: const Offset(0, 3),
                blurRadius: 12,
                spreadRadius: 0,
              ),
              // Легкая тень снизу
              BoxShadow(
                color: _getCircleShadowColor(opacity: 0.06),
                offset: const Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              iconText,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: ResponsiveMetrics.of(context).scaled(9.5),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
