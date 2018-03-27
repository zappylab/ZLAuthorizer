Pod::Spec.new do |spec|
  spec.platform = :ios, "9.0"
  spec.name = 'ZLAuthorizer'
  spec.version = '0.3'
  spec.homepage = 'https://github.com/zappylab/ZLAuthorizer'
  spec.authors = { 'Ilya Dyakonov' => 'ilya@zappylab.com' }
  spec.summary = 'Authorization module used by ZappyLab'
  spec.source = { :git => 'https://github.com/zappylab/ZLAuthorizer.git', :branch => "dev" }
  spec.source_files = 'Authorizer/**/*.{h,m}'
  spec.dependency 'Lockbox'
  spec.dependency 'NSString+Validation'
  spec.dependency 'AFNetworking'
  spec.dependency 'BlocksKit', '~> 2.2.0'
  spec.dependency 'FBSDKLoginKit'
  spec.dependency 'GoogleSignIn'
  spec.dependency 'TwitterKit'
  spec.frameworks = 'Security', 'SystemConfiguration', 'AssetsLibrary'
  spec.requires_arc = true
end
