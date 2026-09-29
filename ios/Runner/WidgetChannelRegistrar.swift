import Flutter
import Foundation
import WidgetKit

final class WidgetChannelRegistrar {
  private static let channelName = "com.alpwarestudio.wakeon/widget"
  private static let appGroupId = "group.com.alpwarestudio.wakeon.shared"
  private static var didRegister = false

  static func register(binaryMessenger: FlutterBinaryMessenger) {
    guard !didRegister else { return }
    didRegister = true

    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "syncWidgetDevices" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard let devices = call.arguments as? [[String: Any]] else {
        result(FlutterError(code: "invalid_arguments", message: "Expected a device list.", details: nil))
        return
      }

      syncWidgetDevices(devices)
      result(nil)
    }
  }

  private static func syncWidgetDevices(_ devices: [[String: Any]]) {
    let sanitizedDevices = devices.compactMap { item -> [String: Any]? in
      guard
        let id = item["id"] as? String, !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        let name = item["name"] as? String, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        let macAddress = item["macAddress"] as? String, !macAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        let broadcastAddress = item["broadcastAddress"] as? String, !broadcastAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        let port = item["port"] as? Int, (1...65535).contains(port)
      else {
        return nil
      }

      return [
        "id": id,
        "name": name,
        "type": item["type"] as? String ?? "other",
        "macAddress": macAddress,
        "broadcastAddress": broadcastAddress,
        "port": port,
        "isFavorite": item["isFavorite"] as? Bool ?? false,
      ]
    }

    guard let defaults = UserDefaults(suiteName: appGroupId) else {
      return
    }

    if let data = try? JSONSerialization.data(withJSONObject: sanitizedDevices, options: []) {
      defaults.set(data, forKey: "devices")
      defaults.set(Date().timeIntervalSince1970, forKey: "updatedAt")
      defaults.synchronize()
    }

    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}
