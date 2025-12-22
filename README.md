# Chunked Widget to Image Plugin

![](https://img.shields.io/badge/Awesome-Flutter-blue)
![](https://img.shields.io/badge/Platform-Android_iOS_Web_Windows_MacOS_Linux-blue)
![](https://img.shields.io/badge/License-MIT-blue)

Language: English | [简体中文](README_ZH.md)

A Flutter plugin that converts Flutter widgets to image files with support for large images via chunking technology.

## Features

- Convert any Flutter Widget to PNG or JPEG format image files
- Support exporting ultra-large sized images (breaking most platform texture limitations)
- Off-screen rendering support without adding Widget to the Widget tree
- Automatic pagination export function for long lists/long content
- Configurable compilation options to enable/disable image formats on demand to reduce app size
- Uses native libraries (libpng, libjpeg-turbo) for high performance and quality on mobile platforms (Android/iOS/macOS)
- Uses widget_to_image_converter for image processing on Windows and Linux platforms

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  chunked_widget_to_image: ^latest
```

Then run:

```bash
flutter pub get
```

## Configuration

By default, the plugin includes support for both PNG and JPEG formats. However, you can customize this behavior by setting environment variables at build time.

To disable certain image format supports in your build, set environment variables when running or building your Flutter app:

```bash
# Disable PNG support
CHUNKED_WIDGET_TO_PNG=OFF flutter run

# Disable JPEG support
CHUNKED_WIDGET_TO_JPEG=OFF flutter run

# Disable both PNG and JPEG support (not recommended)
CHUNKED_WIDGET_TO_PNG=OFF CHUNKED_WIDGET_TO_JPEG=OFF flutter run
```

In Android Studio, you can set these environment variables in your Run/Debug Configuration:
1. Go to Run > Edit Configurations...
2. Select your Flutter configuration
3. In the Environment Variables section, add:
   - Name: `CHUNKED_WIDGET_TO_PNG`, Value: `OFF` (to disable PNG)
   - Name: `CHUNKED_WIDGET_TO_JPEG`, Value: `OFF` (to disable JPEG)

### Configuration Options

- `CHUNKED_WIDGET_TO_PNG`: Enable/disable PNG support (default: ON)
- `CHUNKED_WIDGET_TO_JPEG`: Enable/disable JPEG support (default: ON)

Disabling unused image format support can significantly reduce your app's binary size.

## Usage

### Basic Usage

```dart
// Create controller
final controller = WidgetToImageController();

// Use in widget tree
WidgetToImage(
  controller: controller,
  child: YourWidget(), // The widget you want to convert to image
),

// Export to image file
controller.toImageFile(
  outPath: '/path/to/output.png',
  format: ImageFormat.png,
  callback: (result, message) {
    if (result) {
      print('Image exported successfully: $message');
    } else {
      print('Image export failed: $message');
    }
  },
);
```

### Off-screen Rendering

```dart
// Export widget without adding it to the widget tree
controller.toImageFileFromWidget(
  YourWidget(),
  outPath: '/path/to/output.jpg',
  format: ImageFormat.jpg,
  callback: (result, message) {
    // Handle result
  },
);
```

### Long Content Export

```dart
// Export long list or long content widget
controller.toImageFileFromLongWidget(
  YourLongWidget(),
  outPath: '/path/to/output.png',
  format: ImageFormat.png,
  callback: (result, message) {
    // Handle result
  },
);
```

## Supported Platforms

- Android
- iOS
- Linux
- macOS
- Windows

## Building

The plugin uses CMake for building native code on mobile platforms. The native libraries (libpng, libjpeg-turbo, libyuv) are integrated as submodules and can be conditionally compiled based on the configuration options.

On Windows and Linux platforms, the plugin uses widget_to_image_converter for image processing.

When a feature is disabled at compile time:
- The corresponding source files are excluded from compilation
- The third-party libraries are not built or linked
- The API functions still exist but will return appropriate error codes when used

This approach ensures clean compilation without missing library dependencies while providing clear feedback to developers attempting to use disabled features.

## Error Handling

When a feature is disabled at compile time and a user attempts to use it:
- Functions will return error code `-1` indicating the feature is not available
- No crashes or undefined behavior will occur

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.