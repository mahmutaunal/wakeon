import AppIntents
import Network
import SwiftUI
import WidgetKit

private let appGroupId = "group.com.alpwarestudio.wakeon"

struct WidgetDevice: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let type: String
    let macAddress: String
    let broadcastAddress: String
    let port: Int
    let isFavorite: Bool
}

enum WidgetDeviceStore {
    static func devices() -> [WidgetDevice] {
        guard
            let defaults = UserDefaults(suiteName: appGroupId),
            let data = defaults.data(forKey: "devices"),
            let devices = try? JSONDecoder().decode([WidgetDevice].self, from: data)
        else { return [] }

        return devices
    }

    static func device(id: String) -> WidgetDevice? {
        devices().first { $0.id == id }
    }
}

struct DeviceEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Device"
    static var defaultQuery = DeviceEntityQuery()

    let id: String
    let name: String
    let macAddress: String
    let broadcastAddress: String
    let port: Int

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            subtitle: LocalizedStringResource(stringLiteral: broadcastAddress)
        )
    }

    init(device: WidgetDevice) {
        id = device.id
        name = device.name
        macAddress = device.macAddress
        broadcastAddress = device.broadcastAddress
        port = device.port
    }
}

struct DeviceEntityQuery: EntityQuery {
    func entities(for identifiers: [DeviceEntity.ID]) async throws -> [DeviceEntity] {
        WidgetDeviceStore.devices()
            .filter { identifiers.contains($0.id) }
            .map(DeviceEntity.init(device:))
    }

    func suggestedEntities() async throws -> [DeviceEntity] {
        WidgetDeviceStore.devices().map(DeviceEntity.init(device:))
    }

    func defaultResult() async -> DeviceEntity? {
        WidgetDeviceStore.devices().first.map(DeviceEntity.init(device:))
    }
}

struct SelectWakeDeviceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Wakeon Device"
    static var description = IntentDescription("Choose the device shown on this Wakeon widget.")

    @Parameter(title: "Device")
    var device: DeviceEntity?
}

struct WakeDeviceIntent: AppIntent {
    static var title: LocalizedStringResource = "Wake Device"
    static var description = IntentDescription("Sends a Wake-on-LAN packet to the selected device.")
    static var openAppWhenRun = false

    @Parameter(title: "Device ID")
    var deviceId: String

    init() {}

    init(deviceId: String) {
        self.deviceId = deviceId
    }

    func perform() async throws -> some IntentResult {
        guard let device = WidgetDeviceStore.device(id: deviceId) else {
            return .result()
        }

        try await WakeOnLanSender.wake(device: device)
        return .result()
    }
}

enum WakeOnLanSender {
    static func wake(device: WidgetDevice) async throws {
        let packet = try magicPacket(macAddress: device.macAddress)
        let host = NWEndpoint.Host(device.broadcastAddress)
        let port = NWEndpoint.Port(rawValue: UInt16(device.port)) ?? NWEndpoint.Port(rawValue: 9)!
        let connection = NWConnection(host: host, port: port, using: .udp)

        try await withCheckedThrowingContinuation { continuation in
            var didResume = false

            func finish(_ result: Result<Void, Error>) {
                guard !didResume else { return }
                didResume = true
                connection.cancel()
                continuation.resume(with: result)
            }

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    connection.send(content: packet, completion: .contentProcessed { error in
                        if let error { finish(.failure(error)) }
                        else { finish(.success(())) }
                    })
                case .failed(let error):
                    finish(.failure(error))
                default:
                    break
                }
            }

