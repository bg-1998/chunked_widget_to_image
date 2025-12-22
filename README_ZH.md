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
- 可配置编译选项，按需启用/禁用图像格式以减少应用体积
- 移动平台(Android/iOS/macOS)使用原生库(libpng, libjpeg-turbo)保证高性能和高质量
- Windows 和 Linux 平台使用 widget_to_image_converter 实现图像处理功能

## 安装

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  chunked_widget_to_image: ^0.0.2
```

然后运行：

```bash
flutter pub get
```

## 配置

默认情况下，插件包含对 PNG 和 JPEG 格式的支持。但是，您可以通过设置构建时环境变量来自定义此行为。

要在构建中禁用某些图像格式支持，请在运行或构建 Flutter 应用时设置环境变量：

```bash
# 禁用 PNG 支持
CHUNKED_WIDGET_TO_PNG=OFF flutter run

# 禁用 JPEG 支持
CHUNKED_WIDGET_TO_JPEG=OFF flutter run

# 同时禁用 PNG 和 JPEG 支持（不推荐）
CHUNKED_WIDGET_TO_PNG=OFF CHUNKED_WIDGET_TO_JPEG=OFF flutter run
```

在 Android Studio 中，您可以在运行/调试配置中设置这些环境变量：
1. 转到 Run > Edit Configurations...
2. 选择你的 Flutter 配置
3. 在 Environment Variables 部分，添加：
   - Name: `CHUNKED_WIDGET_TO_PNG`, Value: `OFF` (禁用 PNG)
   - Name: `CHUNKED_WIDGET_TO_JPEG`, Value: `OFF` (禁用 JPEG)

### 配置选项

- `CHUNKED_WIDGET_TO_PNG`: 启用/禁用 PNG 支持 (默认: ON)
- `CHUNKED_WIDGET_TO_JPEG`: 启用/禁用 JPEG 支持 (默认: ON)

禁用未使用的图像格式支持可以显著减小应用程序的二进制大小。

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

移动平台插件使用 CMake 构建原生代码。原生库 (libpng, libjpeg-turbo, libyuv) 作为子模块集成，并可以根据配置选项有条件地编译。

Windows 和 Linux 平台使用 widget_to_image_converter 实现图像处理功能。

当在编译时禁用某个功能时：
- 相应的源文件会被排除在编译之外
- 第三方库不会被构建或链接
- API 函数仍然存在，但在使用时会返回适当的错误码

这种方法确保了干净的编译过程，没有缺失的库依赖，同时为试图使用已禁用功能的开发人员提供明确的反馈。

## 错误处理

当某个功能在编译时被禁用，而用户试图使用它时：
- 函数将返回错误码 `-1` 表示该功能不可用
- 不会发生崩溃或未定义的行为

## 贡献

欢迎贡献！请随时提交问题和拉取请求。

## 许可证

该项目基于 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件了解详情。