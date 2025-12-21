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
- Uses native libraries (libpng, libjpeg-turbo) for high performance and quality

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  chunked_widget_to_image: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Configuration

By default, the plugin includes support for both PNG and JPEG formats. However, you can customize this behavior by configuring the plugin in your app's `pubspec.yaml` file.

To disable certain image format supports in your build, add the following to your `pubspec.yaml`:

```yaml
# In your app's pubspec.yaml
dependencies:
  chunked_widget_to_image:
    # ... your chunked_widget_to_image dependency configuration

# Add this section to configure the plugin
chunked_widget_to_image:
  with_png: false   # Set to false to exclude PNG support
  with_jpeg: false  # Set to false to exclude JPEG support
```

### Configuration Options

- `with_png`: Enable/disable PNG support (default: true)
- `with_jpeg`: Enable/disable JPEG support (default: true)

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

The plugin uses CMake for building native code. The native libraries (libpng, libjpeg-turbo, libyuv) are integrated as submodules and can be conditionally compiled based on the configuration options.

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