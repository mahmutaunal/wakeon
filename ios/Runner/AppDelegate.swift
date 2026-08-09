import Flutter
import StoreKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      WidgetChannelRegistrar.register(binaryMessenger: controller.binaryMessenger)
      AppStoreChannelRegistrar.register(
        binaryMessenger: controller.binaryMessenger,
        presenter: controller
      )
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

/// Presents the App Store product page without navigating away from Wakeon.
enum AppStoreChannelRegistrar {
  private static let channelName = "com.alpwarestudio.wakeon/app_store"

  static func register(
    binaryMessenger: FlutterBinaryMessenger,
    presenter: UIViewController
  ) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "showStoreProduct" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let appStoreId = arguments["appStoreId"] as? NSNumber
      else {
        result(FlutterError(
          code: "invalid_arguments",
          message: "A numeric App Store ID is required.",
          details: nil
        ))
        return
      }

      let storeController = SKStoreProductViewController()
      storeController.delegate = StoreProductDismissDelegate.shared
      storeController.loadProduct(
        withParameters: [
          SKStoreProductParameterITunesItemIdentifier: appStoreId
        ]
      ) { loaded, error in
        guard loaded, error == nil else {
          result(FlutterError(
            code: "store_product_unavailable",
            message: error?.localizedDescription ?? "The App Store page could not be loaded.",
            details: nil
          ))
          return
        }
        presenter.present(storeController, animated: true) {
          result(true)
        }
      }
    }
  }
}

private final class StoreProductDismissDelegate: NSObject, SKStoreProductViewControllerDelegate {
  static let shared = StoreProductDismissDelegate()

  func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    viewController.dismiss(animated: true)
  }
}
