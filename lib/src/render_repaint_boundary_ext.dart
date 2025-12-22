import 'dart:ffi' as ffi;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:ffi/ffi.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:chunked_widget_to_image/chunked_widget_to_image.dart';
import 'package:widget_to_image_converter/widget_to_image_converter.dart';
import 'chunked_widget_to_image_bindings_generated.dart';

const int _kMaxChunkSize = 16384;//大部分平台能显示的图片最大宽高

extension RenderRepaintBoundaryExt on RenderRepaintBoundary{
  /// 将widget保存为图片
  ///
  /// [outPath] 图像保存的路径
  /// [chunkHeight] 分块大小
  /// [pixelRatio] 缩放比例
  /// [format] 图像格式
  /// [callback] 保存回调
  void toImageByChunks({
    required String outPath,
    double? chunkHeight,
    double pixelRatio = 1.0,
    ImageFormat format = ImageFormat.png,
    void Function(bool result,String message)? callback
  }) async {
    if(size.width*pixelRatio > _kMaxChunkSize||
        size.height*pixelRatio > _kMaxChunkSize){
      pixelRatio = pixelRatio*(_kMaxChunkSize/math.max(size.width,size.height));
    }
    Size convSize = Size((size.width ~/ 2) * 2, (size.height ~/ 2) * 2);
    Size outSize = Size((convSize.width * pixelRatio), (convSize.height * pixelRatio));
    chunkHeight = ((chunkHeight??(_kMaxChunkSize*1024/
        math.min(convSize.width*pixelRatio,_kMaxChunkSize)).ceil()) ~/ 2) * 2;
    if (chunkHeight <= 0) {
      throw ArgumentError('chunkHeight 必须大于 0');
    }
    if(Platform.isWindows||Platform.isLinux){
      try{
        final ui.Image chunkImage = await toImage(pixelRatio: pixelRatio);
        ByteData? byteData =
        await chunkImage.toByteData(format: ui.ImageByteFormat.rawRgba);
        Uint8List imageBytes = byteData!.buffer.asUint8List();
        convertRgbaToJpeg(imageBytes,convSize.width.ceil(),convSize.height.ceil(),100,outPath);
        chunkImage.dispose();
        callback?.call(true,'保存成功');
      } catch (e){
        callback?.call(false,'保存图片失败');
      }
      return;
    }
    final List<Rect> chunksRect = [];
    final double totalHeight = convSize.height;
    double dy = 0;
    while (dy < totalHeight) {
      final double currentChunkHeight =
      (dy + chunkHeight <= totalHeight)
          ? chunkHeight
          : totalHeight - dy;
      chunksRect.add(Rect.fromLTWH(0, dy,
          convSize.width,
          currentChunkHeight));
      dy += chunkHeight;
    }
    ffi.Pointer<ffi.Int64>? widgetToImageContext = await _createWidgetToImage(outPath: outPath,
        width: outSize.width.ceil(),
        height: outSize.height.ceil(), format: format.index);
    if (widgetToImageContext == null||widgetToImageContext.address==0) {
      callback?.call(false,'创建图片失败');
      return;
    }
    int curChunkIndex = 0;
    void writeImageBytes() async {
      var chunkRect = chunksRect[curChunkIndex];
      final ui.Image chunkImage;
      try {
        chunkImage = await toImageChunks(convSize: convSize,chunkRect: chunkRect, pixelRatio: pixelRatio);
      } catch (e) {
        callback?.call(false,e.toString());
        return;
      }
      ByteData? byteData =
      await chunkImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      Uint8List imageBytes = byteData!.buffer.asUint8List();
      final int rows = chunkImage.height;
      final int srcStride =
          byteData.lengthInBytes ~/ rows;
      final bytePtr = generateUint8ListPointer(imageBytes);
      ffi.Pointer<ffi.Uint8> memPtr = await _loadBytesToMemory(bytePtr, imageBytes.length);
      executeWriteImage(WriteImageComputeParams(
        ctxPointer: widgetToImageContext,
        chunkPointer: memPtr,
        srcStride: srcStride,
        rows: rows,
      )).then((value) async {
        byteData = null;
        chunkImage.dispose();
        if(value!=0&&value!=1){
          callback?.call(false,'写入图片失败');
          return;
        }
        if((curChunkIndex < chunksRect.length-1)&&value!=1){
          curChunkIndex++;
          writeImageBytes();
        } else {
          int result = await _saveWidgetToImage(widgetToImageContext);
          if (result != 0) {
            callback?.call(false,'保存图片失败');
          } else {
            callback?.call(true,'保存成功');
          }
        }
      });
    }
    try {
      writeImageBytes();
    } catch (e) {
      callback?.call(false,'保存图片失败:$e');
    }
  }

