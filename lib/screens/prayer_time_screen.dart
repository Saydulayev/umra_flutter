import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../utils/platform_icons.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/notification_preferences_provider.dart';
import '../models/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/notification_settings_sheet.dart';
import '../services/notification_service.dart';
import '../services/prayer_time_service.dart';
import '../utils/responsive_metrics.dart';
import '../theme/app_type.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_constants.dart';

class PrayerTimeScreen extends StatefulWidget {
  /// Когда экран используется как вкладка нижнего таб-бара, скрываем кнопку
  /// «назад» и резервируем место под плавающий бар.
  final bool embedded;

  const PrayerTimeScreen({super.key, this.embedded = false});

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  PrayerTimeData? _prayerTimes;
  bool _hasError = false;
  String _currentCityKey = 'mecca';

  // Кешируем дорогие в пересчёте значения: исламская дата/год (Hijri-конвертация)
  // и время Qiyam (= два полных расчёта adhan). Раньше всё это вызывалось из
  // build() на каждом тике секундного таймера. Теперь — только при смене города
  // (см. _recomputePrayerTimes). Обратный отсчёт изолирован в _PrayerCountdown,
  // поэтому 1-сек обновление перестраивает лишь маленькую капсулу, а не экран.
  DateTime? _qiyamTime;
  String _islamicDate = '';
  String _islamicYear = '';

