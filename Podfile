# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

def tio_chat
    inhibit_all_warnings!
    pod 'YYModel'
    pod 'AFNetworking'
    pod 'GoogleWebRTC'
    pod 'JPush'
end

def tio_chat_demo
    inhibit_all_warnings!
    pod 'MBProgressHUD'
    pod 'SDWebImage'
    pod 'YYWebImage'
    pod 'M80AttributedLabel'
    pod 'MJRefresh'
    pod 'DZNEmptyDataSet'
    pod 'CocoaLumberjack'
    pod 'DZNEmptyDataSet'
    pod 'JSONModel'

end


target 'tio-chat-ios' do
#   Comment the next line if you don't want to use dynamic frameworks
#  use_frameworks!
  use_modular_headers!

  # Pods for tio-chat-ios
  tio_chat
  tio_chat_demo

end
