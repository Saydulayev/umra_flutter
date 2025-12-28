import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:umra_flutter/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class CounterTapWidget extends StatefulWidget {
  const CounterTapWidget({super.key});

  @override
  State<CounterTapWidget> createState() => _CounterTapWidgetState();
}

class _CounterTapWidgetState extends State<CounterTapWidget> {
  int _counter = 0;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('tawaf_counter') ?? 0;
    });
  }

  Future<void> _saveCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tawaf_counter', value);
  }

  Future<void> _incrementCounter() async {
    if (_counter < 7) {
      setState(() {
        _counter++;
      });
      await _saveCounter(_counter);
      _triggerVibration();

      if (_counter == 7) {
        setState(() {
          _showCelebration = true;
        });
      }
    }
  }

  Future<void> _decrementCounter() async {
    if (_counter > 0) {
      setState(() {
        _counter = 0;
        _showCelebration = false;
      });
      await _saveCounter(_counter);
      _triggerVibration();
    }
  }

  Future<void> _triggerVibration() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Заголовок и счетчик
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${l10n.circleString} ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              Text(
                '$_counter',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Праздничное сообщение
          if (_showCelebration)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                // Ограничиваем значение opacity в диапазоне 0.0-1.0
                final clampedOpacity = value.clamp(0.0, 1.0);
                final clampedScale = value.clamp(0.0, 1.0);
                return Transform.scale(
                  scale: clampedScale,
                  child: Opacity(
                    opacity: clampedOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.teal.shade300,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.sayFinishedString,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 32),

          // Кнопки управления
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            _buildButton(
              context,
              label: l10n.addString,
              onPressed: _incrementCounter,
              theme: theme,
              enabled: _counter < 7,
            ),
            const SizedBox(width: 24),
            _buildButton(
              context,
              label: l10n.resetString,
              onPressed: _decrementCounter,
              theme: theme,
              enabled: _counter > 0,
            ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    required theme,
    required bool enabled,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? theme.lightBackgroundColor : theme.disabledButtonBackgroundColor,
        foregroundColor: enabled ? theme.primaryColor : theme.disabledButtonForegroundColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
