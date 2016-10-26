source 'https://git.groriri.me/frajaona/privatepods.git'
source 'https://github.com/CocoaPods/Specs.git'
# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

def cas_pods()
  pod 'CocoaAsyncSocket', '~> 7.5.0'
end

def socks_pods()
  pod 'socks', '~> 1.0.3'
end

target 'LiFXSwiftKitiOS' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LiFXSwiftKitiOS
  cas_pods()

  target 'LiFXSwiftKitiOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'LiFXSwiftKitMacOS' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LiFXSwiftKitMacOS
  socks_pods()

  target 'LiFXSwiftKitMacOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'LiFXSwiftKitTVOS' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LiFXSwiftKitTVOS
  cas_pods()

  target 'LiFXSwiftKitTVOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
