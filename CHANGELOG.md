## 1.0.0

* BREAKING CHANGE: 移除构建时配置选项 (CHUNKED_WIDGET_TO_PNG 和 CHUNKED_WIDGET_TO_JPEG)
* BREAKING CHANGE: 使用预编译静态库替代构建时编译，提供更快的构建时间和一致的行为
* BREAKING CHANGE: macOS 平台现在仅支持 ARM64 架构 (Apple Silicon)
* 更新文档以反映平台实现变更
* Bump version to 1.0.0

## 0.0.2

* Change configuration method from pubspec.yaml settings to environment variables
* Update documentation to reflect new configuration method
* Bump version to 0.0.2

## 0.0.1

* Initial release
* Support converting Flutter widgets to PNG/JPEG image files
* Implement chunking mechanism for large image handling
* Add off-screen widget rendering capability
* Support configurable compilation for PNG/JPEG formats
* Provide long list/image export functionality