require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-karhoo-sdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-karhoo-sdk
                   DESC
  s.homepage     = package["homepage"]
  s.license      = package["licence"]
  s.authors      = package["author"]
  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/github_account/react-native-karhoo-sdk.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  s.dependency "KarhooSDK"
  s.dependency "BraintreeDropIn"
  s.dependency "React"
end

