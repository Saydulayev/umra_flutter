package saydulayev.wien_gmail.com.umra

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

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
    
    // Настраиваем внешний вид системных панелей
    // Flutter управляет стилем иконок через SystemChrome
    WindowInsetsControllerCompat(window, window.decorView).let { controller ->
      controller.isAppearanceLightStatusBars = true
      controller.isAppearanceLightNavigationBars = true
    }
  }
}

