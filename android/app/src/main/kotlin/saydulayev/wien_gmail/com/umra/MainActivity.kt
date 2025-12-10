package saydulayev.wien_gmail.com.umra

import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    // Разрешаем контенту рисоваться под системными панелями
    WindowCompat.setDecorFitsSystemWindows(window, false)
    // Не задаём цвета панелей напрямую — Flutter управляет стилем иконок через SystemChrome
    WindowInsetsControllerCompat(window, window.decorView).let { controller ->
      controller.isAppearanceLightStatusBars = true
      controller.isAppearanceLightNavigationBars = true
    }
    super.onCreate(savedInstanceState)
  }
}

