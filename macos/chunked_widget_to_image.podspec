#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint chunked_widget_to_image.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'chunked_widget_to_image'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.requires_arc        = true
  s.static_framework    = true

  s.source           = { :path => '.' }

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.15'

  s.prepare_command = <<-CMD
    set -e

    rm -rf build

    cmake \
      -S ../src \
      -B build \
      -DCMAKE_OSX_SYSROOT=macosx \
      -DCMAKE_OSX_ARCHITECTURES=arm64 \
      -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
      -DCMAKE_BUILD_TYPE=Release \
      -DPNG_FRAMEWORK=OFF

    cmake --build build --config Release --parallel
  CMD

  s.vendored_frameworks = 'build/chunked_widget_to_image.framework'
  s.preserve_paths = 'build/chunked_widget_to_image.framework'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
