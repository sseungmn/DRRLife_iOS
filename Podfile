# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'DRRLife' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'NMapsMap'

# API Networking
  pod 'Moya'
# UI programmatically
  pod 'Then'
  pod 'SnapKit'
# More
  pod 'MBProgressHUD'
# Firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'

  target 'DRRLifeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DRRLifeUITests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
end
