
Pod::Spec.new do |s|
  s.name             = 'chunked_widget_to_image'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'https://github.com/bg-1998'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bg' => '2967769426@qq.com' }

  s.platform            = :osx
  s.requires_arc        = true
  s.static_framework    = true

  s.source           = { :path => '.' }

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.15'

  s.vendored_frameworks = 'chunked_widget_to_image.framework'
  s.preserve_paths = 'chunked_widget_to_image.framework'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.swift_version = '5.0'
end