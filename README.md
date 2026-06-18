# Wakeon

[![Google Play](https://img.shields.io/badge/Google_Play-Download-success?logo=google-play)](https://play.google.com/store/apps/details?id=com.alpwarestudio.wakeon)

Wakeon is a simple, modern, and open-source Wake-on-LAN application built with Flutter.

Wake your computers, servers, NAS devices, and other Wake-on-LAN compatible hardware with a single tap.

Designed with simplicity in mind, Wakeon focuses on reliability, privacy, and a clean Material 3 user experience.

## Features

### Core Features

- Wake-on-LAN magic packet support
- Add and manage multiple devices
- Edit and delete saved devices
- Automatic last wake tracking
- Local device storage
- Fast one-tap wake action

### Network Tools

- Local network discovery helper
- Broadcast address assistance
- Manual device configuration
- Remote Wake guide

### User Experience

- Material 3 design
- Light theme support
- Dark theme support
- Responsive layout
- Beginner-friendly setup flow

### 🔒 Secure Device Sharing

- Optional share expiration
- Encrypted share links
- Easy import/export

### 🔐 Privacy First

- No account required
- No sign-in required
- No cloud dependency
- No ads
- No analytics
- No tracking
- Local-only device storage
- Device data remains on your device
- No user accounts

## Screenshots

| Home (Light) | Add Device |
|--------------|------------|
| ![](assets/screenshots/android/en/1.png) | ![](assets/screenshots/android/en/2.png) |

| Network Scan | Settings |
|-------------|----------|
| ![](assets/screenshots/android/en/3.png) | ![](assets/screenshots/android/en/4.png) |

| Remote Wake Guide | Home (Dark) |
|------------------|-------------|
| ![](assets/screenshots/android/en/5.png) | ![](assets/screenshots/android/en/6.png) |

## How Wake-on-LAN Works

Wake-on-LAN (WOL) allows a powered-off or sleeping computer to be started remotely by sending a special network packet called a Magic Packet.

Wakeon generates and sends this packet to the selected device.

Typical configuration:

```text
MAC Address: AA:BB:CC:DD:EE:FF
Broadcast Address: 192.168.1.255
Port: 9
```

## Getting Started

### 1. Enable Wake-on-LAN in BIOS/UEFI

Enable one of the following options depending on your motherboard:

- Wake-on-LAN
- Wake by PCI-E
- Power On By PCI-E
- Resume By LAN
- PME Event Wake Up

### 2. Configure Your Network Adapter

On Windows:

1. Open Device Manager
2. Open your Ethernet adapter properties
3. Enable:
   - Allow this device to wake the computer
   - Only allow a magic packet to wake the computer
4. Enable Wake-on-LAN related options under the Advanced tab

### 3. Add Your Device to Wakeon

You will typically need:

- Device name
- MAC address
- Broadcast address
- Port (usually 9)

## Finding Your MAC Address

### Windows

Open Command Prompt:

```bash
ipconfig /all
```

Use the Physical Address value of your Ethernet adapter.

### macOS

```bash
ifconfig
```

### Linux

```bash
ip addr
```

## Remote Wake

Wake-on-LAN was originally designed for local networks.

For remote wake scenarios, Wakeon recommends using:

- WireGuard
- Tailscale
- ZeroTier
- Router VPN solutions

Advanced WAN setups using:

- Port forwarding
- Static DHCP lease
- MAC/IP binding
- Broadcast forwarding

may work depending on your router and ISP.

## Supported Platforms

- Android
- iOS

Planned:

- Windows
- macOS
- Linux

## Tech Stack

- Flutter
- Dart
- Riverpod
- SharedPreferences
- Material 3
- Cryptography Package

## Privacy Policy

Wakeon does not collect, transmit, or store personal information.

All device information remains on the user's device.

For details, see [Privacy Policy](PRIVACY_POLICY.md).

Wakeon does not use:

- Analytics services
- Advertising SDKs
- Tracking frameworks
- User accounts

## Open Source

Wakeon is open-source and community-friendly.

Contributions, bug reports, feature requests, and pull requests are welcome.

## Roadmap

- Improved network discovery
- Better hostname detection
- Automatic MAC address detection
- Windows support
- macOS support
- Linux support
- Additional accessibility improvements

## License

MIT License

Copyright (c) 2026 AlpWare Studio
