import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';
import '../theme/app_type.dart';
import '../utils/platform_icons.dart';
import '../utils/responsive_metrics.dart';

/// Экран компаса киблы: стрелка указывает направление на Каабу.
///
/// Направление вычисляется по формуле начального азимута большого круга
/// (great-circle initial bearing) от текущих GPS-координат к Каабе.
/// Heading устройства берётся из магнитометра (flutter_compass); на iOS это
/// trueHeading (с поправкой на склонение), на Android — магнитный север.
/// Погрешность склонения (обычно ≤ 5–7°) для бытового компаса приемлема.
class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

enum _QiblaStatus { loading, ready, servicesOff, denied, deniedForever, error }

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with WidgetsBindingObserver {
  // Координаты Каабы (Масджид аль-Харам, Мекка).
  static const double _kaabaLat = 21.4225241;
  static const double _kaabaLng = 39.8261818;

  /// Порог «вы направлены на киблу», градусы.
  static const double _alignedTolerance = 5.0;

  /// Порог показа подсказки о калибровке, градусы погрешности сенсора.
  static const double _accuracyThreshold = 30.0;

  _QiblaStatus _status = _QiblaStatus.loading;
  double? _qiblaBearing; // азимут киблы от севера, 0..360

  // Непрерывный (без скачка на 0/360) heading для плавного поворота диска.
  double _continuousHeading = 0;
  double? _lastRawHeading;
  bool _aligned = false;
  bool _needsCalibration = false;
  bool _hasCompassSensor = true;

  StreamSubscription<CompassEvent>? _compassSub;

  // Детект «молчащего» стрима: на части Android-устройств без магнитометра
  // (и в эмуляторах) FlutterCompass.events создаётся успешно, но не эмитит
  // ни одного события — без таймаута компас выглядел бы рабочим, просто
  // «застывшим». Если за _compassTimeoutDuration не пришло ни одного события,
  // считаем, что сенсора нет, и показываем fallback со статическим азимутом.
  static const Duration _compassTimeoutDuration = Duration(seconds: 3);
  Timer? _compassTimeout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _compassTimeout?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  // Магнитометр не нужен, пока приложение в фоне. Важно: именно cancel(), а
  // не pause() — FlutterCompass.events это закэшированный broadcast-стрим
  // поверх EventChannel.receiveBroadcastStream(), и pause() лишь отбрасывает
  // события на Dart-стороне, не останавливая нативный опрос сенсора. Нативный
  // 'cancel' уходит только при отписке последнего слушателя, поэтому реально
  // отписываемся на paused и пересоздаём подписку на resumed ('listen'
  // вызовется заново). Таймаут тоже гасим, чтобы он не тикал в фоне.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_compassSub == null && _status == _QiblaStatus.ready) {
        _subscribeCompass();
      }
    } else if (state == AppLifecycleState.paused) {
      _compassTimeout?.cancel();
      _compassSub?.cancel();
      _compassSub = null;
    }
  }

  Future<void> _init() async {
    setState(() => _status = _QiblaStatus.loading);
    try {
      final servicesOn = await Geolocator.isLocationServiceEnabled();
      if (!servicesOn) {
        if (mounted) setState(() => _status = _QiblaStatus.servicesOff);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _status = _QiblaStatus.deniedForever);
        return;
      }
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _status = _QiblaStatus.denied);
        return;
      }

      // Для азимута киблы хватает грубой точности; timeout — чтобы не висеть
      // в помещении без GPS-фикса, fallback — последняя известная позиция.
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } on TimeoutException {
        position = await Geolocator.getLastKnownPosition();
      }
      position ??= await Geolocator.getLastKnownPosition();

      if (position == null) {
        if (mounted) setState(() => _status = _QiblaStatus.error);
        return;
      }

      final bearing = _greatCircleBearing(
        position.latitude,
        position.longitude,
        _kaabaLat,
        _kaabaLng,
      );

      if (!mounted) return;
      setState(() {
        _qiblaBearing = bearing;
        _status = _QiblaStatus.ready;
      });
      _subscribeCompass();
    } catch (_) {
      if (mounted) setState(() => _status = _QiblaStatus.error);
    }
  }

  void _subscribeCompass() {
    final events = FlutterCompass.events;
    if (events == null) {
      setState(() => _hasCompassSensor = false);
      return;
    }
    _compassSub?.cancel();
    _compassTimeout?.cancel();
    _compassTimeout = Timer(_compassTimeoutDuration, () {
      // Ни одного события за таймаут — стрим «молчит», сенсора нет.
      if (mounted) setState(() => _hasCompassSensor = false);
    });
    _compassSub = events.listen((event) {
      _compassTimeout?.cancel();
      final heading = event.heading;
      if (heading == null) {
        if (_hasCompassSensor && mounted) {
          setState(() => _hasCompassSensor = false);
        }
        return;
      }

      // Накопление кратчайшей дуги: heading 359° → 1° даёт delta +2°,
      // а не −358°, поэтому AnimatedRotation не делает полный оборот.
      final last = _lastRawHeading;
      if (last == null) {
        _continuousHeading = heading;
      } else {
        final delta = ((heading - last + 540) % 360) - 180;
        _continuousHeading += delta;
      }
      _lastRawHeading = heading;

      final qibla = _qiblaBearing;
      bool aligned = false;
      if (qibla != null) {
        final diff = ((qibla - heading + 540) % 360) - 180;
        aligned = diff.abs() <= _alignedTolerance;
      }
      // Лёгкая вибрация один раз при «попадании» в киблу.
      if (aligned && !_aligned) HapticFeedback.lightImpact();

      final accuracy = event.accuracy;
      final needsCalibration =
          accuracy != null && (accuracy < 0 || accuracy > _accuracyThreshold);

      if (!mounted) return;
      setState(() {
        _hasCompassSensor = true;
        _aligned = aligned;
        _needsCalibration = needsCalibration;
      });
    });
  }

  /// Начальный азимут большого круга от точки (lat1, lng1) к (lat2, lng2),
  /// градусы от истинного севера, 0..360.
  static double _greatCircleBearing(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const deg2rad = math.pi / 180.0;
    final phi1 = lat1 * deg2rad;
    final phi2 = lat2 * deg2rad;
    final dLng = (lng2 - lng1) * deg2rad;
    final y = math.sin(dLng);
    final x =
        math.cos(phi1) * math.tan(phi2) - math.sin(phi1) * math.cos(dLng);
    final bearing = math.atan2(y, x) / deg2rad;
    return (bearing + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).selectedTheme;
    final l10n = AppLocalizations.of(context)!;
    final type = AppType.of(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
        title: Text(
          l10n.qiblaTitle,
          style: TextStyle(
            color: theme.textColor,
            fontWeight: FontWeight.w600,
            fontSize: type.callout,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody(theme, l10n, type)),
    );
  }

  Widget _buildBody(AppTheme theme, AppLocalizations l10n, AppType type) {
    switch (_status) {
      case _QiblaStatus.loading:
        return Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        );
      case _QiblaStatus.servicesOff:
        return _buildProblem(
          theme,
          type,
          message: l10n.qiblaLocationServicesOff,
          buttonLabel: l10n.qiblaOpenSettings,
          onPressed: () => Geolocator.openLocationSettings(),
        );
      case _QiblaStatus.denied:
        return _buildProblem(
          theme,
          type,
          message: l10n.qiblaLocationDenied,
          buttonLabel: l10n.retry,
          onPressed: _init,
        );
      case _QiblaStatus.deniedForever:
        return _buildProblem(
          theme,
          type,
          message: l10n.qiblaLocationDenied,
          buttonLabel: l10n.qiblaOpenSettings,
          onPressed: () => Geolocator.openAppSettings(),
        );
      case _QiblaStatus.error:
        return _buildProblem(
          theme,
          type,
          message: l10n.qiblaLocationError,
          buttonLabel: l10n.retry,
          onPressed: _init,
        );
      case _QiblaStatus.ready:
        return _buildCompass(theme, l10n, type);
    }
  }

  Widget _buildProblem(
    AppTheme theme,
    AppType type, {
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PlatformIcons.errorOutline, size: 48, color: theme.errorColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textColor, fontSize: type.caption),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onPressed,
              child: Text(
                buttonLabel,
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(AppTheme theme, AppLocalizations l10n, AppType type) {
    final qibla = _qiblaBearing!;
    final dialTurns = -_continuousHeading / 360.0;
    // Стрелка = кибла относительно текущего heading. Складываем с непрерывным
    // dialTurns, чтобы анимация тоже шла по кратчайшей дуге.
    final needleTurns = qibla / 360.0 + dialTurns;
    final accent = _aligned ? theme.secondaryColor : theme.primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = ResponsiveMetrics.of(context);
        final dialSize = math
            .min(
              // Высотный бюджет: AppBar-отступы, цель-Кааба, статус и азимут.
              math.min(constraints.maxWidth - 64, constraints.maxHeight - 300),
              metrics.contentMaxWidth * 0.62,
            )
            .clamp(160.0, 420.0)
            .toDouble();

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Подсказка о калибровке — появляется при слабом сигнале.
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _needsCalibration ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // info, не errorOutline: калибровка — подсказка,
                          // а не ошибка, тревожная иконка здесь лишняя.
                          Icon(
                            PlatformIcons.info,
                            size: 16,
                            color: theme.goldAccentTextColor,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.qiblaCalibrationHint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.goldAccentTextColor,
                                fontSize: type.overline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_hasCompassSensor) ...[
                    // Неподвижная цель — Кааба вверху. Пользователь
                    // поворачивается, пока стрелка не укажет на неё:
                    // стрелка вверх = вы смотрите в сторону киблы.
                    _KaabaTarget(
                      theme: theme,
                      size: dialSize * 0.16,
                      highlighted: _aligned,
                    ),
                    SizedBox(height: dialSize * 0.04),
                    SizedBox(
                      width: dialSize,
                      height: dialSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Вращающийся диск: деления и стороны света.
                          AnimatedRotation(
                            turns: dialTurns,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.linear,
                            child: CustomPaint(
                              size: Size.square(dialSize),
                              painter: _DialPainter(theme: theme),
                            ),
                          ),
                          // Стрелка на Каабу.
                          AnimatedRotation(
                            turns: needleTurns,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.linear,
                            child: CustomPaint(
                              size: Size.square(dialSize),
                              painter: _NeedlePainter(
                                theme: theme,
                                color: accent,
                              ),
                            ),
                          ),
                          // Центральная точка.
                          Container(
                            width: dialSize * 0.055,
                            height: dialSize * 0.055,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent,
                              border: Border.all(
                                color: theme.backgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Статус «вы направлены на киблу».
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _aligned ? 1 : 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PlatformIcons.checkCircle,
                            size: 18,
                            color: theme.goldAccentTextColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.qiblaAligned,
                            style: TextStyle(
                              color: theme.goldAccentTextColor,
                              fontSize: type.caption,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    // Магнитометра нет: показываем только статический азимут.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      child: Text(
                        l10n.qiblaNoCompass,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.secondaryTextColor,
                          fontSize: type.caption,
                        ),
                      ),
                    ),
                  ],
                  // Азимут киблы в градусах от севера — работает и как
                  // fallback без сенсора.
                  Text(
                    l10n.qiblaDegreesFromNorth(qibla.round().toString()),
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: type.title,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Неподвижная цель «Кааба» над компасом ───────────────────────────────────

class _KaabaTarget extends StatelessWidget {
  final AppTheme theme;
  final double size;
  final bool highlighted;

  const _KaabaTarget({
    required this.theme,
    required this.size,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: highlighted
                ? theme.secondaryColor
                : theme.lightBackgroundColor,
            border: Border.all(
              color: theme.secondaryColor,
              width: highlighted ? 2 : 1.5,
            ),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                      color: theme.secondaryColor.withValues(alpha: 0.45),
                      blurRadius: 14,
                    ),
                  ]
                : const [],
          ),
          padding: EdgeInsets.all(size * 0.22),
          child: SvgPicture.asset(
            'assets/icons/kaaba.svg',
            colorFilter: ColorFilter.mode(
              highlighted ? theme.onSecondaryColor : theme.goldAccentTextColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Указатель-риска от Каабы к диску: сюда должна встать стрелка.
        Container(
          width: 2,
          height: size * 0.28,
          decoration: BoxDecoration(
            color: theme.secondaryColor.withValues(
              alpha: highlighted ? 1.0 : 0.5,
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

// ─── Диск компаса: фон, деления, стороны света ───────────────────────────────

class _DialPainter extends CustomPainter {
  final AppTheme theme;

  const _DialPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Фон диска: поверхность карточки; для emerald — фирменный градиент.
    final bgPaint = Paint();
    if (theme.isEmerald) {
      bgPaint.shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [const Color(0xFF1A2420), theme.lightBackgroundColor],
      ).createShader(Offset.zero & size);
    } else {
      bgPaint.color = theme.lightBackgroundColor;
    }
    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = theme.borderColor,
    );

    // Деления: каждые 5°, крупные каждые 30°.
    for (int deg = 0; deg < 360; deg += 5) {
      final isMajor = deg % 30 == 0;
      final angle = (deg - 90) * math.pi / 180.0;
      final outer = radius * 0.96;
      final inner = radius * (isMajor ? 0.88 : 0.92);
      final tick = Paint()
        ..strokeWidth = isMajor ? 2 : 1
        ..strokeCap = StrokeCap.round
        ..color = isMajor
            ? theme.secondaryTextColor
            : theme.secondaryTextColor.withValues(alpha: 0.35);
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * outer,
        tick,
      );
    }

    // Стороны света. N — золотом, остальные — вторичным текстом.
    const cardinals = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180.0;
      final pos =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius * 0.76);
      final tp = TextPainter(
        text: TextSpan(
          text: cardinals[i],
          style: TextStyle(
            color: i == 0 ? theme.secondaryColor : theme.secondaryTextColor,
            fontSize: radius * 0.13,
            fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Буквы держим «вверх головой» относительно диска — компасы обычно
      // рисуют их фиксированно на диске, поэтому просто размещаем без
      // контр-поворота: диск вращается целиком, это ожидаемое поведение.
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) => old.theme != theme;
}

// ─── Стрелка на Каабу ────────────────────────────────────────────────────────

class _NeedlePainter extends CustomPainter {
  final AppTheme theme;
  final Color color;

  const _NeedlePainter({required this.theme, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final tip = center.translate(0, -radius * 0.62);
    final tail = center.translate(0, radius * 0.18);
    const halfWidth = 10.0;

    // Передняя (указывающая) половина.
    final front = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(center.dx - halfWidth, center.dy)
      ..lineTo(center.dx + halfWidth, center.dy)
      ..close();
    canvas.drawPath(front, Paint()..color = color);

    // Хвост — полупрозрачный.
    final back = Path()
      ..moveTo(tail.dx, tail.dy)
      ..lineTo(center.dx - halfWidth, center.dy)
      ..lineTo(center.dx + halfWidth, center.dy)
      ..close();
    canvas.drawPath(back, Paint()..color = color.withValues(alpha: 0.35));
  }

  @override
  bool shouldRepaint(covariant _NeedlePainter old) =>
      old.color != color || old.theme != theme;
}