  // Примечание: разрешение на уведомления здесь НЕ запрашивается. Этот экран
  // встроен в IndexedStack и создаётся при каждом запуске приложения (даже на
  // вкладке «Дом»), поэтому запрос — включая системный экран «Сигналы и
  // напоминания» от requestExactAlarmsPermission — выскакивал при каждом старте.
  // Разрешение запрашивается только когда пользователь сам включает уведомление
  // в NotificationSettingsSheet (_ensurePermission).

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prefs = Provider.of<UserPreferencesProvider>(context);
    final cityKey = prefs.prayerCity;
    if (_prayerTimes == null || cityKey != _currentCityKey) {
      _currentCityKey = cityKey;
      _recomputePrayerTimes(prayerCityFromString(cityKey));
    }
  }

  void _recomputePrayerTimes(PrayerCity city) {
    setState(() {
      _prayerTimes = PrayerTimeService.getTodayPrayerTimes(city);
      _hasError = _prayerTimes == null;
      if (_prayerTimes != null) {
        _qiyamTime = PrayerTimeService.getQiyamTime(city);
        _islamicDate = PrayerTimeService.getIslamicDate();
        _islamicYear = PrayerTimeService.getIslamicYear();
      }
    });
  }

  Future<void> _onCityChanged(String cityKey) async {
    final prefs = Provider.of<UserPreferencesProvider>(context, listen: false);
    await prefs.setPrayerCity(cityKey);
    _currentCityKey = cityKey;
    _recomputePrayerTimes(prayerCityFromString(cityKey));
    if (!mounted) return;
    final notifPrefs = Provider.of<NotificationPreferencesProvider>(
      context,
      listen: false,
    );
    final texts = PrayerNotificationTexts.of(AppLocalizations.of(context)!);
    await notifPrefs.rescheduleForCity(
        prayerCityFromString(cityKey), texts);
  }

  String _formatTime(DateTime dateTime) {
    return PrayerTimeService.formatPrayerTime(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final prefs = Provider.of<UserPreferencesProvider>(context);
    final theme = themeProvider.selectedTheme;
    final l10n = AppLocalizations.of(context)!;

    if (_prayerTimes == null) {
      return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          automaticallyImplyLeading: !widget.embedded,
          iconTheme: IconThemeData(color: theme.primaryColor),
          title: Text(
            l10n.prayerTimesTitle,
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.w600,
              fontSize: AppType.of(context).callout,
            ),
          ),
        ),
        body: _hasError
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.prayerTimeLoadError,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: AppType.of(context).caption,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => _recomputePrayerTimes(
                          prayerCityFromString(_currentCityKey),
                        ),
                        child: Text(
                          l10n.retry,
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
              ),
      );
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: !widget.embedded,
        iconTheme: IconThemeData(color: theme.primaryColor),
        actions: [
          // DEBUG-кнопка теста уведомлений: kDebugMode → в release-сборке её нет.
          // Тапни → через 30 сек придёт тестовое уведомление (проверка доставки
          // без ожидания намаза). Запускай в debug-сборке: flutter run -d <id>.
          if (kDebugMode)
            IconButton(
              icon: Icon(Icons.bug_report, color: theme.primaryColor),
              onPressed: () async {
                await NotificationService.debugScheduleTest(seconds: 30);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Тест запланирован на +30 сек. '
                        'Сверни приложение и подожди.'),
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(PlatformIcons.notifications, color: theme.primaryColor),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const NotificationSettingsSheet(),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
          final metrics = ResponsiveMetrics.of(context);
          return SingleChildScrollView(
            // Горизонтальный отступ задаёт padding карточки (как margin у
            // «Умра»/«Хадж»), а не scroll-view. Внешний блок = contentMaxWidth
            // (на планшете 680), поэтому заголовок и карточка встают ровно как
            // на других вкладках, а не уезжают к центру по узкому блоку 520.
            padding: EdgeInsets.only(
              top: widget.embedded ? 0 : 16,
              bottom: bottomPadding +
                  (widget.embedded ? kBottomTabBarReservedSpace : 16),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: metrics.contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Крупный заголовок слева — тот же padding (20,4,20,24), что
                    // у «Умра»/«Хадж». Только во встроенном режиме (вкладке).
                    if (widget.embedded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        child: Text(
                          l10n.prayerTimesTitle.toUpperCase(),
                          style: TextStyle(
                            fontSize: metrics.largeTitleFontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: theme.textColor,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: metrics.listScreenHPad,
                      ),
                      child: _buildCard(
                        theme: theme,
                        metrics: metrics,
                        child: Column(
                          children: [
                            // Заголовок: город + дата (Savoye LET 36pt → GreatVibes 36pt)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                '$_islamicDate $_islamicYear',
                                textDirection: TextDirection.ltr,
                                style: GoogleFonts.cinzel(
                                  fontSize: metrics.scaled(22),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                  color: theme.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // VStack spacing 12pt + divider
                            const SizedBox(height: 12),
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              color: theme.textColor.withValues(alpha: 0.12),
                            ),
                            const SizedBox(height: 12),
                            // Переключатель города
                            _buildCitySegmentedControl(
                              context: context,
                              theme: theme,
                              l10n: l10n,
                              selectedCity: prefs.prayerCity,
                              onCityChanged: _onCityChanged,
                            ),
                            const SizedBox(height: 12),
                            // Блок обратного отсчёта (cardStyled: vertical 40pt outside).
                            // Изолирован в отдельный виджет: его секундный таймер
                            // перестраивает только эту капсулу, а не весь экран.
                            SizedBox(
                              width: double.infinity,
                              child: _PrayerCountdown(
                                prayerTimes: _prayerTimes!,
                                city: prayerCityFromString(_currentCityKey),
                                theme: theme,
                                l10n: l10n,
                                type: AppType(metrics),
                              ),
                            ),
                            // Список намазов (rowsHorizontalPadding 16pt)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: metrics.isCompactPhone ? 8 : 16,
                              ),
                              child: Column(
                                children: _buildPrayerRows(
                                  theme,
                                  l10n,
                                  AppType(metrics),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
    );
  }

  /// Внешняя карточка — аналог iOS transparentStyled (standardCardFrame cornerRadius 20)
  Widget _buildCard({
    required AppTheme theme,
    required ResponsiveMetrics metrics,
    required Widget child,
  }) {
    return AppCard(
      theme: theme,
      cornerRadius: 20,
      shadows: [
        BoxShadow(
          color: theme.cardShadowColor,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: Padding(padding: metrics.prayerCardPadding, child: child),
    );
  }

  /// Список намазов. Порядок как в iOS: Fajr → Sunrise (капсула) → Dhuhr → Asr → Maghrib → Isha → Qiyam (капсула).
  List<Widget> _buildPrayerRows(
    AppTheme theme,
    AppLocalizations l10n,
    AppType type,
  ) {
    final qiyamTime = _qiyamTime;

    Widget plain(String name, String time) =>
        _buildPrayerTimeRow(name, time, theme: theme, type: type);

    Widget carded(String name, String time) => _buildCapsuleCard(
      theme: theme,
      child: _buildPrayerTimeRow(name, time, theme: theme, type: type),
    );

    return [
      plain(l10n.fajr, _formatTime(_prayerTimes!.fajr)),
      carded(l10n.sunrise, _formatTime(_prayerTimes!.sunrise)),
      plain(l10n.dhuhr, _formatTime(_prayerTimes!.dhuhr)),
      plain(l10n.asr, _formatTime(_prayerTimes!.asr)),
      plain(l10n.maghrib, _formatTime(_prayerTimes!.maghrib)),
      plain(l10n.isha, _formatTime(_prayerTimes!.isha)),
      if (qiyamTime != null) carded(l10n.qiyam, _formatTime(qiyamTime)),
    ];
  }

  /// capsuleStyled — standardCardFrame cornerRadius 20
  Widget _buildCapsuleCard({required AppTheme theme, required Widget child}) {
    return AppCard(
      theme: theme,
      cornerRadius: 20,
      margin: EdgeInsets.zero,
      shadows: [],
      child: child,
    );
  }

  /// Строка намаза — PrayerTimeRow iOS (.callout semibold)
  Widget _buildPrayerTimeRow(
    String prayerName,
    String prayerTime, {
    required AppTheme theme,
    required AppType type,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              prayerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: type.callout,
                fontWeight: FontWeight.w600,
                color: theme.isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            prayerTime,
            maxLines: 1,
            style: TextStyle(
              fontSize: type.callout,
              fontWeight: FontWeight.w400,
              color: theme.isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Переключатель города
  Widget _buildCitySegmentedControl({
    required BuildContext context,
    required AppTheme theme,
    required AppLocalizations l10n,
    required String selectedCity,
    required Future<void> Function(String) onCityChanged,
  }) {
    final activeBg = theme.primaryColor;
    final activeText = theme.isDark ? Colors.black : Colors.white;
    final inactiveText = theme.textColor.withValues(alpha: 0.6);

    return AppCard(
      theme: theme,
      cornerRadius: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      shadows: [
        BoxShadow(
          color: theme.cardShadowColor,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onCityChanged('mecca'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selectedCity == 'mecca' ? activeBg : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.mecca,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppType.of(context).caption,
                    fontWeight: FontWeight.w600,
                    color: selectedCity == 'mecca' ? activeText : inactiveText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onCityChanged('medina'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: selectedCity == 'medina' ? activeBg : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.medina,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppType.of(context).caption,
                    fontWeight: FontWeight.w600,
                    color: selectedCity == 'medina' ? activeText : inactiveText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Изолированный блок обратного отсчёта до следующего намаза.
///
/// Владеет собственным секундным таймером. Поскольку это отдельный
/// `StatefulWidget`, `setState` каждую секунду перестраивает ТОЛЬКО эту
/// капсулу, а не весь экран намазов (список, заголовок, переключатель города).
/// Расчёт следующего намаза дешёвый (сравнение 6 готовых времён); тяжёлые
/// `getQiyamTime`/Hijri в parent кешируются и сюда не попадают.
class _PrayerCountdown extends StatefulWidget {
  final PrayerTimeData prayerTimes;
  final PrayerCity city;
  final AppTheme theme;
  final AppLocalizations l10n;
  final AppType type;

  const _PrayerCountdown({
    required this.prayerTimes,
    required this.city,
    required this.theme,
    required this.l10n,
    required this.type,
  });

  @override
  State<_PrayerCountdown> createState() => _PrayerCountdownState();
}

class _PrayerCountdownState extends State<_PrayerCountdown> {
  Timer? _timer;
  String _nextPrayerName = '';
  Duration _timeUntilNextPrayer = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void didUpdateWidget(covariant _PrayerCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Город/времена сменились (переключатель Мекка/Медина) — пересчитываем сразу.
    if (oldWidget.prayerTimes != widget.prayerTimes ||
        oldWidget.city != widget.city) {
      _update();
    }
  }

  void _update() {
    if (!mounted) return;
    setState(() {
      _nextPrayerName =
          PrayerTimeService.getNextPrayerName(widget.prayerTimes);
      _timeUntilNextPrayer = PrayerTimeService.getTimeUntilNextPrayer(
        widget.prayerTimes,
        widget.city,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = widget.l10n;
    return AppCard(
      theme: theme,
      cornerRadius: 999,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      shadows: [
        BoxShadow(
          color: theme.cardShadowColor,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          _nextPrayerName.isEmpty
              ? '—'
              : '${_localizedPrayerName(_nextPrayerName, l10n)} ${l10n.prayerTimeIn} ${_formatDuration(_timeUntilNextPrayer)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: widget.type.callout,
            fontWeight: FontWeight.w600,
            color: theme.isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
}

String _localizedPrayerName(String englishName, AppLocalizations l10n) {
  switch (englishName) {
    case 'Fajr':
      return l10n.fajr;
    case 'Sunrise':
      return l10n.sunrise;
    case 'Dhuhr':
      return l10n.dhuhr;
    case 'Asr':
      return l10n.asr;
    case 'Maghrib':
      return l10n.maghrib;
    case 'Isha':
      return l10n.isha;
    case 'Qiyam':
      return l10n.qiyam;
    default:
      return englishName;
  }
}
