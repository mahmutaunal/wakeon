package com.alpwarestudio.wakeon.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/** Shared native storage for Wakeon widgets. */
object WidgetDeviceStore {
    const val CHANNEL_NAME = "com.alpwarestudio.wakeon/widget"

    private const val PREFS_NAME = "wakeon_widget_data"
    private const val KEY_DEVICES = "devices"
    private const val KEY_UPDATED_AT = "updated_at"
    private const val DEVICE_PREF_PREFIX = "widget_device_"

    fun syncDevices(context: Context, devices: List<Map<String, Any?>>) {
        val payload = JSONArray()

        devices.forEach { item ->
            val id = item["id"] as? String ?: return@forEach
            val name = item["name"] as? String ?: return@forEach
            val macAddress = item["macAddress"] as? String ?: return@forEach
            val broadcastAddress = item["broadcastAddress"] as? String ?: return@forEach
            val port = (item["port"] as? Number)?.toInt() ?: return@forEach

            payload.put(
                JSONObject()
                    .put("id", id)
                    .put("name", name)
                    .put("type", item["type"] as? String ?: "other")
                    .put("macAddress", macAddress)
                    .put("broadcastAddress", broadcastAddress)
                    .put("port", port)
                    .put("isFavorite", item["isFavorite"] as? Boolean ?: false),
            )
        }

        preferences(context)
            .edit()
            .putString(KEY_DEVICES, payload.toString())
            .putLong(KEY_UPDATED_AT, System.currentTimeMillis())
            .apply()

        refreshWidgets(context)
    }

    fun getDevices(context: Context): List<WidgetDevice> {
        val rawValue = preferences(context).getString(KEY_DEVICES, null) ?: return emptyList()

        return runCatching {
            val items = JSONArray(rawValue)
            buildList {
                for (index in 0 until items.length()) {
                    val item = items.optJSONObject(index) ?: continue
                    val id = item.optString("id").trim()
                    val name = item.optString("name").trim()
                    val macAddress = item.optString("macAddress").trim()
                    val broadcastAddress = item.optString("broadcastAddress").trim()
                    val port = item.optInt("port", -1)

                    if (id.isEmpty() || name.isEmpty() || macAddress.isEmpty() || broadcastAddress.isEmpty()) {
                        continue
                    }

                    if (port !in 1..65535) {
                        continue
                    }

                    add(
                        WidgetDevice(
                            id = id,
                            name = name,
                            type = item.optString("type", "other"),
                            macAddress = macAddress,
                            broadcastAddress = broadcastAddress,
                            port = port,
                            isFavorite = item.optBoolean("isFavorite", false),
                        ),
                    )
                }
            }
        }.getOrDefault(emptyList())
    }

    fun saveSelectedDeviceId(context: Context, appWidgetId: Int, deviceId: String) {
        preferences(context)
            .edit()
            .putString(selectedDeviceKey(appWidgetId), deviceId)
            .apply()
    }

    fun getSelectedDevice(context: Context, appWidgetId: Int): WidgetDevice? {
        val selectedId = preferences(context).getString(selectedDeviceKey(appWidgetId), null)
            ?: return null

        return getDevices(context).firstOrNull { it.id == selectedId }
    }

    fun removeWidget(context: Context, appWidgetId: Int) {
        preferences(context).edit().remove(selectedDeviceKey(appWidgetId)).apply()
    }

    private fun selectedDeviceKey(appWidgetId: Int): String = "$DEVICE_PREF_PREFIX$appWidgetId"

    private fun preferences(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private fun refreshWidgets(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, DeviceWakeWidgetProvider::class.java),
        )

        if (ids.isNotEmpty()) {
            DeviceWakeWidgetProvider.updateWidgets(context, manager, ids)
        }
    }
}
