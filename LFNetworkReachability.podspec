Pod::Spec.new do |s|
  s.name               = 'LFNetworkReachability'
  s.summary            = 'Reachability'
  s.version            = '1.1.0'
  s.license            = { :type => 'Apache License Version 2.0', :file => 'LICENSE' }
  s.authors            = { 'wangxiaoxiang' => 'wangxiaoxiang@youku.com' }
  s.homepage           = 'https://github.com/LaiFengiOS/LFNetworkReachability'
  s.source                  = { :git => 'https://github.com/LaiFengiOS/LFNetworkReachability.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'LFNetworkReachability/LFNetworkReachability/*.{h,m}'
  s.public_header_files = 'LFNetworkReachability/LFNetworkReachability/*.h'

  s.frameworks = 'SystemConfiguration'
  s.requires_arc = true
end
