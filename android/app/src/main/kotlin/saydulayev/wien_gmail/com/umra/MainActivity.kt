package saydulayev.wien_gmail.com.umra

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "saydulayev.wien_gmail.com.umra/system_ui"
  private var windowInsetsController: WindowInsetsControllerCompat? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    
    // Включаем edge-to-edge для Android 15+ (API 35+)
    // enableEdgeToEdge() доступен с androidx.core:core:1.12.0+ и рекомендуется для Android 15+
    // Для обратной совместимости используем enableEdgeToEdge() для всех версий
    // Этот метод автоматически обрабатывает различия между версиями Android
    WindowCompat.enableEdgeToEdge(window)
    
    // Для Android 15+ layoutInDisplayCutoutMode должно быть LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
    // для неплавающих окон (согласно документации Android 15)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      val layoutParams = window.attributes
      layoutParams.layoutInDisplayCutoutMode = 
          WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
      window.attributes = layoutParams
    }
    
    // Для Android 15+ (API 35+) НЕ используем setStatusBarColor, setNavigationBarColor, 
    // setNavigationBarDividerColor - эти API устарели и не поддерживаются
    // Вместо этого используем только WindowInsetsControllerCompat для управления внешним видом
    // Цвета системных панелей теперь прозрачные по умолчанию в edge-to-edge режиме
    windowInsetsController = WindowInsetsControllerCompat(window, window.decorView)
    windowInsetsController?.let { controller ->
      // Устанавливаем только яркость иконок, не цвета
      // Это работает для всех версий Android, включая Android 15+
      controller.isAppearanceLightStatusBars = true
      controller.isAppearanceLightNavigationBars = true
    }
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    // Создаем платформенный канал для обновления яркости иконок из Flutter
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "updateSystemUIAppearance" -> {
          val isDark = call.argument<Boolean>("isDark") ?: false
          updateSystemUIAppearance(isDark)
          result.success(null)
        }
        else -> {
          result.notImplemented()
        }
      }
    }
  }

  private fun updateSystemUIAppearance(isDark: Boolean) {
    windowInsetsController?.let { controller ->
      // Для темной темы иконки светлые, для светлой темы иконки темные
      controller.isAppearanceLightStatusBars = !isDark
      controller.isAppearanceLightNavigationBars = !isDark
    }
  }
}

