Pod::Spec.new do |s|
  s.name             = 'KKCocoaCommon'
  s.version          = '1.0.7'
  s.summary          = 'Cocoa common.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/LeungKinKeung/KKCocoaCommon'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LeungKinKeung' => 'leungkinkeung@qq.com' }
  s.source           = { :git => 'https://github.com/LeungKinKeung/KKCocoaCommon.git', :tag => s.version.to_s }
  
  s.osx.deployment_target = '10.10'
  
  s.source_files    = 'KKCocoaCommon/Classes/**/*.{h,m,mm,c}'
  s.osx.frameworks  = ['AppKit', 'QuartzCore', 'CoreGraphics']
  
end
