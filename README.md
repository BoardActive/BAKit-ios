![Cocoapods platforms](https://img.shields.io/cocoapods/p/BAKit)
![GitHub top language](https://img.shields.io/github/languages/top/boardactive/BAKit-ios?color=orange)
![Cocoapods](https://img.shields.io/cocoapods/v/BAKit?color=red)
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
    * ```pod 'BAKit'```
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
        pod 'BAKit'
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

---

#### Update App Capabilities

Under your app's primary target you will need to edit it's **Capabilities** as follows:  
1. Enable **Background Modes**. Apple provides documentation explain the various **Background Modes** [here](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html#//apple_ref/doc/uid/TP40009252-SW22) 
2. Tick the checkbox *Location updates*  
3. Tick the checkbox *Background fetch*  
4. Tick the checkbox *Remote notifications*  
5. Enable **Push Notifications**  

---

### Using BAKit
#### AppDelegate
Having followed the Apple's instructions linked in the **Add Firebase Core and Firebase Messaging to Your App** section, please add the following code to the top of your ```AppDelegate.swift```:

```swift 
import BAKit
import Firebase
import UIKit
import UserNotifications
import Messages
```

Prior to the declaration of the ```AppDelegate``` class, a protocol is declared. Those classes conforming to said protocol receive the notification in the example app:

```swift
protocol NotificationDelegate: NSObject {
    func appReceivedRemoteNotification(notification: [AnyHashable: Any])
}
```

Just inside the declaration of the ```AppDelegate``` class, the following variables and constants are declared:

```swift
    public weak var notificationDelegate: NotificationDelegate?

    private let authOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
```

After configuring Firebase and declaring ```AppDelegate```'s conformance to Firebase's ```MessagingDelegate```, store your BoardActive AppId and AppKey to ```BoardActive.client.userDefaults``` like so:

```swift
func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
    application.applicationIconBadgeNumber = UserDefaults.extensions.badge

    // AppId is of type Int        
    BoardActive.client.userDefaults?.set(<#AppId#>, forKey: "AppId")

    // AppKey is of type String
    BoardActive.client.userDefaults?.set(<#AppKey#>, forKey: "AppKey")
        
    return true
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
        
        monitorLocationOperation.addDependency(requestNotificationsOperation)
        requestNotificationsOperation.addDependency(registerDeviceOperation)
        
        operationQueue.addOperation(registerDeviceOperation)
        operationQueue.addOperation(requestNotificationsOperation)
        operationQueue.addOperation(monitorLocationOperation)
    }

    public func requestNotifications() {        
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in        
    if BoardActive.client.userDefaults?.object(forKey: "dateNotificationRequested") == nil {
                BoardActive.client.userDefaults?.set(Date().iso8601, forKey: "dateNotificationRequested")
                BoardActive.client.userDefaults?.synchronize()
            }
            guard error == nil, granted else {
            // Handle error and possibility of user not granting permission
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
        os_log("\n[AppDelegate] didRegisterForRemoteNotificationsWithDeviceToken :: APNs TOKEN: %s \n", deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    // Handle APNS token registration error
        os_log("\n[AppDelegate] didFailToRegisterForRemoteNotificationsWithError :: APNs TOKEN FAIL :: %s \n", error.localizedDescription)
    }

    /**
     Called when app in foreground or background as opposed to `application(_:didReceiveRemoteNotification:)` which is only called in the foreground.
     (Source: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application)
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
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
        
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        guard (response.actionIdentifier == UNNotificationDefaultActionIdentifier) || (response.actionIdentifier == UNNotificationDismissActionIdentifier) else {
            return
        }
        
        let userInfo = response.notification.request.content.userInfo as! [String: Any]
        
        self.notificationDelegate?.appReceivedRemoteNotification(notification: userInfo)
        
        completionHandler()
    }
    
    /**
     Creates an instance of `NotificationModel` from `userInfo`, validates said instance, and calls `createEvent`, capturing the current application state.
     
     - Parameter userInfo: A dictionary that contains information related to the remote notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a notification identifier, and custom data. The provider originates it as a JSON-defined dictionary that iOS converts to an `NSDictionary` object; the dictionary may contain only property-list objects plus `NSNull`. For more information about the contents of the remote notification dictionary, see Generating a Remote Notification.
     */
    public func handleNotification(application: UIApplication, userInfo: [AnyHashable: Any]) {
        let tempUserInfo = userInfo as! [String: Any]
        
        if let _ = tempUserInfo["aps"], let messageId = tempUserInfo["messageId"] as? String, let firebaseNotificationId = tempUserInfo["gcmmessageId"] as? String {
            switch application.applicationState {
            case .active:
                os_log("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId)
                break
            case .background:
                os_log("%s", String.ReceivedBackground)
                BoardActive.client.postEvent(name: String.Received, messageId: messageId, firebaseNotificationId: firebaseNotificationId)
                break
            case .inactive:
                os_log("%s", String.TappedAndTransitioning)
                BoardActive.client.postEvent(name: String.Opened, messageId: messageId, firebaseNotificationId: firebaseNotificationId)
                break
            default:
                break
            }
        }
    }
}
```
Add the following to monitor for significant location updates whilst the app is terminated.
```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        BoardActive.client.locationManager.stopMonitoringSignificantLocationChanges()

    }

    func applicationWillTerminate(_ application: UIApplication) {        
        BoardActive.client.locationManager.startMonitoringSignificantLocationChanges()
    }
```

## Download Example App Source Code
There is an example app included in the repo's code under ["Example"](https://github.com/BoardActive/BAKit-ios/tree/master/Example).

## Ask for Help

Our team wants to help. Please contact us 
* Call us: [(678) 383-2200](tel:+6494461709)
* Email Us [support@boardactive.com](mailto:info@boardactive.com)
* Online Support [Web Site](https://www.boardactive.com/)

