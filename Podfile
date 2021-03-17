# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

target 'Chat And Note' do
  use_frameworks!

  # Firebase
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'

pod 'FBSDKLoginKit'
pod 'GoogleSignIn'

pod 'MessageKit'
pod 'JGProgressHUD'
pod 'SDWebImage'

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
end
