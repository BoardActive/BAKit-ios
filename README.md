# BAKit-iOS

![Cocoapods platforms](https://img.shields.io/cocoapods/p/BAKit)
![GitHub top language](https://img.shields.io/github/languages/top/boardactive/BAKit-ios?color=orange)
![Cocoapods](https://img.shields.io/cocoapods/v/BAKit-iOS?color=red)

<img src="https://avatars0.githubusercontent.com/u/38864287?s=200&v=4" width="96" height="96"/>

**Location-based notifications for personalized user engagement and retention campaigns.**

BoardActive's platform connects brands to consumers using location-based engagement. Set up geofences around any location, measure foot-traffic, and engage users with personalized notifications when they enter those areas.

📍 **It's not about Advertising... It's about *PERSONALIZING***

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Configuration](#configuration)
- [Integration](#integration)
- [Example App](#example-app)
- [Support](#support)

---

## Features

✅ **Geofence Monitoring** - Automatic location-based notifications
✅ **Firebase Cloud Messaging** - Remote push notification delivery
✅ **Campaign Analytics** - Track user engagement and foot-traffic
✅ **Background Monitoring** - Works even when app is closed
✅ **Rich Notifications** - Images, actions, and custom content

---

## Requirements

| Component | Version |
|-----------|---------|
| **iOS** | 12.0+ |
| **Swift** | 4.0+ |
| **Xcode** | 11.0+ |
| **CocoaPods** | 1.0+ |

**You'll Need:**
1. A [BoardActive account](https://app.boardactive.com/signup) (free to create)
2. A Firebase project with Cloud Messaging enabled
3. Your app's APNS certificate configured in Firebase

---

## Quick Start

### 1️⃣ Install via CocoaPods

```bash
# Add to your Podfile
pod 'BAKit-iOS'
pod 'Firebase/Core'
pod 'Firebase/Messaging'

# Install
pod install
```

### 2️⃣ Get Your Credentials

- **BoardActive AppId & AppKey**: Email [taylor@boardactive.com](mailto:taylor@boardactive.com) with your Firebase Server Key
- **GoogleService-Info.plist**: Download from [Firebase Console](https://console.firebase.google.com/)

### 3️⃣ Initialize in AppDelegate

```swift
import BAKit
import Firebase

func application(_ application: UIApplication,
                 willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()

    // Store your BoardActive credentials
    BoardActive.client.userDefaults?.set(YOUR_APP_ID, forKey: "AppId")
    BoardActive.client.userDefaults?.set("YOUR_APP_KEY", forKey: "AppKey")

    return true
}
```

### 4️⃣ Setup SDK After Login

```swift
// After user authentication, start geofence monitoring
(UIApplication.shared.delegate as! AppDelegate).setupSDK()
```

**That's it!** The SDK will now monitor geofences and deliver notifications.

---

## Installation

### CocoaPods (Recommended)

1. **Create a Podfile** (if you don't have one):
   ```bash
   pod init
   ```

2. **Add BAKit-iOS to your Podfile**:
   ```ruby
   platform :ios, '12.0'
   use_frameworks!

   target 'YourAppName' do
     pod 'BAKit-iOS'
     pod 'Firebase/Core'
     pod 'Firebase/Messaging'
   end
   ```

3. **Install dependencies**:
   ```bash
   pod repo update
   pod install
   ```

4. **Open the `.xcworkspace` file** (not `.xcodeproj`):
   ```bash
   open YourAppName.xcworkspace
   ```

5. **Add `GoogleService-Info.plist`** to your project:
   - Download from Firebase Console → Project Settings
   - Drag the file into your Xcode project

---

## Configuration

### Step 1: Info.plist Permissions

Add these keys to your `Info.plist`:

#### Location Permissions (Required)
```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We use your location to send personalized offers when you visit nearby places.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to send personalized offers when you visit nearby places.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>We use your location to send personalized offers even when the app is closed.</string>
```

#### Photo Library (Optional - for saving notification images)
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save offer images to your photo library.</string>
```

### Step 2: Enable Capabilities

In Xcode, go to **Your Target → Signing & Capabilities**:

#### Background Modes
- ✅ Location updates
- ✅ Remote notifications
- ✅ Background fetch

#### Push Notifications
- ✅ Enable Push Notifications capability

#### App Groups (for Notification Service Extension)
- ✅ Add an app group: `group.{your-bundle-id}`

---

## Integration

### Full AppDelegate Setup

Here's the complete AppDelegate implementation. Copy and customize for your app:

<details>
<summary><strong>Click to expand complete AppDelegate.swift</strong></summary>

```swift
import UIKit
import BAKit
import Firebase
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?

    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    var notificationPermission = false

    // MARK: - App Lifecycle

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        // Store BoardActive credentials
        BoardActive.client.userDefaults?.set(YOUR_APP_ID, forKey: "AppId")
        BoardActive.client.userDefaults?.set("YOUR_APP_KEY", forKey: "AppKey")

        return true
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup location manager for background monitoring
        locationManager = CLLocationManager()
        locationManager?.delegate = self

        // Handle app launch from significant location change
        if launchOptions?[.location] != nil {
            locationManager?.startMonitoringSignificantLocationChanges()
        }

        return true
    }

    // MARK: - SDK Setup

    func setupSDK() {
        let operationQueue = OperationQueue()

        let registerDeviceOperation = BlockOperation {
            BoardActive.client.registerDevice { (parsedJSON, err) in
                guard err == nil, parsedJSON != nil else {
                    print("❌ [BAKit] Device registration failed")
                    return
                }

                BoardActive.client.userDefaults?.set(true, forKey: String.ConfigKeys.DeviceRegistered)
                BoardActive.client.userDefaults?.synchronize()

                // Update user permissions
                var locationEnabled = false
                if CLLocationManager.locationServicesEnabled() {
                    switch CLLocationManager.authorizationStatus() {
                    case .authorizedAlways, .authorizedWhenInUse:
                        locationEnabled = true
                    default:
                        locationEnabled = false
                    }
                }

                let permissions: [String: Any] = [
                    "notificationPermission": self.notificationPermission,
                    "locationPermission": locationEnabled
                ]
                self.updateUserAttributes(dictParameter: permissions)
            }
        }

        let requestNotificationsOperation = BlockOperation {
            self.requestNotifications()
        }

        let monitorLocationOperation = BlockOperation {
            DispatchQueue.main.async {
                BoardActive.client.monitorLocation()
            }
        }

        let saveGeofenceOperation = BlockOperation {
            BoardActive.client.storeAppLocations()
        }

        // Set operation dependencies
        requestNotificationsOperation.addDependency(registerDeviceOperation)
        monitorLocationOperation.addDependency(requestNotificationsOperation)
        monitorLocationOperation.addDependency(saveGeofenceOperation)

        // Execute operations
        operationQueue.addOperations([
            registerDeviceOperation,
            requestNotificationsOperation,
            saveGeofenceOperation,
            monitorLocationOperation
        ], waitUntilFinished: false)
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if BoardActive.client.userDefaults?.object(forKey: "dateNotificationRequested") == nil {
                BoardActive.client.userDefaults?.set(Date().iso8601, forKey: "dateNotificationRequested")
                BoardActive.client.userDefaults?.synchronize()
            }

            guard error == nil, granted else {
                print("⚠️ [BAKit] Notification permission denied")
                return
            }

            self.notificationPermission = granted
        }

        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    private func updateUserAttributes(dictParameter: [String: Any]) {
        let tempData = ["attributes": ["stock": dictParameter]]
        BoardActive.client.updateUserData(body: tempData) { (response, error) in
            if let error = error {
                print("⚠️ [BAKit] Failed to update user attributes: \(error)")
            }
        }
    }
}

// MARK: - Firebase Messaging Delegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        BoardActive.client.userDefaults?.set(token, forKey: "deviceToken")
        BoardActive.client.userDefaults?.synchronize()
    }
}

// MARK: - Notification Delegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("✅ [BAKit] APNs token: \(tokenString)")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ [BAKit] APNs registration failed: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle silent push for geofence updates
        if let type = userInfo["type"] as? String,
           ["update", "place_update", "campaign"].contains(type) {
            BoardActive.client.userDefaults?.set(true, forKey: String.ConfigKeys.silentPushReceived)
        }

        completionHandler(.newData)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Track notification opened event
        if let messageId = userInfo["baMessageId"] as? String,
           let firebaseId = userInfo["gcm.message_id"] as? String,
           let notificationId = userInfo["baNotificationId"] as? String {
            BoardActive.client.postEvent(
                name: String.Opened,
                messageId: messageId,
                firebaseNotificationId: firebaseId,
                notificationId: notificationId
            )
        }

        completionHandler()
    }
}

// MARK: - Location Manager Delegate

extension AppDelegate: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            BoardActive.client.stopMonitoring(region: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        BoardActive.client.currentLocation = location

        // Check if silent push requires geofence refresh
        let silentPush = BoardActive.client.userDefaults?.value(forKey: String.ConfigKeys.silentPushReceived) as? Bool ?? false
        if silentPush {
            BoardActive.client.userDefaults?.set(false, forKey: String.ConfigKeys.silentPushReceived)
            UserDefaults(suiteName: "BAKit")?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
            BoardActive.client.storeAppLocations()
        }
    }
}
```

</details>

---

### Notification Service Extension (Required for Rich Notifications)

1. **Add Notification Service Extension**:
   - In Xcode: File → New → Target
   - Select "Notification Service Extension"
   - Name it `NotificationServiceExtension`

2. **Replace `NotificationService.swift` with**:

```swift
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        defer {
            contentHandler(bestAttemptContent ?? request.content)
        }

        guard let attachment = request.attachment else { return }
        bestAttemptContent?.attachments = [attachment]
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension UNNotificationRequest {
    var attachment: UNNotificationAttachment? {
        guard let imageURL = content.userInfo["imageUrl"] as? String,
              let url = URL(string: imageURL),
              let imageData = try? Data(contentsOf: url) else {
            return nil
        }
        return try? UNNotificationAttachment(data: imageData, options: nil)
    }
}

extension UNNotificationAttachment {
    convenience init(data: Data, options: [NSObject: AnyObject]?) throws {
        let fileManager = FileManager.default
        let tempFolder = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)

        try fileManager.createDirectory(at: tempFolder, withIntermediateDirectories: true)

        let fileURL = tempFolder.appendingPathComponent(UUID().uuidString + ".jpg")
        try data.write(to: fileURL)
        try self.init(identifier: UUID().uuidString, url: fileURL, options: options)
    }
}
```

3. **Configure Bundle ID**: `{your-main-bundle-id}.NotificationServiceExtension`

---

## Usage

### Starting the SDK

Call `setupSDK()` after user authentication (typically after login):

**UIKit:**
```swift
(UIApplication.shared.delegate as! AppDelegate).setupSDK()
```

**SwiftUI:**
```swift
@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

var body: some View {
    ContentView()
        .onAppear {
            appDelegate.setupSDK()
        }
}
```

### Creating Geofences

1. Log in to your [BoardActive Dashboard](https://app.boardactive.com)
2. Navigate to **Places** → **Create New Place**
3. Set location, radius, and notification message
4. Save and activate

The SDK automatically downloads and monitors geofences. When users enter a geofence, they'll receive your notification.

---

## Example App

Check out the [example app](https://github.com/BoardActive/BAKit-ios/tree/master/Example) included in this repository:

```bash
cd Example
pod install
open BAKit-iOS.xcworkspace
```

The example demonstrates:
- Complete SDK integration
- Notification handling
- Location permission flow
- Background geofence monitoring

---

## Troubleshooting

### Location not working in background?
- Ensure "Location updates" is enabled in Background Modes
- Request "Always" location permission, not just "When In Use"
- Check that user granted "Always Allow" in Settings

### Notifications not appearing?
- Verify Firebase Cloud Messaging is configured correctly
- Check APNS certificate is uploaded to Firebase
- Ensure notification permissions are granted
- Verify `GoogleService-Info.plist` is in your project

### Geofences not monitoring?
- Ensure `setupSDK()` is called after user authentication
- Check BoardActive dashboard has active geofences near test location
- iOS limits to 20 monitored geofences per app

---

## API Reference

### BoardActive Client

```swift
// Register device with BoardActive
BoardActive.client.registerDevice { (response, error) in }

// Monitor location for geofences
BoardActive.client.monitorLocation()

// Download geofences from server
BoardActive.client.storeAppLocations()

// Update user attributes
BoardActive.client.updateUserData(body: attributes) { (response, error) in }

// Track events
BoardActive.client.postEvent(name: eventName,
                             messageId: id,
                             firebaseNotificationId: fbId,
                             notificationId: notifId)
```

---

## Support

**Need Help?**

- 📧 Email: [support@boardactive.com](mailto:support@boardactive.com)
- 🌐 Website: [boardactive.com](https://www.boardactive.com)
- 📖 Dashboard: [app.boardactive.com](https://app.boardactive.com)
- 🐛 Issues: [GitHub Issues](https://github.com/BoardActive/BAKit-ios/issues)

**Get Started:**
- [Create BoardActive Account](https://app.boardactive.com/signup)
- [Firebase Console](https://console.firebase.google.com/)

---

## License

BAKit-iOS is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

**Made with ❤️ by BoardActive**
