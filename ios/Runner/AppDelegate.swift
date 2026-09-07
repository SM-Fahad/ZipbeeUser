import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let mapsKey = (Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let keyToUse = (mapsKey != nil && !mapsKey!.isEmpty) ? mapsKey! : "AIzaSyA2_J7HSn0DmOrrTzBN5FJVJ23CeeUtmN4"
    GMSServices.provideAPIKey(keyToUse)
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
