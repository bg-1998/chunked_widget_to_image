# Chunked Widget to Image 插件

![](https://img.shields.io/badge/Awesome-Flutter-blue)
![](https://img.shields.io/badge/Platform-Android_iOS_Web_Windows_macOS_Linux_鸿蒙-blue)
![](https://img.shields.io/badge/License-MIT-blue)
![](https://img.shields.io/badge/版本-2.0.0-orange)

语言: 简体中文 | [English](README.md)

一款强大的 Flutter 插件，可将 Flutter 组件转换为高质量图像文件。采用先进的分块技术突破平台纹理尺寸限制，支持导出超大尺寸图片到 PNG 或 JPEG 格式。

## ✨ 功能特性

- 🎨 **通用组件转换**: 将任意 Flutter Widget 转换为 PNG 或 JPEG 格式图片
- 🖼️ **超大图像支持**: 导出任意尺寸图像，突破平台纹理限制 (16384px+)
- 🚀 **离屏渲染**: 无需将组件添加到组件树即可导出
- 📜 **长内容导出**: 自动分页导出长列表和可滚动内容
- ⚡ **高性能**: 使用原生库 (libpng, libjpeg-turbo) 保证最佳性能
- 🌐 **多平台支持**: Android、iOS、macOS、Windows、Linux 和鸿蒙

## 📦 安装

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  chunked_widget_to_image: ^2.0.0
```

然后运行：

```bash
flutter pub get
```

## 🎯 快速开始

### 基础用法

```dart
import 'package:chunked_widget_to_image/chunked_widget_to_image.dart';

// 创建控制器
final controller = WidgetToImageController();

// 使用 WidgetToImage 包装你的组件
WidgetToImage(
  controller: controller,
  child: YourWidget(), // 要转换的组件
),

// 导出为图片文件
controller.toImageFile(
  outPath: '/path/to/output.png',
  pixelRatio: 1.0,
  format: ImageFormat.png,
  callback: (result, message) {
    if (result) {
      print('✓ 导出成功: $message');
    } else {
      print('✗ 导出失败: $message');
    }
  },
);
```

### 离屏导出

无需显示组件即可导出：

```dart
controller.toImageFileFromWidget(
  YourWidget(),
  outPath: '/path/to/output.jpg',
  pixelRatio: 1.0,
  format: ImageFormat.jpg,
  context: context, // 可选：继承应用主题
  targetSize: Size(800, 600), // 可选：指定目标尺寸
  delay: Duration(seconds: 1),
  callback: (result, message) {
    // 处理结果
  },
);
```

### 长内容导出

非常适合导出长列表或可滚动内容：

```dart
controller.toImageFileFromLongWidget(
  YourLongListWidget(),
  outPath: '/path/to/output.png',
  pixelRatio: 1.0,
  format: ImageFormat.png,
  context: context,
  constraints: BoxConstraints(maxWidth: 800), // 可选：自定义约束
  callback: (result, message) {
    // 处理结果
  },
);
```

## 📖 API 文档

### WidgetToImageController

#### `toImageFile()`
将组件树中的组件导出为图片文件。

**参数：**
- `outPath` (必需): 输出文件路径
- `pixelRatio`: 设备像素比 (默认: 1.0)
- `format`: 图片格式 (png/jpeg)
- `callback`: 导出结果回调
- `delay`: 捕获前延迟时间 (默认: 20ms)

#### `toImageFileFromWidget()`
将离屏组件导出为图片文件。

**参数：**
- `widget` (必需): 要导出的组件
- `outPath` (必需): 输出文件路径
- `pixelRatio`: 设备像素比 (默认: 1.0)
- `format`: 图片格式 (png/jpeg)
- `context`: 用于主题继承的 BuildContext (可选)
- `targetSize`: 目标组件尺寸 (可选)
- `delay`: 捕获前延迟时间 (默认: 1s)
- `callback`: 导出结果回调

#### `toImageFileFromLongWidget()`
将长/可滚动组件导出为图片文件。

**参数：**
- `widget` (必需): 要导出的组件
- `outPath` (必需): 输出文件路径
- `pixelRatio`: 设备像素比 (默认: 1.0)
- `format`: 图片格式 (png/jpeg)
- `context`: 用于主题继承的 BuildContext (可选)
- `constraints`: 布局约束 BoxConstraints (可选)
- `delay`: 捕获前延迟时间 (默认: 1s)
- `callback`: 导出结果回调

### WidgetToImage 组件

便捷的组件，使用 RepaintBoundary 包装你的内容。

```dart
WidgetToImage(
  controller: controller,
  child: YourWidget(),
)
```

## 🌍 支持的平台

| 平台 | 状态 | 说明 |
|------|------|------|
| Android | ✅ 支持 | 完整支持 |
| iOS | ✅ 支持 | 完整支持 |
| macOS | ✅ 支持 | 仅支持 ARM64 (Apple Silicon) |
| Windows | ✅ 支持 | 完整支持 |
| Linux | ✅ 支持 | 提供 FFI 支持 |
| 鸿蒙 | ✅ 支持 | 完整支持 |


### 错误处理

所有导出方法都通过回调提供详细的错误信息：

```dart
callback: (result, message) {
  if (!result) {
    // 记录详细错误信息
    print('错误: $message');
    // 显示用户友好的错误提示
    showDialog(...);
  }
}
```

## 📝 完整示例

查看 [example](example/) 目录获取完整的工作示例，包括：
- 基础组件导出
- 离屏渲染
- 长列表导出
- 性能计时
- 全屏预览

## 📄 许可证

本项目基于 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。
