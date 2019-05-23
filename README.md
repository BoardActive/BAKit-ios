<img src="https://avatars0.githubusercontent.com/u/38864287?s=200&v=4" width="96" height="96"/>

### Retain and engage mobile users

Connect with customers using BoardActive's proprietary location-based marketing technology.

## Installation

BoardActive for iOS supports iOS 10+. 

Building with Xcode 9 is required, which adds support for iPhone X and iOS 11.

## SDK

Currently, the SDK is available via CocoaPods or via downloading the repository and manually linking the SDK's source code to your project.

### CocoaPods

Add the BoardActive pod into your Podfile and run `pod install`.
```ruby
    platform :ios, '10.0'

    target :YourTargetName do
      pod 'BoardActive'
    end
```

### Update Info.plist

When installing BoardActive, you'll need to make sure that you have the following entries in your `Info.plist`: `Privacy - Location Always and When In Use Usage Description`, `Privacy - Location Always Usage Description`, and `Privacy - Location When In Use Usage Description`. 

Additionally, you'll have to add three items to `Required background modes`: `App downloads content in response to push notifications`, `App downloads content from the network`, and `App registers for location updates`. The same can be accomplished by selecting the project's primary target, selecting the `Capabilities` settings, and, under `Background Modes`, ensuring `Location updates`, `Background fetch`, and `Remote notifications` are all checked. 

## How to use this SDK

### Permissions

`CoreLocation` and `UserNotifications` permissions need be requested before the hosting app's `AppDelegate`'s `application(_:willFinishLaunchingWithOptions:)`.

### Instantiate BAKit

```swift
    // 1
    import BAKit

    @UIApplicationMain 
    class AppDelegate: UIResponder, UIApplicationDelegate {
        var window: UIWindow?
    
        func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
            // 2
            BoardActive.client.setupEnvironment(appID: "", appKey: "")
        
            // 3
            BoardActive.client.requestNotifications()

            return true
        }
    }
```
1) Import the SDK.
2) Set SDK's `appID` and `appKey` and configure the associated Firebase project.
3) Declare `BoardActive` as the `UNUserNotificationCenterDelegate` and `MessagingDelegate`. Requests user push notification authorization via the `UNUserNotificationCenter` and registers for remote notifications. Additionally, trigger the calling of `BoardActive.client.requestLocations()` thereby requesting appropriate `CoreLocation` permissions and starting location updates.

## Example app

There is an example app provided [here](https://github.com/BoardActive/BAKit-ios/tree/master/Example) for Swift.

## Setup and Configuration

* [TODO] Our [installation guide](https://developers.boardactive.com) contains full setup and initialisation instructions.
* [TODO] Read ["Configuring BoardActive for iOS"](https://developers.boardactive.com).
* [TODO] Read our guide on [Push Notifications](https://developers.boardactive.com).
* Please contact us at [BoardActive](https://boardactive.com) with any questions you may have, we're only a click away!

## Customer Support

👋 [TODO] Contact us with any issues at our [BoardActive Developer Hub available here](https://developers.boardactive.com). If you bump into any problems or need more support, just start a conversation using Intercom there and it will be immediately routed to our Customer Support Engineers.

## Cordova/Phonegap Support
[TODO] Looking for Cordova/Phonegap support? We have a [Cordova Plugin](https://github.com/BoardActive/BAKit-cordova) for BoardActive 🎉

## What about X, Y, or Z?

BoardActive for iOS has support for all these things. For full details please read our [documentation](https://developers.boardactive.com).
