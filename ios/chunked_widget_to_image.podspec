pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

current_dir = Dir.pwd
calling_dir = File.dirname(__FILE__)
project_dir = calling_dir.slice(0..(calling_dir.index('/.symlinks')))
symlinks_index = calling_dir.index('/ios/.symlinks')
if !symlinks_index
    symlinks_index = calling_dir.index('/.ios/.symlinks')
end

flutter_project_dir = calling_dir.slice(0..(symlinks_index))

Pod::UI.puts "[chunked_widget_to_image] #{Psych::VERSION}"
psych_version_gte_500 = Gem::Version.new(Psych::VERSION) >= Gem::Version.new('5.0.0')
if psych_version_gte_500 == true
    cfg = YAML.load_file(File.join(flutter_project_dir, 'pubspec.yaml'), aliases: true)
else
    cfg = YAML.load_file(File.join(flutter_project_dir, 'pubspec.yaml'))
end

with_png = "ON"

if cfg['chunked_widget_to_image'] && cfg['chunked_widget_to_image']['with_png'] != true
    with_png = 'OFF'
end

with_jpeg = "ON"

if cfg['chunked_widget_to_image'] && cfg['chunked_widget_to_image']['with_jpeg'] != true
    with_jpeg = 'OFF'
end


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
    cmake ../../src -DCMAKE_OSX_SYSROOT=iphoneos -DCMAKE_OSX_ARCHITECTURES=arm64 -DIOS=ON -DWITH_PNG=#{with_png} -DWITH_JPEG=#{with_jpeg}
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