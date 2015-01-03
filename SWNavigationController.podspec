Pod::Spec.new do |s|
  s.name     = 'SWNavigationController'
  s.version  = '0.0.1'
  s.author   = { 'Chris Wendel' => 'chriwend@umich.edu' }
  s.homepage = 'https://github.com/CEWendel/SWNavigationController'
  s.summary  = 'A UINavigationController subclass and corresponding UINavigationControllerDelegate that provides drop-in support for edge-swiping left and right through a view hierarchy.'
  s.license  = 'MIT'
  s.source   = { :git => 'https://github.com/CEWendel/SWNavigationController.git', :tag => s.version.to_s }
  s.source_files = 'SWNavigationController/PodFiles/*.{h,m}'
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
end
