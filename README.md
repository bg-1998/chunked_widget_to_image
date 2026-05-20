# Chunked Widget to Image Plugin

![](https://img.shields.io/badge/Awesome-Flutter-blue)
![](https://img.shields.io/badge/Platform-Android_iOS_Web_Windows_macOS_Linux_HarmonyOS-blue)
![](https://img.shields.io/badge/License-MIT-blue)
![](https://img.shields.io/badge/Version-2.0.0-orange)

Language: English | [简体中文](README_ZH.md)

A powerful Flutter plugin that converts Flutter widgets to high-quality image files. Using advanced chunking technology to break through platform texture size limitations, supports exporting ultra-large images to PNG or JPEG format.

## ✨ Features

- 🎨 **Universal Widget Conversion**: Convert any Flutter Widget to PNG or JPEG format image files
- 🖼️ **Ultra-Large Image Support**: Export images of any size, breaking through platform texture limitations (16384px+)
- 🚀 **Off-Screen Rendering**: Export widgets without adding them to the widget tree
- 📜 **Long Content Export**: Automatic pagination export for long lists and scrollable content
- ⚡ **High Performance**: Uses native libraries (libpng, libjpeg-turbo) for optimal performance
- 🌐 **Multi-Platform Support**: Android, iOS, macOS, Windows, Linux, and HarmonyOS

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  chunked_widget_to_image: ^2.0.0
```

Then run:

```bash
flutter pub get
```

## 🎯 Quick Start

### Basic Usage

```dart
import 'package:chunked_widget_to_image/chunked_widget_to_image.dart';

// Create controller
final controller = WidgetToImageController();

// Wrap your widget with WidgetToImage
WidgetToImage(
  controller: controller,
  child: YourWidget(), // The widget you want to convert
),

// Export to image file
controller.toImageFile(
  outPath: '/path/to/output.png',
  pixelRatio: 1.0,
  format: ImageFormat.png,
  callback: (result, message) {
    if (result) {
      print('✓ Export successful: $message');
    } else {
      print('✗ Export failed: $message');
    }
  },
);
```

### Off-Screen Export

Export widgets without displaying them on screen:

```dart
controller.toImageFileFromWidget(
  YourWidget(),
  outPath: '/path/to/output.jpg',
  pixelRatio: 1.0,
  format: ImageFormat.jpg,
  context: context, // Optional: inherit app theme
  targetSize: Size(800, 600), // Optional: specify target size
  delay: Duration(seconds: 1),
  callback: (result, message) {
    // Handle result
  },
);
```

### Long Content Export

Perfect for exporting long lists or scrollable content:

```dart
controller.toImageFileFromLongWidget(
  YourLongListWidget(),
  outPath: '/path/to/output.png',
  pixelRatio: 1.0,
  format: ImageFormat.png,
  context: context,
  constraints: BoxConstraints(maxWidth: 800), // Optional: custom constraints
  callback: (result, message) {
    // Handle result
  },
);
```

## 📖 API Reference

### WidgetToImageController

#### `toImageFile()`
Export widget from widget tree to image file.

**Parameters:**
- `outPath` (required): Output file path
- `pixelRatio`: Device pixel ratio (default: 1.0)
- `format`: Image format (png/jpeg)
- `callback`: Export result callback
- `delay`: Delay before capture (default: 20ms)

#### `toImageFileFromWidget()`
Export off-screen widget to image file.

**Parameters:**
- `widget` (required): Widget to export
- `outPath` (required): Output file path
- `pixelRatio`: Device pixel ratio (default: 1.0)
- `format`: Image format (png/jpeg)
- `context`: BuildContext for theme inheritance (optional)
- `targetSize`: Target widget size (optional)
- `delay`: Delay before capture (default: 1s)
- `callback`: Export result callback

#### `toImageFileFromLongWidget()`
Export long/scrollable widget to image file.

**Parameters:**
- `widget` (required): Widget to export
- `outPath` (required): Output file path
- `pixelRatio`: Device pixel ratio (default: 1.0)
- `format`: Image format (png/jpeg)
- `context`: BuildContext for theme inheritance (optional)
- `constraints`: BoxConstraints for layout (optional)
- `delay`: Delay before capture (default: 1s)
- `callback`: Export result callback

### WidgetToImage Widget

A convenience widget that wraps your content with a RepaintBoundary.

```dart
WidgetToImage(
  controller: controller,
  child: YourWidget(),
)
```

## 🌍 Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Supported | Full support |
| iOS | ✅ Supported | Full support |
| macOS | ✅ Supported | ARM64 only (Apple Silicon) |
| Windows | ✅ Supported | Full support |
| Linux | ✅ Supported | FFI support available |
| HarmonyOS | ✅ Supported | Full support |





## 📝 Complete Example

See the [example](example/) directory for a complete working example including:
- Basic widget export
- Off-screen rendering
- Long list export
- Performance timing
- Full-screen preview



## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