            connection.start(queue: DispatchQueue.global(qos: .utility))
        }
    }

    private static func magicPacket(macAddress: String) throws -> Data {
        let cleanMac = macAddress.filter { $0.isHexDigit }
        guard cleanMac.count == 12 else { throw WakeOnLanError.invalidMacAddress }

        var macBytes = [UInt8]()
        var index = cleanMac.startIndex
        while index < cleanMac.endIndex {
            let nextIndex = cleanMac.index(index, offsetBy: 2)
            guard let byte = UInt8(cleanMac[index..<nextIndex], radix: 16) else {
                throw WakeOnLanError.invalidMacAddress
            }
            macBytes.append(byte)
            index = nextIndex
        }

        var data = Data(repeating: 0xFF, count: 6)
        for _ in 0..<16 { data.append(contentsOf: macBytes) }
        return data
    }

    enum WakeOnLanError: Error { case invalidMacAddress }
}

struct WakeonWidgetEntry: TimelineEntry {
    let date: Date
    let device: WidgetDevice?
}

struct WakeonWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WakeonWidgetEntry {
        WakeonWidgetEntry(
            date: Date(),
            device: WidgetDevice(
                id: "placeholder",
                name: "My Computer",
                type: "desktop",
                macAddress: "00:11:22:33:44:55",
                broadcastAddress: "192.168.1.255",
                port: 9,
                isFavorite: true
            )
        )
    }

    func snapshot(for configuration: SelectWakeDeviceIntent, in context: Context) async -> WakeonWidgetEntry {
        WakeonWidgetEntry(date: Date(), device: selectedDevice(configuration: configuration))
    }

    func timeline(for configuration: SelectWakeDeviceIntent, in context: Context) async -> Timeline<WakeonWidgetEntry> {
        Timeline(
            entries: [WakeonWidgetEntry(date: Date(), device: selectedDevice(configuration: configuration))],
            policy: .never
        )
    }

    private func selectedDevice(configuration: SelectWakeDeviceIntent) -> WidgetDevice? {
        if let id = configuration.device?.id,
           let device = WidgetDeviceStore.device(id: id) {
            return device
        }
        return WidgetDeviceStore.devices().first
    }
}

struct WakeonWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WakeonWidgetEntry

    var body: some View {
        Group {
            if let device = entry.device {
                content(for: device)
            } else {
                emptyContent
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    @ViewBuilder
    private func content(for device: WidgetDevice) -> some View {
        switch family {
        case .systemMedium:
            HStack(spacing: 14) {
                deviceIdentity(device)
                    .frame(maxWidth: .infinity, alignment: .leading)

                wakeButton(device, compact: true)
                    .frame(width: 112)
            }
        default:
            VStack(alignment: .leading, spacing: 10) {
                deviceIdentity(device)
                wakeButton(device, compact: false)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }

    private func deviceIdentity(_ device: WidgetDevice) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.opacity(0.14))
                Image(systemName: symbolName(for: device.type))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(device.name)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(device.broadcastAddress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private func wakeButton(_ device: WidgetDevice, compact: Bool) -> some View {
        Button(intent: WakeDeviceIntent(deviceId: device.id)) {
            HStack(spacing: 7) {
                Image(systemName: "power")
                Text("Wake")
            }
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, minHeight: compact ? 38 : 40)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 13))
        .tint(Color.accentColor.opacity(0.72))
    }

    private var emptyContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.opacity(0.14))
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 40, height: 40)

            Text("Wakeon")
                .font(.system(.headline, design: .rounded, weight: .semibold))

            Text("Add a device in the app, then edit this widget to select it.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
    }

    private func symbolName(for type: String) -> String {
        switch type.lowercased() {
        case "laptop": return "laptopcomputer"
        case "server", "nas": return "externaldrive.connected.to.line.below"
        case "router": return "wifi.router"
        default: return "desktopcomputer"
        }
    }
}

@main
struct WakeonWidgetBundle: WidgetBundle {
    var body: some Widget { WakeonWidget() }
}

struct WakeonWidget: Widget {
    let kind = "WakeonDeviceWakeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectWakeDeviceIntent.self,
            provider: WakeonWidgetProvider()
        ) { entry in
            WakeonWidgetView(entry: entry)
        }
        .configurationDisplayName("Wakeon")
        .description("Wake a saved computer directly from your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
