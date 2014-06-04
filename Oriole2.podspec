Pod::Spec.new do |s|
  s.name         = "Oriole2"
  s.version      = "0.1"
  s.summary      = "A short description of Oriole2."
  s.description  = "Oriole2"
  s.homepage     = "http://Oriole2.com"
  s.license      = "MIT (example)"  
  s.author       = { "Gary Wong" => "52doho@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/52doho/Oriole2.git" }
  s.source_files  = "Oriole2", "Oriole2/**/*.{h,m,mm}"
#  s.public_header_files = "Oriole2/Oriole2/OOCommon.h"
  s.resources = "Oriole2/Resources/*.{bundle}"
  s.preserve_paths = "Oriole2/ThirdParty/Flurry_5.0/*.a"
  s.libraries = "libz"
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(PODS_ROOT)/Flurry" }
  s.frameworks = "SystemConfiguration", "MobileCoreServices", "StoreKit", "CrashReporter"
  s.requires_arc = true
  s.dependency "MBProgressHUD", '~> 0.8'
  s.dependency "QuincyKit", '~> 2.1.9'
#  s.dependency "TapkuLibrary", '~> 0.3.3'
  s.dependency "StandardPaths", '~> 1.5.6'
#  s.dependency "MKStoreKit", '~> 4.99'
  s.dependency "FXKeychain", '~> 1.5'
#  s.dependency "FlurrySDK", '~> 5.0.0'
end
