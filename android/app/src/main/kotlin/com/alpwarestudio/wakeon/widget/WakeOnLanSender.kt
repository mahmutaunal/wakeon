package com.alpwarestudio.wakeon.widget

import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress

/** Sends Wake-on-LAN magic packets without requiring the Flutter engine. */
object WakeOnLanSender {
    fun wake(device: WidgetDevice) {
        require(device.port in 1..65535) { "Invalid port." }

        val packet = buildMagicPacket(device.macAddress)
        val address = InetAddress.getByName(device.broadcastAddress)

        DatagramSocket().use { socket ->
            socket.broadcast = true
            socket.send(DatagramPacket(packet, packet.size, address, device.port))
        }
    }

    private fun buildMagicPacket(macAddress: String): ByteArray {
        val cleanMac = macAddress.replace(Regex("[^A-Fa-f0-9]"), "")
        require(cleanMac.length == 12) { "Invalid MAC address." }

        val macBytes = ByteArray(6)
        for (index in macBytes.indices) {
            macBytes[index] = cleanMac.substring(index * 2, index * 2 + 2).toInt(16).toByte()
        }

        return ByteArray(6 + 16 * macBytes.size).also { packet ->
            for (index in 0 until 6) {
                packet[index] = 0xFF.toByte()
            }

            var offset = 6
            repeat(16) {
                macBytes.copyInto(packet, offset)
                offset += macBytes.size
            }
        }
    }
}
