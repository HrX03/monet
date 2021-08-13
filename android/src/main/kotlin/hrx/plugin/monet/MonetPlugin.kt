package hrx.plugin.monet

import androidx.annotation.NonNull
import com.kieronquinn.monetcompat.core.MonetActivityAccessException
import com.kieronquinn.monetcompat.core.MonetCompat
import com.kieronquinn.monetcompat.interfaces.MonetColorsChangedListener
import dev.kdrag0n.monet.theme.DynamicColorScheme

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** MonetPlugin */
class MonetPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private val listener : Listener = Listener()
  private lateinit var channel : MethodChannel

  private var _monet: MonetCompat? = null
  private val monet: MonetCompat
    get() {
      return if(_monet == null) throw MonetActivityAccessException()
      else _monet!!
    }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "monet/colors")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getCurrentColors") {
      result.success(fromColorsToMap(monet.getMonetColors()))
    } else {
      result.notImplemented()
    }
  }

  private fun fromColorsToMap(scheme: DynamicColorScheme): Map<String, Int> {
    val returnMap: MutableMap<String, Int> = emptyMap<String, Int>().toMutableMap()
    val associations = mapOf(
      "accent1" to scheme.accent1,
      "accent2" to scheme.accent2,
      "accent3" to scheme.accent3,
      "neutral1" to scheme.neutral1,
      "neutral2" to scheme.neutral2,
    )

    associations.forEach{(name, palette) ->
      palette.forEach{(num, color) ->
        returnMap["$name.$num"] = color.toLinearSrgb().toSrgb().quantize8()
      }
    }

    return returnMap
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    MonetCompat.setup(binding.activity)
    _monet = MonetCompat.getInstance()
    monet.addMonetColorsChangedListener(listener, false)
    monet.updateMonetColors()
  }

  override fun onDetachedFromActivity() {
    monet.removeMonetColorsChangedListener(listener)
    _monet = null
  }

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

  private inner class Listener : MonetColorsChangedListener {
    override fun onMonetColorsChanged(
      monet: MonetCompat,
      monetColors: DynamicColorScheme,
      isInitialChange: Boolean
    ) {
      channel.invokeMethod("updateColors", fromColorsToMap(monetColors))
    }
  }
}
