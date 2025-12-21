# Chunked Widget To Image 插件说明

## 中文说明

Chunked Widget To Image 是一个强大的 Flutter 插件，可以将 Flutter Widgets 转换为高质量的图片文件。该插件专为处理大型图像而设计，采用分块技术来避免内存问题，并支持多种图像格式。

主要特性：
- 将任意 Flutter Widget 转换为 PNG 或 JPEG 格式的图片文件
- 支持超大尺寸图像导出（突破大多数平台的纹理限制）
- 离屏渲染支持，无需将 Widget 添加到 Widget 树中即可导出
- 长列表/长内容自动分页导出功能
- 可配置编译选项，按需启用/禁用图像格式以减少应用体积
- 使用原生库(libpng, libjpeg-turbo)保证高性能和高质量

## English Description

Chunked Widget To Image is a powerful Flutter plugin that converts Flutter Widgets into high-quality image files. The plugin is designed specifically for handling large images, using chunking techniques to avoid memory issues, and supports multiple image formats.

Key features:
- Convert any Flutter Widget to PNG or JPEG format image files
- Support exporting ultra-large sized images (breaking most platform texture limitations)
- Off-screen rendering support, allowing export without adding Widget to the Widget tree
- Automatic pagination export function for long lists/long content
- Configurable compilation options to enable/disable image formats on demand to reduce app size
- Uses native libraries (libpng, libjpeg-turbo) to ensure high performance and quality