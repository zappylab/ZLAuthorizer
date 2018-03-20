workspace 'ZLAuthorizer'
project 'AuthorizerExample/AuthorizerExample.xcodeproj'
platform :ios, '7.0'

install! 'cocoapods', :deterministic_uuids => false

pod 'Lockbox'
pod 'ZLNetworkRequestsPerformer', :git => 'https://github.com/zappylab/ZLNetworkRequestsPerformer.git', :branch => 'master'
pod 'AFNetworking', '~> 3.0'
pod 'NSString+Validation'
pod 'BlocksKit', '~> 2.2.0'
pod 'GoogleSignIn'
pod 'FBSDKLoginKit'

target :AuthorizerTests do
	pod 'Specta'
	pod 'Expecta'
	pod 'OHHTTPStubs'
end
