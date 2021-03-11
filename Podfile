# Uncomment this line to define a global platform for your project
platform :ios, "13.0"
use_frameworks!
use_modular_headers!

# Ignore all warnings from pods.
inhibit_all_warnings!

target "SudoSecureVault" do
  podspec :name => 'SudoSecureVault'
end

target "SudoSecureVaultTests" do
  podspec :name => 'SudoSecureVault'
end

target "SudoSecureVaultIntegrationTests" do
  podspec :name => 'SudoSecureVault'
  pod 'SudoProfiles'
end

target "TestApp" do
  podspec :name => 'SudoSecureVault'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
