#
# Be sure to run `pod lib lint BAKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BAKit'
  s.version          = '0.1.0'
  s.summary          = 'Location-based notifications for personalized user engagement and retention campaigns.'
  s.description      = 'Board Active iOS SDK, for integrating BoardActive into your iOS application. The SDK supports iOS 10.0]+'
  s.homepage         = 'https://github.com/boardactive/BAKit-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  # s.author           = { 'Hunter Brennick' => 'hunter@boardactive.com' }
  s.author           = { 'BoardActive' => 'dev@boardactive.com' }
  s.source           = { :git => 'https://github.com/BoardActive/BAKit-ios.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '10.0'
  s.swift_version         = '4.0'
  s.requires_arc = true
  
  s.module_name = 'BAKit'

  s.source_files = 'BAKit/Source/**/*.{swift,h,m}'
  
  # s.resource_bundles = { 'BAKitAssets' => 'BAKit/Assets/*.png' }
  # s.resource_bundles = { 'BAKit' => ['BAKit/Source/Storyboards/*.storyboard', 'Resources/**/*/Assets.xcassets'] }
  # s.resource_bundles = { 'BAKit_FirebaseBundle' => ['BAKit/Source/BAKit_FirebaseBundle/*.{plist}'] }
  s.resources = 'BAKit/**/*.{png,json}'
  # s.resource_bundles = { 'Resources/**/*/Assets.xcassets' }

#  s.dependency 'Alamofire', '~> 4.7'
#  s.dependency 'PromiseKit/Alamofire', '~> 6.0'
  s.dependency 'Firebase/Core', '~> 5.0'
  s.dependency 'Firebase/Messaging'
#  s.dependency 'Alamofire-SwiftyJSON'
#  s.dependency 'SwiftyJSON', '~> 4.0'
  # NOTE: adding ~> 3.1.1 or any 3.x.x of Firebase/Messaging caused the app to fail
  
  s.static_framework = true
end
