#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_candies_jpush.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_candies_jpush'
  s.version          = '0.0.1'
  s.summary          = 'JPush Flutter Plugin'
  s.description      = <<-DESC
JPush Flutter Plugin
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'JPush','4.6.6'
  s.dependency 'JCore','3.2.3'
  s.platform = :ios, '9.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
