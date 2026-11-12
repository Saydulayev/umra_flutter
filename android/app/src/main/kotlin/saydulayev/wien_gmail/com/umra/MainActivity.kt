package saydulayev.wien_gmail.com.umra

import android.hardware.GeomagneticField
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Магнитное склонение для компаса киблы: датчик отдаёт heading от
        // магнитного севера, а азимут киблы считается от истинного.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "umra/geomagnetic")
            .setMethodCallHandler { call, result ->
                if (call.method != "declination") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val lat = call.argument<Double>("latitude")
                val lng = call.argument<Double>("longitude")
                if (lat == null || lng == null) {
                    result.error("bad_args", "latitude/longitude required", null)
                    return@setMethodCallHandler
                }
                val alt = call.argument<Double>("altitude") ?: 0.0
                val field = GeomagneticField(
                    lat.toFloat(),
                    lng.toFloat(),
                    alt.toFloat(),
                    System.currentTimeMillis(),
                )
                result.success(field.declination.toDouble())
            }
    }
}
