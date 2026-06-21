import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/platform_icons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import '../services/audio_service.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_metrics.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class PlayerWidget extends StatefulWidget {
  final String fileName;

  const PlayerWidget({super.key, required this.fileName});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  late AudioPlayer _audioPlayer;
  // true только после успешной инициализации плеера. Если загрузка аудио
  // упала (например, из-за нативной ошибки objective_c на симуляторе),
  // поле _audioPlayer не инициализируется — флаг защищает от обращения к нему.
  bool _audioReady = false;
  bool _isPlaying = false;
  bool _isRepeating = false;
  double _playbackRate = 1.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;
  bool _isHandlingComplete = false;

  // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Добавляем подписки для правильной очистки
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      _audioPlayer = await AudioService().loadAudio(widget.fileName);
      _audioReady = true;

      // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Сохраняем подписки для отмены в dispose
      _durationSubscription = _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration ?? Duration.zero;
            _isLoading = false;
          });
        }
      });

      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            // Ограничиваем позицию, чтобы она не превышала длительность
            if (_duration > Duration.zero && position > _duration) {
              _position = _duration;
            } else {
              _position = position;
            }
          });

          // Проверяем, достиг ли плеер конца (вне setState)
          // Если режим повтора включен, не обрабатываем завершение
          if (_duration > Duration.zero &&
              position >= _duration &&
              _isPlaying &&
              !_isRepeating &&
              !_isHandlingComplete) {
            _handlePlaybackComplete();
          }
        }
      });

      _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });

          // Обрабатываем завершение воспроизведения (вне setState)
          // Если режим повтора включен, не обрабатываем завершение
          if (state.processingState == ProcessingState.completed &&
              !_isRepeating &&
              !_isHandlingComplete) {
            _handlePlaybackComplete();
          }
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio: $e');
      if (!mounted) return;

      // Захватываем всё из context синхронно, пока виджет ещё активен
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context);
      final theme = Provider.of<ThemeProvider>(context, listen: false).selectedTheme;

      setState(() {
        _isLoading = false;
      });

      if (l10n != null) {
        // Показываем только короткое локализованное сообщение — без полного
        // дампа исключения (он раздувал SnackBar на весь экран). Подробности
        // остаются в debugPrint выше. Показ обёрнут в try/catch: при ошибке
        // инициализации дерево может демонтироваться, и showSnackBar способен
        // бросить «deactivated widget's ancestor».
        try {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.audioLoadError),
              duration: const Duration(seconds: 3),
              backgroundColor: theme.errorColor,
            ),
          );
        } catch (_) {
          // Виджет/Scaffold уже демонтируется — безопасно игнорируем.
        }
      }
    }
  }

  Future<void> _handlePlaybackComplete() async {
    if (_isHandlingComplete) return; // Предотвращаем множественные вызовы

    _isHandlingComplete = true;

    try {
      // Останавливаем воспроизведение
      await _audioPlayer.pause();
      // Возвращаем позицию на начало
      await _audioPlayer.seek(Duration.zero);

      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      }
    } finally {
      // Сбрасываем флаг через небольшую задержку
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _isHandlingComplete = false;
        }
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (!_audioReady) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // Останавливаем все остальные плееры перед запуском этого
      await AudioService().stopAllExcept(_audioPlayer);
      await _audioPlayer.play();
    }
  }

  Future<void> _toggleRepeat() async {
    if (!_audioReady) return;
    setState(() {
      _isRepeating = !_isRepeating;
    });
    await _audioPlayer.setLoopMode(_isRepeating ? LoopMode.one : LoopMode.off);
  }

  Future<void> _cyclePlaybackRate() async {
    if (!_audioReady) return;
    setState(() {
      if (_playbackRate == 1.0) {
        _playbackRate = 1.5;
      } else if (_playbackRate == 1.5) {
        _playbackRate = 2.0;
      } else {
        _playbackRate = 1.0;
      }
    });
    await _audioPlayer.setSpeed(_playbackRate);
    if (!_isPlaying) {
      // Останавливаем все остальные плееры перед запуском этого
      await AudioService().stopAllExcept(_audioPlayer);
      await _audioPlayer.play();
    }
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  }

  double _clampPosition(double position, double maxDuration) {
    if (maxDuration <= 0) return 0.0;
    // Ограничиваем позицию, чтобы она не превышала длительность
    return position.clamp(0.0, maxDuration);
  }

  @override
  void dispose() {
    // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Отменяем все подписки перед dispose
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();

    // Удаляем плеер из списка активных перед удалением.
    // Только если инициализация прошла успешно — иначе _audioPlayer (late)
    // не присвоен, и обращение к нему бросило бы LateInitializationError.
    if (_audioReady) {
      AudioService().unregisterPlayer(_audioPlayer);
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;
    final metrics = ResponsiveMetrics.of(context);

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                context,
                icon: PlatformIcons.repeat,
                isActive: _isRepeating,
                color: Colors.red,
                onTap: _toggleRepeat,
                theme: theme,
                size: metrics.playerControlSize,
              ),
              SizedBox(width: metrics.playerControlGap),
              _buildControlButton(
                context,
                icon: _isPlaying
                    ? PlatformIcons.pause
                    : PlatformIcons.playArrow,
                isActive: _isPlaying,
                color: Colors.green,
                onTap: _togglePlayPause,
                theme: theme,
                size: metrics.playerControlSize,
              ),
              SizedBox(width: metrics.playerControlGap),
              _buildRateButton(
                context,
                rate: _playbackRate,
                onTap: _cyclePlaybackRate,
                theme: theme,
                size: metrics.playerControlSize,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _clampPosition(
              _position.inMilliseconds.toDouble(),
              _duration.inMilliseconds.toDouble(),
            ),
            min: 0,
            max: _duration.inMilliseconds > 0
                ? _duration.inMilliseconds.toDouble()
                : 1.0,
            onChanged: (value) {
              _audioPlayer.seek(Duration(milliseconds: value.toInt()));
            },
            activeColor: theme.primaryColor,
            inactiveColor: theme.primaryColor.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
    required theme,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.lightBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: theme.cardShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? theme.primaryColor : theme.textColor,
          size: size * 0.38,
        ),
      ),
    );
  }

  Widget _buildRateButton(
    BuildContext context, {
    required double rate,
    required VoidCallback onTap,
    required theme,
    required double size,
  }) {
    final isActive = rate > 1.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.lightBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: theme.cardShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${rate}x',
            style: TextStyle(
              color: isActive ? theme.primaryColor : theme.textColor,
              fontSize: size * 0.23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
