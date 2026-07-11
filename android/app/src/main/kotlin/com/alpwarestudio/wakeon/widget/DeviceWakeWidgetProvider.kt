package com.alpwarestudio.wakeon.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import android.widget.Toast
import com.alpwarestudio.wakeon.MainActivity
import com.alpwarestudio.wakeon.R

class DeviceWakeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.action != ACTION_WAKE_DEVICE) {
            return
        }

        val appWidgetId = intent.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        )

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            return
        }

        val device = WidgetDeviceStore.getSelectedDevice(context, appWidgetId)
        if (device == null) {
            Toast.makeText(context, R.string.widget_device_missing, Toast.LENGTH_SHORT).show()
            updateWidget(context, AppWidgetManager.getInstance(context), appWidgetId)
            return
        }

        Thread {
            val result = runCatching { WakeOnLanSender.wake(device) }

            val message = if (result.isSuccess) {
                context.getString(R.string.widget_wake_sent, device.name)
            } else {
                context.getString(R.string.widget_wake_failed)
            }

            mainThreadToast(context, message)
        }.start()
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        appWidgetIds.forEach { appWidgetId ->
            WidgetDeviceStore.removeWidget(context, appWidgetId)
        }
    }

    companion object {
        private const val ACTION_WAKE_DEVICE = "com.alpwarestudio.wakeon.widget.ACTION_WAKE_DEVICE"

        fun updateWidgets(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray,
        ) {
            appWidgetIds.forEach { appWidgetId ->
                updateWidget(context, appWidgetManager, appWidgetId)
            }
        }

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val selectedDevice = WidgetDeviceStore.getSelectedDevice(context, appWidgetId)
            val views = RemoteViews(context.packageName, R.layout.device_wake_widget)

            if (selectedDevice == null) {
                views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_empty_title))
                views.setTextViewText(R.id.widget_subtitle, context.getString(R.string.widget_empty_subtitle))
                views.setTextViewText(R.id.widget_button_label, context.getString(R.string.widget_open_app))
                views.setOnClickPendingIntent(R.id.widget_button, openAppPendingIntent(context, appWidgetId))
                views.setOnClickPendingIntent(R.id.widget_root, configurePendingIntent(context, appWidgetId))
            } else {
                views.setTextViewText(R.id.widget_title, selectedDevice.name)
                views.setTextViewText(
                    R.id.widget_subtitle,
                    context.getString(
                        R.string.widget_device_detail,
                        selectedDevice.broadcastAddress,
                    ),
                )
                views.setTextViewText(R.id.widget_button_label, context.getString(R.string.widget_wake_action))
                views.setOnClickPendingIntent(R.id.widget_button, wakePendingIntent(context, appWidgetId))
                views.setOnClickPendingIntent(R.id.widget_root, configurePendingIntent(context, appWidgetId))
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun wakePendingIntent(context: Context, appWidgetId: Int): PendingIntent {
            val intent = Intent(context, DeviceWakeWidgetProvider::class.java).apply {
                action = ACTION_WAKE_DEVICE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }

            return PendingIntent.getBroadcast(
                context,
                appWidgetId,
                intent,
                pendingIntentFlags(mutable = false),
            )
        }

        private fun configurePendingIntent(context: Context, appWidgetId: Int): PendingIntent {
            val intent = Intent(context, DeviceWakeWidgetConfigureActivity::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }

            return PendingIntent.getActivity(
                context,
                appWidgetId + 100_000,
                intent,
                pendingIntentFlags(mutable = false),
            )
        }

        private fun openAppPendingIntent(context: Context, appWidgetId: Int): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            return PendingIntent.getActivity(
                context,
                appWidgetId + 200_000,
                intent,
                pendingIntentFlags(mutable = false),
            )
        }

        private fun pendingIntentFlags(mutable: Boolean): Int {
            val mutabilityFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (mutable) PendingIntent.FLAG_MUTABLE else PendingIntent.FLAG_IMMUTABLE
            } else {
                0
            }

            return PendingIntent.FLAG_UPDATE_CURRENT or mutabilityFlag
        }

        private fun mainThreadToast(context: Context, message: String) {
            android.os.Handler(context.mainLooper).post {
                Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
            }
        }
    }
}
