package saydulayev.wien_gmail.com.umra

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // Edge-to-edge: начиная с Android 15 (targetSdk=35) включено по умолчанию,
    // но для обратной совместимости включаем его и на более старых версиях.
    // Важно: не используем WindowCompat.enableEdgeToEdge(), т.к. внутри могут
    // вызываться setStatusBarColor/setNavigationBarColor, которые не поддерживаются в Android 15.
    WindowCompat.setDecorFitsSystemWindows(window, false)

    // Для Android 15+ layoutInDisplayCutoutMode должно быть LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
    // для неплавающих окон (согласно документации Android 15)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      val layoutParams = window.attributes
      layoutParams.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
      window.attributes = layoutParams
    }
  }
}
