package com.alpwarestudio.wakeon.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.ScrollView
import android.widget.TextView
import com.alpwarestudio.wakeon.R

class DeviceWakeWidgetConfigureActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private var selectedDeviceId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        renderContent()
    }

    private fun renderContent() {
        val devices = WidgetDeviceStore.getDevices(this)
        val previousSelection = WidgetDeviceStore.getSelectedDevice(this, appWidgetId)?.id
        selectedDeviceId = previousSelection ?: devices.firstOrNull()?.id

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(20), dp(20), dp(20))
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            )
        }

        root.addView(
            TextView(this).apply {
                text = getString(R.string.widget_config_title)
                textSize = 22f
                setTypeface(typeface, android.graphics.Typeface.BOLD)
            },
        )

        root.addView(
            TextView(this).apply {
                text = getString(R.string.widget_config_subtitle)
                textSize = 15f
                setPadding(0, dp(8), 0, dp(16))
            },
        )

        if (devices.isEmpty()) {
            root.addView(
                TextView(this).apply {
                    text = getString(R.string.widget_config_empty)
                    textSize = 16f
                    setPadding(0, dp(24), 0, dp(24))
                },
            )
        } else {
            val radioGroup = RadioGroup(this).apply {
                orientation = RadioGroup.VERTICAL
            }

            devices.forEachIndexed { index, device ->
                val viewId = 10_000 + index
                radioGroup.addView(
                    RadioButton(this).apply {
                        id = viewId
                        text = getString(
                            R.string.widget_config_device_row,
                            device.name,
                            device.macAddress,
                            device.broadcastAddress,
                            device.port,
                        )
                        textSize = 16f
                        setPadding(0, dp(8), 0, dp(8))
                        isChecked = device.id == selectedDeviceId
                    },
                )
            }

            radioGroup.setOnCheckedChangeListener { _, checkedId ->
                val index = checkedId - 10_000
                selectedDeviceId = devices.getOrNull(index)?.id
            }

            root.addView(
                ScrollView(this).apply {
                    addView(radioGroup)
                    layoutParams = LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        0,
                        1f,
                    )
                },
            )
        }

        root.addView(
            Button(this).apply {
                text = getString(R.string.widget_config_save)
                gravity = Gravity.CENTER
                isEnabled = devices.isNotEmpty()
                setOnClickListener { saveSelection() }
            },
        )

        setContentView(root)
    }

    private fun saveSelection() {
        val deviceId = selectedDeviceId ?: return

        WidgetDeviceStore.saveSelectedDeviceId(this, appWidgetId, deviceId)
        DeviceWakeWidgetProvider.updateWidget(this, AppWidgetManager.getInstance(this), appWidgetId)

        val resultValue = android.content.Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        setResult(RESULT_OK, resultValue)
        finish()
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()
}
