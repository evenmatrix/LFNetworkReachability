Pod::Spec.new do |s|
  s.name               = 'LFNetworkReachability'
  s.summary            = 'Reachability'
  s.version            = '1.0.4'
  s.license            = { :type => 'Apache License Version 2.0', :file => 'LICENSE' }
  s.authors            = { 'wangxiaoxiang' => 'wangxiaoxiang@youku.com' }
  s.social_media_url   = 'https://github.com/LaiFengiOS/LFNetworkReachability'
  s.homepage           = 'https://github.com/LaiFengiOS/LFNetworkReachability'
  s.platform           = :ios, '6.0'
  s.ios.deployment_target   = '6.0'
  s.source                  = { :git => 'https://github.com/LaiFengiOS/LFNetworkReachability.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.preserve_paths = 'LFNetworkReachability/framework/LFNetworkReachability.framework'
  s.vendored_frameworks = 'LFNetworkReachability/framework/LFNetworkReachability.framework'
  s.framework = "SystemConfiguration"
end
