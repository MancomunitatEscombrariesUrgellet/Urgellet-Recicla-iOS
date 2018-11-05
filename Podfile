# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target 'Urgellet' do
    # Comment this line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.1'
            end
        end
    end
    pod 'APESuperHUD', :tag => '2.0.1', :git => 'https://github.com/apegroup/APESuperHUD.git'
    pod 'RealmSwift'
    pod 'TTGSnackbar', '1.7.3'
    pod 'SwiftyTimer', '2.0.0'
    pod 'ReachabilitySwift', '3'
    pod 'PDFReader', '2.5.0'
    pod 'SwiftyJSON', '4.1.0'
    pod 'SwiftEventBus', :tag => '2.2.0', :git => 'https://github.com/cesarferreira/SwiftEventBus.git'
end
