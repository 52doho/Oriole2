Pod::Spec.new do |s|
  s.name         = "Oriole2"
  s.version      = '0.1.1'
  s.summary      = "Oriole2 common libs for iOS."
  s.homepage     = "https://github.com/52doho"
  s.license      = "MIT"
  s.author       = { "Gary Wong" => "52doho@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/52doho/Oriole2.git", :tag => "v#{s.version}"}
  s.source_files  = "Oriole2", "Oriole2/**/*.{h,m,mm}"
  s.resources = "Oriole2/Resources/*.{bundle}"
  s.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/Parse" }
  s.frameworks = "SystemConfiguration", "MobileCoreServices", "StoreKit"
  s.requires_arc = true
  s.dependency "MBProgressHUD"
  s.dependency "iRate"
  s.dependency "iVersion"
  s.dependency "Google-Mobile-Ads-SDK"
  s.dependency "Firebase/Core"
  s.dependency "Firebase/Analytics"
  s.dependency "RMStore"
end
