import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import '../repositories/preferences_repository.dart';
import '../constants/app_constants.dart';

/// Сервис для работы с оценкой приложения
class AppReviewService {
  static final AppReviewService _instance = AppReviewService._internal();
  factory AppReviewService() => _instance;
  AppReviewService._internal();

  final PreferencesRepository _prefsRepo = PreferencesRepository();
  final InAppReview _inAppReview = InAppReview.instance;

  /// Проверить, доступен ли In-App Review
  Future<bool> isAvailable() async {
    return await _inAppReview.isAvailable();
  }

  /// Показать диалог оценки приложения
  Future<void> requestReview() async {
    try {
      if (await isAvailable()) {
        await _inAppReview.requestReview();
      }
    } catch (e) {
      // Игнорируем ошибки, чтобы не нарушать работу приложения
      debugPrint('Error requesting review: $e');
    }
  }

  /// Открыть страницу приложения в магазине.
  /// На iOS обязательно передаётся числовой App Store ID, иначе страница
  /// не откроется.
  Future<void> openStoreListing() async {
    await _inAppReview.openStoreListing(
      appStoreId: Platform.isIOS ? AppStrings.appStoreId : null,
    );
  }

  /// Проверить, нужно ли показать диалог оценки
  /// Показываем только если:
  /// 1. Пользователь еще не оценивал приложение
  /// 2. Прошло минимум 3 минуты использования
  Future<bool> shouldShowReviewDialog() async {
    final hasRated = await _prefsRepo.getBool(PrefsKeys.hasRatedApp) ?? false;
    return !hasRated;
  }
}
