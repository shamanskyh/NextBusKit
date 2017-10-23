Pod::Spec.new do |s|
  s.name             = 'NextBusKit'
  s.version          = '0.1.3'
  s.summary          = 'A Swift interface for NextBus.'
  s.description      = <<-DESC
NextBusKit is a Swift interface for interacting with the NextBus API.
                       DESC
  s.homepage         = 'https://github.com/shamanskyh/NextBusKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shamanskyh' => 'harry.shamansky@icloud.com' }
  s.source           = { :git => 'https://github.com/shamanskyh/NextBusKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/**/*'
  s.dependency 'Kanna', '~> 2.1.0'
end
