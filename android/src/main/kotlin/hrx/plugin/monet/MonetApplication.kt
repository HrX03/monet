package hrx.plugin.monet

import com.kieronquinn.monetcompat.core.MonetCompat
import io.flutter.app.FlutterApplication

open class MonetApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        MonetCompat.enablePaletteCompat()
    }
}