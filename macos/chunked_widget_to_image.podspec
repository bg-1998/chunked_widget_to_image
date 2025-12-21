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

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.platform            = :osx
  s.requires_arc        = true
  s.static_framework    = true

  s.source           = { :path => '.' }

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'chunked_widget_to_image_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.15'
  
  s.prepare_command = <<-CMD
      rm -rf build
      mkdir -p build
      cd build
      cmake ../../src -DCMAKE_OSX_SYSROOT=macosx -DCMAKE_OSX_ARCHITECTURES=arm64 -DMACOS=ON
      make
  CMD
  s.script_phase = {
      :name => 'Build chunked_widget_to_image.framework',
      :script => 'echo "Using prebuilt framework: build/chunked_widget_to_image.framework"',
      :execution_position => :before_compile
  }

  s.vendored_frameworks = 'build/chunked_widget_to_image.framework'
  s.preserve_paths = 'build/chunked_widget_to_image.framework'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.swift_version = '5.0'
end