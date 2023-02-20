![Cocoapods platforms](https://img.shields.io/cocoapods/p/BAKit)
![GitHub top language](https://img.shields.io/github/languages/top/boardactive/BAKit-ios?color=orange)
![Cocoapods](https://img.shields.io/cocoapods/v/BAKit-iOS?color=red)
![GitHub commits since tagged version (branch)](https://img.shields.io/github/commits-since/boardactive/BAKit-ios/1.0.2)
![GitHub issues](https://img.shields.io/github/issues-raw/boardactive/BAKit-iOS)

# BAKit-iOS

<img src="https://avatars0.githubusercontent.com/u/38864287?s=200&v=4" width="96" height="96"/>

### Location-Based Engagement

##### Enhance your app. Empower your marketing.

##### It's not about Advertising... It's about *"PERSONALIZING"*

BoardActive's platform connects brands to consumers using location-based engagement. Our international patent-pending Visualmatic™ software is a powerful marketing tool allowing brands to set up a virtual perimeter around any location, measure foot-traffic, and engage users with personalized messages when they enter geolocations… AND effectively attribute campaign efficiency by seeing where users go after the impression!

Use your BoardActive account to create Places (geo-fenced areas) and Messages (notifications) to deliver custom messages to your app users.

[Click Here to get a BoardActive Account](https://app.boardactive.com/signup)

Once a client has established at least one geofence, the BAKit SDK leverages any smart device's native location monitoring, determines when a user enters said geofence and dispatches a  *personalized* notification of the client's composition.
___
### Required For Setup
1. A Firebase project to which you've added your app.
2. A BoardActive account

### Create a Firebase Project
#### Add Firebase Core and Firebase Messaging to your app
To use Firebase Cloud Messaging you must create a Firebase project.

* [Firebase iOS Quickstart](https://firebase.google.com/docs/ios/setup) - A guide to creating and understanding Firebase projects.
* [Set up a Firebase Cloud Messaging client app on iOS](https://firebase.google.com/docs/cloud-messaging/ios/client) - How to handle Firebase Cloud Messaging (the means by which BoardActive sends push notifications).
    * Please refer to the following two articles regarding APNS, as Firebase's documentation is a bit dated. We'll also cover how to add push notifications to your account whilst installing the SDK:
        * [Enable Push Notifications](https://help.apple.com/xcode/mac/current/#/devdfd3d04a1)
        * [Registering Your App with APNs](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns)
* [Click Here to go to the Firebase Console](https://console.firebase.google.com/u/0/)

Once you create a related Firebase project you can download the ```GoogleService-Info.plist``` and hang on to that file for use in the "CocoaPods" section.

### Receiving your BoardActive AppKey
* Please email the Firebase key found in the Firebase project settings “Service Accounts” -> “Firebase Admin SDK” under “Firebase service account” to [taylor@boardactive.com](taylor@boardactive.com) and he will respond with your BoardActive AppKey.

### Installing the BAKit SDK
* BoardActive for iOS utilizes Swift 4.0 and supports iOS 10+.
* Build with Xcode 9+ is required, adding support for iPhone X and iOS 11.
* Currently, the SDK is available via CocoaPods or via downloading the repository and manually linking the SDK's source code to your project.

#### CocoaPods
1. [Setup CocoaPods](http://guides.cocoapods.org/using/getting-started.html)
2. Close/quit Xcode.
3. Run ```$ pod init``` via the terminal in your project directory.
4. Open your newly created `Podfile` and add the following pods (see the example Podfile at the end of this section).
    * ```pod 'BAKit-iOS'```
    * ```pod 'Firebase/Core', '~> 5.0'```
    * ```pod 'Firebase/Messaging'```
5. Run ```$ pod repo update``` from the terminal in your main project directory.
6. Run ```$ pod install```  from the terminal in your main project directory, and once CocoaPods has created workspace, open the <App Name>.workspace file.
7. Incorporate your ```GoogleService-Info.plist```, previously mentioned in the **Create a Firebase Project** section, by dragging said file into your project.

**Example Podfile**

```ruby
    platform :ios, '10.0'

    use_frameworks!

    target :YourTargetName do  
        pod 'BAKit-iOS'
        pod 'Firebase/Core', '~> 5.0'
        pod 'Firebase/Messaging'
    end
```

---

#### Update Info.plist - Location Permission
Requesting location permission requires the follow entries in your ```Info.plist``` file. Each entry requires an accompanying key in the form of a ```String``` explaining how user geolocation data will be used.

- `NSLocationAndWhenInUseUsageDescription`
  - `Privacy - Location Always and When In Use Usage Description`
- `NSLocationWhenInUseUsageDescription`
  - `Privacy - When In Use Usage Description`
- `NSLocationAlwaysUsageDescription`
  - `Privacy - Location Always Usage Description`

#### Update Info.plist - Gallery Permission

- `NSPhotoLibraryAddUsageDescription`
   - `Privacy - Photo Library Usage Description`  
   
---

#### Update App Capabilities

Under your app's primary target you will need to edit it's **Capabilities** as follows:  
1. Enable **Background Modes**. Apple provides documentation explain the various **Background Modes** [here](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/uid/TP40009252-SW22) 
2. Tick the checkbox *Location updates*  
3. Tick the checkbox *Remote notifications* 
4. Tick the checkbox *Background fetch*  
5. Tick the checkbox *Background processing*  
6. Enable **Push Notifications**  
7. Add **App Groups**

---

### Using BAKit
#### AppDelegate
Having followed the Apple's instructions linked in the **Add Firebase Core and Firebase Messaging to Your App** section, please add the following code to the top of your ```AppDelegate.swift```:

```swift
import BAKit
import Firebase
import UserNotifications
import Messages
import CoreLocation
```

Prior to the declaration of the ```AppDelegate``` class, a protocol is declared. Those classes conforming to said protocol receive the notification in the example app:

```swift
protocol NotificationDelegate: NSObject {
    func appReceivedRemoteNotification(notification: [AnyHashable: Any])
    func appReceivedRemoteNotificationInForeground(notification: [AnyHashable: Any])
}
```

Flags use to manage notification behaviour in various states
```swift
    var isNotificationStatusActive = false
    var isApplicationInBackground = false
    var isAppActive = false
    var isReceviedEventUpdated = false
```
Just inside the declaration of the ```AppDelegate``` class, the following variables and constants are declared:

```swift
    var locationManager: CLLocationManager?
    public weak var notificationDelegate: NotificationDelegate?

    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
    
```

Now store your BoardActive AppId and AppKey to ```BoardActive.client.userDefaults``` like so:

```swift
func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
    
    // AppId is of type Int        
    BoardActive.client.userDefaults?.set(<#AppId#>, forKey: "AppId")

    // AppKey is of type String
    BoardActive.client.userDefaults?.set(<#AppKey#>, forKey: "AppKey")

    return true
}

```
Add the following to monitor for significant location updates whilst the app is terminated.

**Note: It is mandatory to give always allow permission to achieve the full functionality in killed state. 
And the option under edit scheme *"wait for the executable to be launched"* must be ticked.**

```swift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            isNotificationStatusActive = true
            //You have a location when app is in killed/ not running state
                locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager?.distanceFilter = kCLDistanceFilterNone
                locationManager?.pausesLocationUpdatesAutomatically = false
                locationManager?.allowsBackgroundLocationUpdates = true
                locationManager?.startMonitoringSignificantLocationChanges()
                locationManager?.activityType = .otherNavigation
                locationManager?.startUpdatingLocation()
        }
        NotificationCenter.default.addObserver(BoardActive.client, selector: #selector(BoardActive.client.updatePermissionStates), name: Notification.Name("Update user permission states"), object: nil)
        return true
}

```
  Manage the flag values when application enters in background (If using scenedelegate)
```swift

func sceneDidBecomeActive(_ scene: UIScene) {
     // Called when the scene has moved from an inactive state to an active state.
     // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
     UIApplication.shared.applicationIconBadgeNumber = 0
     isNotificationStatusActive = true
     if (isApplicationInBackground) {
         NotificationCenter.default.post(name: Notification.Name("Update user permission states"), object: nil)
     }
     isAppActive = true
}
    
func sceneDidEnterBackground(_ scene: UIScene) {
      // Called as the scene transitions from the foreground to the background.
      // Use this method to save data, release shared resources, and store enough scene-specific state information
      // to restore the scene back to its current state.
      isApplicationInBackground = true
      isAppActive = false
}

```
  Manage the flag values when application enters in background (If using appdelegate methods)
```swift

func applicationDidEnterBackground(_ application: UIApplication) {
    isApplicationInBackground = true
    isAppActive = false
}
    
func applicationDidBecomeActive(_ application: UIApplication) {
     application.applicationIconBadgeNumber = 0

     if (isApplicationInBackground) {
          NotificationCenter.default.post(name: Notification.Name("Update user permission states"), object: nil)
     }
     isAppActive = true
}

```
Add the following below the closing brace of your `AppDelegate` class.

```swift
extension AppDelegate {
/**
Call this function after having received your FCM and APNS tokens.
Additionally, you must have set your AppId and AppKey using the
BoardActive class's userDefaults.
*/
   func setupSDK() {
        let operationQueue = OperationQueue()
        let registerDeviceOperation = BlockOperation.init {
            BoardActive.client.registerDevice { (parsedJSON, err) in
                guard err == nil, let parsedJSON = parsedJSON else {
                    fatalError()
                }
                
                BoardActive.client.userDefaults?.set(true, forKey: String.ConfigKeys.DeviceRegistered)
                BoardActive.client.userDefaults?.synchronize()
            }
        }
       
        let requestNotificationsOperation = BlockOperation.init {
            self.requestNotifications()
        }
        
        let monitorLocationOperation = BlockOperation.init {
            DispatchQueue.main.async {
                BoardActive.client.monitorLocation()
            }
        }
        
        let saveGeofenceLocationOperation = BlockOperation.init {
            BoardActive.client.storeAppLocations()
        }

        monitorLocationOperation.addDependency(requestNotificationsOperation)
        requestNotificationsOperation.addDependency(registerDeviceOperation)
        monitorLocationOperation.addDependency(saveGeofenceLocationOperation)
        
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
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

```
In an extension adhering to Firebase's ```MessagingDelegate``` that receive's the FCM Token, store said token in BAKit's ```userDefaults```.

```swift
// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    /**
     This function will be called once a token is available, or has been refreshed. Typically it will be called once per app start, but may be called more often, if a token is invalidated or updated. In this method, you should perform operations such as:

     * Uploading the FCM token to your application server, so targeted notifications can be sent.
     * Subscribing to any topics.
     */
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        BoardActive.client.userDefaults?.set(fcmToken, forKey: "deviceToken")
        BoardActive.client.userDefaults?.synchronize()
    }
}
```
Both as a means by which you can double check you've implemented the necessary ```UNUserNotificationCenterDelegate``` functions, the next snippet is provided.

```swift
// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        print("\n[AppDelegate] didRegisterForRemoteNotificationsWithDeviceToken :: APNs TOKEN: %s \n", deviceTokenString)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    // Handle APNS token registration error
        print("\n[AppDelegate] didFailToRegisterForRemoteNotificationsWithError :: APNs TOKEN FAIL :: %s \n", error.localizedDescription)
    }

    /**
     Called when app in foreground or background as opposed to `application(_:didReceiveRemoteNotification:)` which is only called in the foreground.
     (Source: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application)
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState != .active && (userInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Update || userInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Place_update || userInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Campaign) {
            BoardActive.client.userDefaults?.set(true, forKey: String.ConfigKeys.silentPushReceived)
        }
        handleNotification(application: application, userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

         let userInfo = notification.request.content.userInfo as! [String: Any]
        
        if userInfo["notificationId"] as? String == "0000001" {
            handleNotification(application: UIApplication.shared, userInfo: userInfo)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("Refresh HomeViewController Tableview"), object: nil, userInfo: userInfo)
        completionHandler(UNNotificationPresentationOptions.init(arrayLiteral: [.badge, .sound, .alert]))
    }

    /**
        This delegate method will call when user opens the notification from the notification center.
    */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo as! [String: Any]
        
        if isApplicationInBackground && !isNotificationStatusActive {
            isNotificationStatusActive = false
            isApplicationInBackground = false
            if let _ = userInfo["aps"], let _ = userInfo["baMessageId"] as? String, let _ = userInfo["gcm.message_id"] as? String, let _ = userInfo["baNotificationId"] as? String {
                if (isReceviedEventUpdated) {
                    self.notificationDelegate?.appReceivedRemoteNotificationInForeground(notification: userInfo)
                } else {
                    self.notificationDelegate?.appReceivedRemoteNotification(notification: userInfo)
                }
            }
            
        } else if isAppActive && !isNotificationStatusActive {
            if (isReceviedEventUpdated) {
                self.notificationDelegate?.appReceivedRemoteNotificationInForeground(notification: userInfo)
            } else {
                self.notificationDelegate?.appReceivedRemoteNotification(notification: userInfo)
            }
            
        } else {
            isNotificationStatusActive = true
            isApplicationInBackground = false
            NotificationCenter.default.post(name: Notification.Name("display"), object: nil)
        }
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
    /**
     Use `userInfo` for validating said instance, and calls `createEvent`, capturing the current application state.

     - Parameter userInfo: A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an `NSDictionary` object; the dictionary may contain only property-list objects plus `NSNull`. For more information about the contents of the remote notification dictionary, see Generating a Remote Notification.
     */
    public func handleNotification(application: UIApplication, userInfo: [AnyHashable: Any]) {
        let tempUserInfo = userInfo as! [String: Any]
        
        if tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.App_status && tempUserInfo[String.NotificationKeys.PlaceId] == nil {
            let app_status = tempUserInfo[String.NotificationKeys.Action] as? String
            if app_status == String.NotificationKeys.Disable {
                UserDefaults.standard.set(false, forKey: String.NotificationKeys.App_status)
            } else if app_status == String.NotificationKeys.Enable {
                UserDefaults.standard.set(true, forKey: String.NotificationKeys.App_status)
            }
        } else if tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Place_update || tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Update || tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Campaign || tempUserInfo[String.NotificationKeys.Typee] as? String == String.NotificationKeys.Delete {
            UserDefaults(suiteName: "BAKit")?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
            BoardActive.client.storeAppLocations()
        }
        isReceviedEventUpdated = true
        
        if let _ = tempUserInfo["aps"], let messageId = tempUserInfo["baMessageId"] as? String, let firebaseNotificationId = tempUserInfo["gcm.message_id"] as? String, let notificationId = tempUserInfo["baNotificationId"] as? String {
            switch application.applicationState {
            case .active:
                print("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId)
                break
            case .background:
                print("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId)
                break
            case .inactive:
                print("%s", String.TappedAndTransitioning)
                BoardActive.client.postEvent(name: String.Opened, messageId: messageId, firebaseNotificationId: firebaseNotificationId, notificationId: notificationId)
                break
            default:
                break
            }
        }
    }
    
    //Configure category
    private func configureCategory() {
        // Define Actions
        let downloadButton = UNNotificationAction(identifier: BoardActive.client.downloadActionIdentifier, title: "Download", options: UNNotificationActionOptions.foreground)
        // Define Category
        let downloadCategory = UNNotificationCategory(identifier: BoardActive.client.categoryIdentifier, actions: [downloadButton], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        // Register Category
        UNUserNotificationCenter.current().setNotificationCategories([downloadCategory])
    }
}

```
Conform CLLocationManagerDelegate.
```swift

extension AppDelegate: CLLocationManagerDelegate {

    // calls when user Enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
          print("entered in region")
          BoardActive.client.stopMonitoring(region: region)
      }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started monitoring \(manager.monitoredRegions.count) regions")
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Error in monitoring: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("\n[BoardActive] didUpdateLocations :: Error: Last location of locations = nil.\n")
            return
        }
        BoardActive.client.currentLocation = location
        
        let flag: Bool = BoardActive.client.userDefaults?.value(forKey: String.ConfigKeys.silentPushReceived) as? Bool ?? false
        if flag {
            BoardActive.client.userDefaults?.set(false, forKey: String.ConfigKeys.silentPushReceived)
            UserDefaults(suiteName: "BAKit")?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
            BoardActive.client.storeAppLocations()
        }
        
        if UserDefaults.standard.value(forKey: String.ConfigKeys.traveledDistance) == nil {
            UserDefaults.standard.set([location.coordinate.latitude, location.coordinate.longitude], forKey: String.ConfigKeys.traveledDistance)
        } else {
            let previous = UserDefaults.standard.value(forKey: String.ConfigKeys.traveledDistance) as! NSArray
            let previousLocation = CLLocation(latitude: previous[0] as! CLLocationDegrees, longitude: previous[1] as! CLLocationDegrees)
            let distanceInMeters = previousLocation.distance(from: location)
            if distanceInMeters >= BoardActive.client.recordLocationAfterMeters {
                UserDefaults.standard.set([location.coordinate.latitude, location.coordinate.longitude], forKey: String.ConfigKeys.traveledDistance)
                UserDefaults(suiteName: "BAKit")?.set(nil, forKey: String.ConfigKeys.geoFenceLocations)
                BoardActive.client.storeAppLocations()
            }
        }
    }
}

```

Now add a notification service app extension to your project:
Select File > New > Target in Xcode.
Select the Notification Service Extension target from the iOS > Application section.
Click Next.
Specify a name and other configuration details for your app extension.
Click Finish.

And add the same deployment target which you have kept for the project.

It is required to create provisioning profile for the app extention with this kind of bundle id "{main app bundle}.NotificationServiceExtension"

```swift
import UserNotifications

final class NotificationService: UNNotificationServiceExtension {

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
 
        defer {
            contentHandler(bestAttemptContent ?? request.content)
        }
        guard let attachment = request.attachment else { return }
        bestAttemptContent?.attachments = [attachment]
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension UNNotificationRequest {
    var attachment: UNNotificationAttachment? {
        guard let attachmentURL = content.userInfo["imageUrl"] as? String, let imageData = try? Data(contentsOf: URL(string: attachmentURL)!) else {
            return nil
        }
        return try? UNNotificationAttachment(data: imageData, options: nil)
    }
}

extension UNNotificationAttachment {
    convenience init(data: Data, options: [NSObject: AnyObject]?) throws {
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)
        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
        let imageFileIdentifier = UUID().uuidString + ".jpg"
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
        try data.write(to: fileURL)
        try self.init(identifier: imageFileIdentifier, url: fileURL, options: options)
    }
}
```

Add the below method in the controller from which you want to start location and notification services.

If Swift:
```swift
(UIApplication.shared.delegate! as! AppDelegate).setupSDK()
```

If SwiftUI:
```swift
@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

.onAppear() {
     appDelegate.setupSDK()
 }
```

## Download Example App Source Code
There is an example app included in the repo's code under ["Example"](https://github.com/BoardActive/BAKit-ios/tree/master/Example).

## Ask for Help

Our team wants to help. Please contact us
* Call us: [(678) 383-2200](tel:+6494461709)
* Email Us [support@boardactive.com](mailto:support@boardactive.com)
* Online Support [Web Site](https://www.boardactive.com/) 

