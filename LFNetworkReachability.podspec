Pod::Spec.new do |s|
  s.name               = 'LFNetworkReachability'
  s.summary            = 'Reachability'
  s.version            = '1.0.1'
  s.license            = { :type => 'Apache License Version 2.0', :file => 'LICENSE' }
  s.authors            = { 'wangxiaoxiang' => 'wangxiaoxiang@youku.com' }
  s.social_media_url   = 'https://github.com/LaiFengiOS/LFNetworkReachability'
  s.homepage           = 'https://github.com/LaiFengiOS/LFNetworkReachability'
  s.platform           = :ios, '6.0'
  s.ios.deployment_target   = '6.0'
  s.source                  = { :git => 'https://github.com/LaiFengiOS/LFNetworkReachability.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.source_files = 'src/LFNetworkReachability.{h,m}'
  s.public_header_files = 'src/LFNetworkReachability.{h}'
  s.framework = "SystemConfiguration"
end
