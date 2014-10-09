Pod::Spec.new do |spec|
  spec.platform = :ios, "7.0"
  spec.name = 'ZLAuthorizer'
  spec.version = '0.3'
  spec.homepage = 'https://github.com/zappylab/ZLAuthorizer'
  spec.authors = { 'Ilya Dyakonov' => 'ilya@zappylab.com' }
  spec.summary = 'Authorization module used by ZappyLab'
  spec.source = { :git => 'https://github.com/zappylab/ZLAuthorizer.git', :branch => "dev" }
  spec.source_files = 'Authorizer/**/*.{h,m}'
  spec.dependency 'Lockbox'
  spec.dependency 'NSString+Validation'
  spec.dependency 'AFNetworking', '~> 2.0'
  spec.dependency 'BlocksKit', '~> 2.2.0'
  spec.preserve_paths = "Authorizer/Frameworks/*.framework"
  spec.frameworks = 'Accounts', 'Social', 'AddressBook', 'Security', 'SystemConfiguration', 'MediaPlayer', 'CoreMotion', 'AssetsLibrary', 'FacebookSDK', 'GoogleOpenSource', 'GooglePlus'
  spec.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(SRCROOT)/../ZLAuthorizer/Authorizer/Frameworks"' }
  spec.requires_arc = true

  non_arc_files = 'Authorizer/Authorization/Social/Twitter/ABOAuthCore/*{h,m}'
  spec.exclude_files = non_arc_files
  spec.subspec 'no-arc' do |subspec|
    subspec.source_files = non_arc_files
    subspec.requires_arc = false
  end
end