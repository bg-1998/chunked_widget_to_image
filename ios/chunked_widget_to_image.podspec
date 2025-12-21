#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint chunked_widget_to_image.podspec` to validate before publishing.
#
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

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.prepare_command = <<-CMD
    rm -rf build
    mkdir -p build
    cd build
    cmake ../../src -DCMAKE_OSX_SYSROOT=iphoneos -DCMAKE_OSX_ARCHITECTURES=arm64 -DIOS=ON
    make
  CMD
  s.script_phase = {
    :name => 'Build chunked_widget_to_image.framework',
    :script => 'echo "Using prebuilt framework: build/chunked_widget_to_image.framework"',
    :execution_position => :before_compile
  }

  s.vendored_frameworks = 'build/chunked_widget_to_image.framework'
  s.preserve_paths = 'build/chunked_widget_to_image.framework'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }

  s.swift_version = '5.0'
end