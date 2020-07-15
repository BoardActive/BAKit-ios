#
# Be sure to run `pod lib lint BAKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BAKit-iOS'
  s.version          = '2.0.6'
  s.summary          = 'Location-based notifications for personalized user engagement and retention campaigns.'
  s.description      = 'Board Active iOS SDK, for integrating BoardActive into your iOS application. The SDK supports iOS 10.0]+'
  s.homepage         = 'https://boardactive.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Hunter Brennick' => 'hunter@boardactive.com' }
  s.author           = { 'BoardActive' => 'dev@boardactive.com' }
  s.source           = { :git => 'https://github.com/BoardActive/BAKit-ios.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '10.0'

  s.swift_version         = '4.0'

  s.requires_arc = true
  
  s.module_name = 'BAKit'

  s.source_files = 'BAKit/Source/**/*.{swift,h,m}'
  
  s.static_framework = true
end