  Future<ui.Image> toImageChunks({required Size convSize, required Rect chunkRect, double pixelRatio = 1.0}) {
    if (chunkRect.left < 0 || chunkRect.top < 0) {
      throw ArgumentError.value(chunkRect.topLeft, 'chunkOffset', '不能小于Offset.zero');
    }

    if (chunkRect.left >= convSize.width || chunkRect.top >= convSize.height) {
      throw ArgumentError.value(chunkRect.topLeft, 'chunkOffset', '不能大于等于size');
    }

    if (chunkRect.width <= 0 || chunkRect.height <= 0) {
      throw ArgumentError.value(chunkRect, 'chunkSize', '宽度和高度必须大于0');
    }

    if (chunkRect.width > convSize.width || chunkRect.height > convSize.height) {
      throw ArgumentError.value(chunkRect, 'chunkSize', '宽度和高度必须小于等于size');
    }

    final OffsetLayer offsetLayer = layer! as OffsetLayer;
    return offsetLayer.toImage(chunkRect, pixelRatio: pixelRatio);
  }

  static Future<int> executeWriteImage(WriteImageComputeParams params) async {
    return await compute(
      executeWriteImageIsolate,
      params,
    );
  }
}

int executeWriteImageIsolate(WriteImageComputeParams params) {
  try {
    int result = _writeWidgetToImage(params);
    return result;
  } finally {
  }
}

ffi.Pointer<ffi.Uint8> generateUint8ListPointer(Uint8List types) {
  final blob = calloc<ffi.Uint8>(types.length);
  final blobBytes = blob.asTypedList(types.length);
  blobBytes.setAll(0, types);
  return blob;
}

/// 创建图像缓冲区
///
/// [path] 图像文件保存的路径
/// [width] 图像的宽度
/// [height] 图像的高度
/// [format] 图像格式 0:png 1:jpeg
Future<ffi.Pointer<ffi.Int64>?> _createWidgetToImage({
  required String outPath,
  required int width,
  required int height,
  required int format,
}) async {
  final cPath = outPath.toNativeUtf8();
  ffi.Pointer<ffi.Int64>? result;
  try {
    result = _bindings.create_chunked_widget_to_image(
      cPath.cast<ffi.Char>(),
      width,
      height,
      format,
    );
  } finally {
    calloc.free(cPath);
  }
  return result;
}

/// 写入图像数据
///
/// [params] 写入参数
int _writeWidgetToImage(WriteImageComputeParams params){
  int result;
  try {
    result = _bindings.write_chunked_widget_to_image(
      params.ctxPointer,
      params.chunkPointer,
      params.srcStride,
      params.rows,
    );
  } catch (e) {
    result = -1;
  }
  return result;
}

/// 保存图像数据
Future<int> _saveWidgetToImage(ffi.Pointer<ffi.Int64> ctx) async {
  int result;
  try {
    result = _bindings.save_chunked_widget_to_image(ctx);
  } catch (e) {
    result = -1;
  }
  return result;
}

/// 将字节数据加载到内存并返回指针
Future<ffi.Pointer<ffi.Uint8>> _loadBytesToMemory(ffi.Pointer<ffi.Uint8> bytes,int size) async {
  try {
    return _bindings.load_bytes_to_memory(bytes, size);
  } finally {
    calloc.free(bytes);
  }
}

const String _libName = 'chunked_widget_to_image';

/// The dynamic library in which the symbols for [WidgetToImageBindings] can be found.
final ffi.DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return ffi.DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return ffi.DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return ffi.DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final WidgetToImageBindings _bindings = WidgetToImageBindings(_dylib);

class WriteImageComputeParams {
  /// 创建图像缓冲区指针
  final ffi.Pointer<ffi.Int64> ctxPointer;
  /// 分块图像字节指针
  final ffi.Pointer<ffi.Uint8> chunkPointer;
  /// 分块图像的宽度
  final int srcStride;
  /// 分块图像的高度
  final int rows;
  WriteImageComputeParams({required this.ctxPointer,required this.chunkPointer
    ,required this.srcStride,required this.rows});
}
