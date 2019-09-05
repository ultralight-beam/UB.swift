# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'UB' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  xcodeproj 'UB'

  # Pods for UB
  pod 'SwiftProtobuf', '~> 1.0'

  target 'UBTests' do
    inherit! :search_paths
    pod "SwiftProtobuf"
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5.0'
      end
    end
  end
end
