Pod::Spec.new do |s|
  s.name             = 'flutter_ios_app_shortcuts'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin for iOS App Shortcuts (AppIntents) deep-link navigation.'
  s.description      = <<-DESC
    A Flutter plugin that enables iOS App Shortcuts (AppIntents, iOS 16+) to
    deep-link directly into specific screens of your Flutter app. Handles both
    cold-start and warm-start launches reliably using UserDefaults + EventChannel.
  DESC
  s.homepage         = 'https://github.com/abdulrahmanelsehemy/flutter_ios_app_shortcuts'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Abdulrahman Elsehemy' => 'a.elsehemy10@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency         'Flutter'
  s.platform         = :ios, '16.0'
  s.swift_version    = '5.0'
end
