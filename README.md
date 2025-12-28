# Chunked Widget to Image Plugin

![](https://img.shields.io/badge/Awesome-Flutter-blue)
![](https://img.shields.io/badge/Platform-Android_iOS_Web_Windows_MacOS-blue)
![](https://img.shields.io/badge/License-MIT-blue)

Language: English | [简体中文](README_ZH.md)

A Flutter plugin that converts Flutter widgets to image files with support for large images via chunking technology.

## Features

- Convert any Flutter Widget to PNG or JPEG format image files
- Support exporting ultra-large sized images (breaking most platform texture limitations)
- Off-screen rendering support without adding Widget to the Widget tree
- Automatic pagination export function for long lists/long content
- Pre-compiled static libraries for faster build times and consistent behavior
- Uses native libraries (libpng, libjpeg-turbo) for high performance and quality on supported platforms (Android/iOS/macOS/Windows)
- Linux platform is currently not supported

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

## Platform Implementation

This plugin uses different implementations based on the platform:

- Supported platforms (Android/iOS/macOS/Windows): Uses native libraries (libpng, libjpeg-turbo) for high performance and quality
- Linux platform is currently not supported

The plugin now uses pre-compiled static libraries for image processing instead of build-time configuration options. This approach eliminates the need for build-time environment variables and provides faster build times.

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
- macOS
- Windows

## Building

The plugin now uses pre-compiled static libraries for image processing instead of building from source. This approach provides:

- Faster build times
- Consistent behavior across environments
- Reduced build complexity

Supported platforms (Android/iOS/macOS/Windows) use native libraries (libpng, libjpeg-turbo) distributed as pre-compiled static libraries.

Windows platform uses native libraries (libpng, libjpeg-turbo) for high performance and quality.
Linux platform is currently not supported.

## macOS Architecture Support

The macOS platform now supports only ARM64 architecture (Apple Silicon). This change simplifies distribution and ensures optimal performance on modern macOS devices.

## Error Handling

When a feature is disabled at compile time and a user attempts to use it:
- Functions will return error code `-1` indicating the feature is not available
- No crashes or undefined behavior will occur

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.