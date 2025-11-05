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
- [Installation](#installation)
- [Configuration](#configuration)
- [Full Integration Guide](#full-integration-guide)
- [Example App](#example-app)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

---

## Features

✅ **Geofence Monitoring** - Automatic location-based notifications
✅ **Firebase Cloud Messaging** - Remote push notification delivery
✅ **Campaign Analytics** - Track user engagement and foot-traffic
✅ **Background Monitoring** - Works even when app is closed
✅ **Rich Notifications** - Images, actions, and custom content
✅ **Remote Configuration** - Update geofences via silent push
✅ **Duplicate Prevention** - Smart event tracking

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

## Installation

### Step 1: Install via CocoaPods

**Create a Podfile** (if you don't have one):
```bash
cd YourProjectDirectory
pod init
```

**Add BAKit-iOS to your Podfile**:
```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourAppName' do
  pod 'BAKit-iOS'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
end
```

**Install dependencies**:
```bash
pod repo update
pod install
```

**Open the workspace** (not the `.xcodeproj`):
```bash
open YourAppName.xcworkspace
```

### Step 2: Get Your Credentials

**BoardActive AppId & AppKey:**
- Email your Firebase Server Key to [taylor@boardactive.com](mailto:taylor@boardactive.com)
- You'll receive your AppId (integer) and AppKey (string)

**GoogleService-Info.plist:**
- Download from [Firebase Console](https://console.firebase.google.com/) → Project Settings
- Drag the file into your Xcode project

---

## Configuration

### Step 1: Info.plist Permissions

Add these keys to your `Info.plist` with descriptions explaining location usage:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We use your location to send personalized offers when you visit nearby places.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to send personalized offers when you visit nearby places.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>We use your location to send personalized offers even when the app is closed.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save offer images to your photo library.</string>
```

### Step 2: Enable Capabilities

In Xcode → **Your Target → Signing & Capabilities**:

**Enable Background Modes:**
- ✅ Location updates
- ✅ Remote notifications
- ✅ Background fetch
- ✅ Background processing

**Enable Push Notifications:**
- ✅ Add Push Notifications capability

**Enable App Groups:**
- ✅ Add app group: `group.{your-bundle-id}`

---

## Full Integration Guide

### AppDelegate.swift - Complete Implementation

This is the complete, production-ready AppDelegate with all features:

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

    // Flags for notification behavior management
    var isNotificationStatusActive = false
    var isApplicationInBackground = false
    var isAppActive = false
    var isReceviedEventUpdated = false

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
        BoardActive.client.userDefaults?.set(<#YOUR_APP_ID#>, forKey: "AppId")
        BoardActive.client.userDefaults?.set("<#YOUR_APP_KEY#>", forKey: "AppKey")

        return true
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup location manager for background monitoring
        locationManager = CLLocationManager()
        locationManager?.delegate = self

        // Handle app launch from significant location change (killed state)
        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            isNotificationStatusActive = true
            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager?.distanceFilter = kCLDistanceFilterNone
            locationManager?.pausesLocationUpdatesAutomatically = false
            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.startMonitoringSignificantLocationChanges()
            locationManager?.activityType = .otherNavigation
            locationManager?.startUpdatingLocation()
        }

        // Listen for permission update notifications
        NotificationCenter.default.addObserver(
            BoardActive.client,
            selector: #selector(BoardActive.client.updatePermissionStates),
            name: Notification.Name("Update user permission states"),
            object: nil
        )

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        isApplicationInBackground = true
        isAppActive = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        isNotificationStatusActive = true
        if isApplicationInBackground {
            NotificationCenter.default.post(name: Notification.Name("Update user permission states"), object: nil)
        }
        isAppActive = true
    }
}

// MARK: - SDK Setup

extension AppDelegate {

    /// Call this after user authentication to start SDK
    func setupSDK() {
        let operationQueue = OperationQueue()

        let registerDeviceOperation = BlockOperation {
            BoardActive.client.registerDevice { (parsedJSON, err) in
                guard err == nil, let parsedJSON = parsedJSON else {
                    print("❌ [BAKit] Device registration failed")
                    fatalError()
                }

                BoardActive.client.userDefaults?.set(true, forKey: String.ConfigKeys.DeviceRegistered)
                BoardActive.client.userDefaults?.synchronize()

                var locationSharingEnable = false
                if CLLocationManager.locationServicesEnabled() {
                    switch CLLocationManager.authorizationStatus() {
                    case .notDetermined, .restricted, .denied:
                        locationSharingEnable = false
                    case .authorizedAlways, .authorizedWhenInUse:
                        locationSharingEnable = true
                    default:
                        locationSharingEnable = false
                    }
                }

                let dictPara: [String: Any] = [
                    "notificationPermission": self.notificationPermission,
                    "locationPermission": locationSharingEnable,
                    "dateLastOpenedApp": Date().iso8601
                ]
                self.updateUserAttriubtes(dictParameter: dictPara)
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

        let saveGeofenceLocationOperation = BlockOperation {
            BoardActive.client.storeAppLocations()
        }

        // Set operation dependencies
        monitorLocationOperation.addDependency(requestNotificationsOperation)
        requestNotificationsOperation.addDependency(registerDeviceOperation)
        monitorLocationOperation.addDependency(saveGeofenceLocationOperation)

        // Execute operations
        operationQueue.addOperation(registerDeviceOperation)
        operationQueue.addOperation(requestNotificationsOperation)
        operationQueue.addOperation(monitorLocationOperation)
        operationQueue.addOperation(saveGeofenceLocationOperation)
    }

    public func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if BoardActive.client.userDefaults?.object(forKey: "dateNotificationRequested") == nil {
                BoardActive.client.userDefaults?.set(Date().iso8601, forKey: "dateNotificationRequested")
                BoardActive.client.userDefaults?.synchronize()
            }

            self.configureCategory()
            BoardActive.client.updatePermissionStates()

            guard error == nil, granted else {
                return
            }

            self.notificationPermission = granted
        }

        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    fileprivate func updateUserAttriubtes(dictParameter: [String: Any] = [:]) {
        let tempData = ["attributes": ["stock": dictParameter]]
        BoardActive.client.updateUserData(body: tempData) { (response, error) in
            print(response as Any)
        }
    }

    /// Track received and opened events in sequence
    public func updateAllNotificationStatus(_ userInfo: [AnyHashable: Any]) {
        let queue = OperationQueue()
        if let _ = userInfo["aps"],
           let messageId = userInfo["baMessageId"] as? String,
           let firebaseNotificationId = userInfo["gcm.message_id"] as? String,
           let notificationId = userInfo["baNotificationId"] as? String {
            queue.addOperation {
                print("received")
                BoardActive.client.postEvent(
                    name: String.Received,
                    messageId: messageId,
                    firebaseNotificationId: firebaseNotificationId,
                    notificationId: notificationId
                )
            }
            queue.addOperation {
                print("open called")
                BoardActive.client.postEvent(
                    name: String.Opened,
                    messageId: messageId,
                    firebaseNotificationId: firebaseNotificationId,
                    notificationId: notificationId
                )
            }
        }
    }

    /// Track only opened event
    public func notificationOpened(_ userInfo: [AnyHashable: Any]) {
        if let _ = userInfo["aps"],
           let messageId = userInfo["baMessageId"] as? String,
           let firebaseNotificationId = userInfo["gcm.message_id"] as? String,
           let notificationId = userInfo["baNotificationId"] as? String {
            BoardActive.client.postEvent(
                name: String.Opened,
                messageId: messageId,
                firebaseNotificationId: firebaseNotificationId,
                notificationId: notificationId
            ) {
                print("event updated")
            }
        }
    }

    /// Configure notification action buttons (Download button)
    private func configureCategory() {
        let downloadButton = UNNotificationAction(
            identifier: BoardActive.client.downloadActionIdentifier,
            title: "Download",
            options: UNNotificationActionOptions.foreground
        )

        let downloadCategory = UNNotificationCategory(
            identifier: BoardActive.client.categoryIdentifier,
            actions: [downloadButton],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([downloadCategory])
    }
}

// MARK: - Firebase Messaging Delegate

extension AppDelegate: MessagingDelegate {

    /// Receive FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        BoardActive.client.userDefaults?.set(token, forKey: "deviceToken")
        BoardActive.client.userDefaults?.synchronize()
    }
}

// MARK: - User Notification Center Delegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        print("\n[AppDelegate] APNs TOKEN: \(deviceTokenString)\n")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\n[AppDelegate] APNs TOKEN FAIL: \(error.localizedDescription)\n")
    }

    /// Called when app receives remote notification (foreground or background)
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle silent push for geofence updates
        if application.applicationState != .active &&
           (userInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Update ||
            userInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Place_update ||
            userInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Campaign) {
            BoardActive.client.userDefaults?.set(true, forKey: String.ConfigKeys.silentPushReceived)
        }

        handleNotification(application: application, userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    /// Called when notification is presented while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo as! [String: Any]

        if userInfo["notificationId"] as? String == "0000001" {
            handleNotification(application: UIApplication.shared, userInfo: userInfo)
        }

        NotificationCenter.default.post(
            name: NSNotification.Name("Refresh HomeViewController Tableview"),
            object: nil,
            userInfo: userInfo
        )

        completionHandler(UNNotificationPresentationOptions(arrayLiteral: [.badge, .sound, .alert]))
    }

    /// Called when user taps notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo as! [String: Any]

        // Track events based on app state
        if isApplicationInBackground && !isNotificationStatusActive {
            isNotificationStatusActive = false
            isApplicationInBackground = false
            if let _ = userInfo["aps"],
               let _ = userInfo["baMessageId"] as? String,
               let _ = userInfo["gcm.message_id"] as? String,
               let _ = userInfo["baNotificationId"] as? String {
                if isReceviedEventUpdated {
                    self.notificationOpened(userInfo)
                } else {
                    self.updateAllNotificationStatus(userInfo)
                }
            }
        } else if isAppActive && !isNotificationStatusActive {
            if isReceviedEventUpdated {
                self.notificationOpened(userInfo)
            } else {
                self.updateAllNotificationStatus(userInfo)
            }
        } else {
            isNotificationStatusActive = true
            isApplicationInBackground = false
            NotificationCenter.default.post(name: Notification.Name("display"), object: nil)
        }

        // Handle download action
        if response.actionIdentifier == BoardActive.client.downloadActionIdentifier {
            let strUrl = (userInfo["imageUrl"] as? String ?? "").trimmingCharacters(in: .whitespaces)
            if let url = URL(string: strUrl) {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    UIImageWriteToSavedPhotosAlbum(UIImage(data: data)!, nil, nil, nil)
                }
                task.resume()
            } else {
                print(strUrl + " is invalid")
            }
        }

        completionHandler()
    }

    /// Handle notification and track events based on app state
    public func handleNotification(application: UIApplication, userInfo: [AnyHashable: Any]) {
        let tempUserInfo = userInfo as! [String: Any]

        // Handle app enable/disable
        if tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.App_status &&
           tempUserInfo[String.NotificationKeys.PlaceId] == nil {
            let app_status = tempUserInfo[String.NotificationKeys.Action] as? String
            if app_status == String.NotificationKeys.Disable {
                UserDefaults.standard.set(false, forKey: String.NotificationKeys.App_status)
            } else if app_status == String.NotificationKeys.Enable {
                UserDefaults.standard.set(true, forKey: String.NotificationKeys.App_status)
            }
        }
        // Handle geofence updates
        else if tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Place_update ||
                tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Update ||
                tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Campaign ||
                tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Delete {
            UserDefaults(suiteName: "BAKit")?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
            BoardActive.client.storeAppLocations()
        }

        isReceviedEventUpdated = true

        // Track events based on app state
        if let _ = tempUserInfo["aps"],
           let messageId = tempUserInfo["baMessageId"] as? String,
           let firebaseNotificationId = tempUserInfo["gcm.message_id"] as? String,
           let notificationId = tempUserInfo["baNotificationId"] as? String {
            switch application.applicationState {
            case .active:
                print("Received in foreground")
                BoardActive.client.postEvent(
                    name: String.Received,
                    messageId: messageId,
                    firebaseNotificationId: firebaseNotificationId,
                    notificationId: notificationId
                )
            case .background:
                print("Received in background")
                BoardActive.client.postEvent(
                    name: String.Received,
                    messageId: messageId,
                    firebaseNotificationId: firebaseNotificationId,
                    notificationId: notificationId
                )
            case .inactive:
                print("Tapped and transitioning")
                BoardActive.client.postEvent(
                    name: String.Opened,
                    messageId: messageId,
                    firebaseNotificationId: firebaseNotificationId,
                    notificationId: notificationId
                )
            default:
                break
            }
        }
    }
}

// MARK: - Location Manager Delegate

extension AppDelegate: CLLocationManagerDelegate {

    /// Called when user enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Entered region")
            BoardActive.client.stopMonitoring(region: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started monitoring \(manager.monitoredRegions.count) regions")
    }

    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Error in monitoring: \(error.localizedDescription)")
    }

    /// Called when location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("\n[BoardActive] didUpdateLocations :: Error: Last location of locations = nil.\n")
            return
        }

        BoardActive.client.currentLocation = location

        // Check for silent push trigger
        let flag: Bool = BoardActive.client.userDefaults?.value(forKey: String.ConfigKeys.silentPushReceived) as? Bool ?? false
        if flag {
            BoardActive.client.userDefaults?.set(false, forKey: String.ConfigKeys.silentPushReceived)
            UserDefaults(suiteName: "BAKit")?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
            BoardActive.client.storeAppLocations()
        }

        // Check distance traveled
        if UserDefaults.standard.value(forKey: String.ConfigKeys.traveledDistance) == nil {
            UserDefaults.standard.set([location.coordinate.latitude, location.coordinate.longitude],
                                      forKey: String.ConfigKeys.traveledDistance)
        } else {
            let previous = UserDefaults.standard.value(forKey: String.ConfigKeys.traveledDistance) as! NSArray
            let previousLocation = CLLocation(
                latitude: previous[0] as! CLLocationDegrees,
                longitude: previous[1] as! CLLocationDegrees
            )
            let distanceInMeters = previousLocation.distance(from: location)

            if distanceInMeters >= BoardActive.client.recordLocationAfterMeters {
                UserDefaults.standard.set([location.coordinate.latitude, location.coordinate.longitude],
                                          forKey: String.ConfigKeys.traveledDistance)
                UserDefaults(suiteName: "BAKit")?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
                BoardActive.client.storeAppLocations()
            }
        }
    }
}
```

---

### SceneDelegate Support (iOS 13+)

If your app uses SceneDelegate, add these methods to `SceneDelegate.swift`:

```swift
func sceneDidBecomeActive(_ scene: UIScene) {
    UIApplication.shared.applicationIconBadgeNumber = 0

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    appDelegate.isNotificationStatusActive = true

    if appDelegate.isApplicationInBackground {
        NotificationCenter.default.post(name: Notification.Name("Update user permission states"), object: nil)
    }
    appDelegate.isAppActive = true
}

func sceneDidEnterBackground(_ scene: UIScene) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    appDelegate.isApplicationInBackground = true
    appDelegate.isAppActive = false
}
```

---

### Notification Service Extension (Required)

**1. Add Notification Service Extension:**
- In Xcode: File → New → Target
- Select "Notification Service Extension"
- Name it `NotificationServiceExtension`

**2. Replace `NotificationService.swift` with:**

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
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension UNNotificationRequest {
    var attachment: UNNotificationAttachment? {
        guard let attachmentURL = content.userInfo["imageUrl"] as? String,
              let imageData = try? Data(contentsOf: URL(string: attachmentURL)!) else {
            return nil
        }
        return try? UNNotificationAttachment(data: imageData, options: nil)
    }
}

extension UNNotificationAttachment {
    convenience init(data: Data, options: [NSObject: AnyObject]?) throws {
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(temporaryFolderName, isDirectory: true)

        try fileManager.createDirectory(at: temporaryFolderURL,
                                        withIntermediateDirectories: true,
                                        attributes: nil)

        let imageFileIdentifier = UUID().uuidString + ".jpg"
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
        try data.write(to: fileURL)
        try self.init(identifier: imageFileIdentifier, url: fileURL, options: options)
    }
}
```

**3. Configure Bundle ID:** `{your-main-bundle-id}.NotificationServiceExtension`

**4. Create provisioning profile** for the extension with this bundle ID format.

---

## Usage

### Starting the SDK

Call `setupSDK()` after user authentication:

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

1. Log in to [BoardActive Dashboard](https://app.boardactive.com)
2. Navigate to **Places** → **Create New Place**
3. Set location, radius, and notification message
4. Save and activate

The SDK automatically downloads and monitors geofences.

---

## Example App

Check out the [example app](https://github.com/BoardActive/BAKit-ios/tree/master/Example) in this repository:

```bash
cd Example
pod install
open BAKit-iOS.xcworkspace
```

---

## Troubleshooting

### Location not working in background?
- ✅ Enable "Location updates" in Background Modes
- ✅ Request "Always" location permission
- ✅ Verify user granted "Always Allow" in Settings

### Notifications not appearing?
- ✅ Verify Firebase Cloud Messaging configured
- ✅ Check APNS certificate uploaded to Firebase
- ✅ Ensure notification permissions granted
- ✅ Verify `GoogleService-Info.plist` in project

### Geofences not monitoring?
- ✅ Call `setupSDK()` after user authentication
- ✅ Check dashboard has active geofences nearby
- ✅ iOS limits to 20 monitored geofences per app

### Duplicate events in analytics?
- ✅ Verify flag management in AppDelegate
- ✅ Check `isReceviedEventUpdated` flag is set correctly
- ✅ Ensure `handleNotification()` is called properly

---

## API Reference

### Main SDK Methods

```swift
// Register device
BoardActive.client.registerDevice { (response, error) in }

// Monitor location
BoardActive.client.monitorLocation()

// Download geofences
BoardActive.client.storeAppLocations()

// Update user attributes
BoardActive.client.updateUserData(body: attributes) { (response, error) in }

// Track events
BoardActive.client.postEvent(name: eventName,
                             messageId: id,
                             firebaseNotificationId: fbId,
                             notificationId: notifId)

// Update permission states
BoardActive.client.updatePermissionStates()

// Stop monitoring region
BoardActive.client.stopMonitoring(region: region)
```

---

## Support

**Need Help?**

- 📧 Email: [support@boardactive.com](mailto:support@boardactive.com)
- 🌐 Website: [boardactive.com](https://www.boardactive.com)
- 📖 Dashboard: [app.boardactive.com](https://app.boardactive.com)
- 🐛 Issues: [GitHub Issues](https://github.com/BoardActive/BAKit-ios/issues)

**Get Your Credentials:**
- Email [taylor@boardactive.com](mailto:taylor@boardactive.com) with your Firebase Server Key

---

## License

BAKit-iOS is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

**Made with ❤️ by BoardActive**
