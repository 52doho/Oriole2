Pod::Spec.new do |s|
  s.name         = "Oriole2"
  s.version      = '0.1'
  s.summary      = "Oriole2 common libs."
  s.description  = "Oriole2"
  s.homepage     = "http://Oriole2.com"
  s.license      = "MIT (example)"  
  s.author       = { "Gary Wong" => "52doho@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/52doho/Oriole2.git", :branch=> "master"}
#  s.source       = { :git => "https://github.com/52doho/Oriole2.git", :tag => "v#{s.version}"}
  s.source_files  = "Oriole2", "Oriole2/**/*.{h,m,mm}"
  s.resources = "Oriole2/Resources/*.{bundle}"
  s.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/Parse" }
  s.frameworks = "SystemConfiguration", "MobileCoreServices", "StoreKit"
  s.requires_arc = true
  s.dependency "MBProgressHUD", '~> 0.9'
  s.dependency "StandardPaths", '~> 1.6.3'
  s.dependency "FXKeychain", '~> 1.5.2'
  s.dependency "iRate", '~> 1.11.3'
  s.dependency "iVersion", '~> 1.11.4'
  s.dependency "Parse", '~> 1.6.4'
end