package com.alpwarestudio.wakeon

import com.alpwarestudio.wakeon.widget.WidgetDeviceStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WidgetDeviceStore.CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "syncWidgetDevices" -> {
                    @Suppress("UNCHECKED_CAST")
                    val devices = call.arguments as? List<Map<String, Any?>>
                    if (devices == null) {
                        result.error("invalid_arguments", "Expected a device list.", null)
                        return@setMethodCallHandler
                    }

                    WidgetDeviceStore.syncDevices(applicationContext, devices)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
