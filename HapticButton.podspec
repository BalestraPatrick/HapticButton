Pod::Spec.new do |s|
  s.name             = 'HapticButton'
  s.version          = '0.1'
  s.summary          = 'A button that is triggered based on the 3D Touch pressure, similar to the iOS 11 control center.'

  s.description      = <<-DESC
A button that is triggered based on the 3D Touch pressure, similar to the iOS 11 control center.
                       DESC

  s.homepage         = 'https://github.com/BalestraPatrick/HapticButton'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'BalestraPatrick' => 'me@patrickbalestra.com' }
  s.source           = { :git => 'https://github.com/BalestraPatrick/HapticButton.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/BalestraPatrick'

  s.ios.deployment_target = '10.0'

  s.source_files = 'HapticButton/Classes/**/*'

end
