import 'dart:io';

/// An utility to match platforms. It adds a general support for
/// OpenHarmony OS.
class PlatformUtils {
  const PlatformUtils._();

  /// Whether the operating system is a version of
  /// [ohos](https://en.wikipedia.org/wiki/OpenHarmony).
  static final isOhos = Platform.operatingSystem == 'ohos';
}