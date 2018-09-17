<img src="https://avatars0.githubusercontent.com/u/38864287?s=200&v=4" width="96" height="96"/>

### Retain and engage mobile users
Connect with customers using BoardActive's proprietary location-based marketing technology.

## Installation

BoardActive for iOS supports iOS 10 and iOS 11. 

Building with Xcode 9 is required, which adds support for iPhone X and iOS 11.

### CocoaPods
Add the BoardActive pod into your Podfile and run `pod install`.
```ruby
    target :YourTargetName do
      pod 'BoardActive'
    end
```

## Update Info.plist

When installing BoardActive, you'll need to make sure that you have the following entries in your `Info.plist`: `Privacy - Location Always and When In Use Usage Description`, `Privacy - Location Always Usage Description`, and `Privacy - Location When In Use Usage Description`. Additionally, you'll have to add three items to `Required background modes`: `App downloads content in response to push notifications`, `App downloads content from the network`, and `App registers for location updates`.

This is required by Apple for all apps that send notifications and track location in the background. It is necessary when installing BoardActive due to the location-based notification functionality. Users will be prompted for location permissions ONLY when BoardActive's `boot` function is executed.


## Example app
There is an example app provided [here](https://github.com/BoardActive/BAKit-ios/tree/master/Example) for Swift.

## Setup and Configuration

* [TODO] Our [installation guide](https://developers.boardactive.com) contains full setup and initialisation instructions.
* [TODO] Read ["Configuring BoardActive for iOS"](https://developers.boardactive.com).
* [TODO] Read our guide on [Push Notifications](https://developers.boardactive.com).
* Please contact us on [BoardActive](https://boardactive.com) with any questions you may have, we're only a click away!

## Customer Support

👋 [TODO] Contact us with any issues at our [BoardActive Developer Hub available here](https://developers.boardactive.com). If you bump into any problems or need more support, just start a conversation using Intercom there and it will be immediately routed to our Customer Support Engineers.

## Cordova/Phonegap Support
[TODO] Looking for Cordova/Phonegap support? We have a [Cordova Plugin](https://github.com/BoardActive/BAKit-cordova) for BoardActive 🎉

## What about X, Y, or Z?

BoardActive for iOS has support for all these things. For full details please read our [documentation](https://developers.boardactive.com).
