require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-karhoo-sdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["licence"]
  s.authors      = package["author"]
  s.platforms    = { :ios => "12.0" }
  s.source       = { :git => "https://github.com/@iteratorsmobile/react-native-karhoo-sdk.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.requires_arc = true

  s.dependency 'React'
  s.dependency 'KarhooSDK', '1.6.3'
  s.dependency 'Braintree', '5.16.0'
  s.dependency 'BraintreeDropIn', '9.7.0'
end

