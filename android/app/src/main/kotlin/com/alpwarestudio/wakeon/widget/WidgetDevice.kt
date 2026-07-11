package com.alpwarestudio.wakeon.widget

/** A minimal immutable snapshot of a Wakeon device used by app widgets. */
data class WidgetDevice(
    val id: String,
    val name: String,
    val type: String,
    val macAddress: String,
    val broadcastAddress: String,
    val port: Int,
    val isFavorite: Boolean,
)
