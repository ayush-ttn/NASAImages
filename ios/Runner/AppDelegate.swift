import UIKit
import Flutter
import ImageIO

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var imageSaveResult: FlutterResult?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "ayush.app.nasaImages/image",
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        // Note: this method is invoked on the UI thread.
        if call.method == "saveImage", let arg = call.arguments as? [FlutterStandardTypedData] {
            if let imageData = arg.first?.data, let image = UIImage(data: imageData)
            {
                self.imageSaveResult = result
                let saveQueue = DispatchQueue(label: "ImageSaveQueue")
                saveQueue.async {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.imageSaved(_:error:context:)), nil);
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    @objc func imageSaved(_ image: UIImage, error: NSError?, context: UnsafeRawPointer) {
        DispatchQueue.main.async {
            guard error == nil else {
                self.imageSaveResult?(FlutterError(code: "FAILED", message: error?.localizedDescription, details: nil))
                return
            }
            self.imageSaveResult?(NSNumber(value: true))
        }
    }
}
//- (void)image:(UIImage *)image
//didFinishSavingWithError:(NSError *)error
////contextInfo:(void *)contextInfo

