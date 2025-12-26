# Chunked Widget to Image 插件

![](https://img.shields.io/badge/Awesome-Flutter-blue)
![](https://img.shields.io/badge/Platform-Android_iOS_Web_Windows_MacOS_Linux-blue)
![](https://img.shields.io/badge/License-MIT-blue)

语言: 简体中文 | [English](README.md)

一个 Flutter 插件，可以将 Flutter widgets 转换为图像文件，支持通过分块技术处理大图像。

## 功能特性

- 将任意 Flutter Widget 转换为 PNG 或 JPEG 格式的图片文件
- 支持超大尺寸图像导出（突破大多数平台的纹理限制）
- 离屏渲染支持，无需将 Widget 添加到 Widget 树中即可导出
- 长列表/长内容自动分页导出功能
- 预编译静态库，提供更快的构建时间和一致的行为
- 移动平台(Android/iOS/macOS)使用原生库(libpng, libjpeg-turbo)保证高性能和高质量
- Windows 和 Linux 平台使用 widget_to_image_converter 实现图像处理功能

## 安装

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  chunked_widget_to_image: ^latest
```

然后运行：

```bash
flutter pub get
```

## 平台实现

插件根据平台使用不同的实现方式：

- 移动平台 (Android/iOS/macOS): 使用原生库(libpng, libjpeg-turbo)保证高性能和高质量
- 桌面平台 (Windows/Linux): 使用 widget_to_image_converter 实现图像处理功能

插件现在使用预编译的静态库进行图像处理，而不是构建时配置选项。这种方法消除了构建时环境变量的需求，并提供更快的构建时间。

## 使用方法

### 基础用法

```dart
// 创建控制器
final controller = WidgetToImageController();

// 在 Widget 树中使用
WidgetToImage(
  controller: controller,
  child: YourWidget(), // 你想要转换为图片的 widget
),

// 导出为图片文件
controller.toImageFile(
  outPath: '/path/to/output.png',
  format: ImageFormat.png,
  callback: (result, message) {
    if (result) {
      print('图片导出成功: $message');
    } else {
      print('图片导出失败: $message');
    }
  },
);
```

### 离屏渲染

```dart
// 不需要将 widget 添加到 widget 树中即可导出
controller.toImageFileFromWidget(
  YourWidget(),
  outPath: '/path/to/output.jpg',
  format: ImageFormat.jpg,
  callback: (result, message) {
    // 处理结果
  },
);
```

### 长内容导出

```dart
// 导出长列表或长内容 widget
controller.toImageFileFromLongWidget(
  YourLongWidget(),
  outPath: '/path/to/output.png',
  format: ImageFormat.png,
  callback: (result, message) {
    // 处理结果
  },
);
```

## 支持的平台

- Android
- iOS
- Linux
- macOS
- Windows

## 构建说明

插件现在使用预编译静态库进行图像处理，而不是从源代码构建。这种方法提供了：

- 更快的构建时间
- 跨环境的一致行为
- 简化的构建复杂度

移动平台 (Android/iOS/macOS) 使用作为预编译静态库分发的原生库 (libpng, libjpeg-turbo)。

桌面平台 (Windows/Linux) 继续使用 widget_to_image_converter 实现图像处理功能。

## macOS 架构支持

macOS 平台现在仅支持 ARM64 架构 (Apple Silicon)。此变更简化了分发并确保在现代 macOS 设备上的最佳性能。

## 错误处理

当某个功能在编译时被禁用，而用户试图使用它时：
- 函数将返回错误码 `-1` 表示该功能不可用
- 不会发生崩溃或未定义的行为

## 贡献

欢迎贡献！请随时提交问题和拉取请求。

## 许可证

该项目基于 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件了解详情。