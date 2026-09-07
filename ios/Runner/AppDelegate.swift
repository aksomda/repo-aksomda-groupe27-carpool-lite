import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Clé API Google Maps pour iOS.
    // Remplacez YOUR_GOOGLE_MAPS_API_KEY par votre propre clé
    // (https://console.cloud.google.com/google/maps-apis/credentials),
    // avec l'API "Maps SDK for iOS" activée.
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
