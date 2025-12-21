import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import '../chunked_widget_to_image.dart';

class WidgetToImageController {
  late GlobalKey _containerKey;

  WidgetToImageController() {
    _containerKey = GlobalKey();
  }

  /// 将widget保存为图片
  ///
  /// [outPath] 图像保存的路径
  /// [chunkHeight] 分块大小
  /// [pixelRatio] 缩放比例
  /// [format] 图像格式
  /// [callback] 保存回调
  void toImageFile({
    required String outPath,
    double? chunkHeight,
    double pixelRatio = 1.0,
    ImageFormat format = ImageFormat.png,
    void Function(bool result, String message)? callback,
    Duration delay = const Duration(milliseconds: 20),
  }) {
    Future.delayed(delay, () async {
      try {
        var findRenderObject = _containerKey.currentContext?.findRenderObject();
        if (findRenderObject == null) {
          return null;
        }
        RenderRepaintBoundary boundary =
            findRenderObject as RenderRepaintBoundary;
        boundary.toImageByChunks(
          outPath: outPath,
          pixelRatio: 1,
          format: format,
          callback: callback,
        );
      } catch (e) {
        rethrow;
      }
    });
  }

  /// 将不在小部件树widget保存为图片
  ///
  /// [outPath] 图像保存的路径
  /// [chunkHeight] 分块大小
  /// [pixelRatio] 缩放比例
  /// [format] 图像格式
  /// [callback] 保存回调
  /// [targetSize] 目标大小,要尽量大于等于要widget的size
  void toImageFileFromWidget(
    Widget widget, {
    required String outPath,
    double? chunkHeight,
    double pixelRatio = 1.0,
    ImageFormat format = ImageFormat.png,
    void Function(bool result, String message)? callback,
    Duration delay = const Duration(seconds: 1),
    BuildContext? context,
    Size? targetSize,
  }) async {
    ///
    ///Retry counter
    ///
    int retryCounter = 3;
    bool isDirty = false;

    Widget child = widget;

    if (context != null) {
      ///
      ///Inherit Theme and MediaQuery of app
      ///
      ///
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
          data: MediaQuery.of(context),
          child: Material(color: Colors.transparent, child: child),
        ),
      );
    }

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final fallBackView = platformDispatcher.views.first;
    final view = context == null
        ? fallBackView
        : View.maybeOf(context) ?? fallBackView;
    Size logicalSize =
        targetSize ?? view.physicalSize / view.devicePixelRatio; // Adapted
    Size imageSize = targetSize ?? view.physicalSize; // Adapted

    assert(
      logicalSize.aspectRatio.toStringAsPrecision(5) ==
          imageSize.aspectRatio.toStringAsPrecision(5),
    ); // Adapted (toPrecision was not available)

    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        // size: logicalSize,
        logicalConstraints: BoxConstraints(
          maxWidth: logicalSize.width,
          maxHeight: logicalSize.height,
        ),
        devicePixelRatio: pixelRatio,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(
      focusManager: FocusManager(),
      onBuildScheduled: () {
        ///
        ///current render is dirty, mark it.
        ///
        isDirty = true;
      },
    );

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
          container: repaintBoundary,
          child: Directionality(textDirection: TextDirection.ltr, child: child),
        ).attachToRenderTree(buildOwner);
    ////
    ///Render Widget
    ///
    ///

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    do {
      ///
      ///Reset the dirty flag
      ///
      ///
      isDirty = false;

      Size convSize = repaintBoundary.size;
      try {
        ui.Image image = await repaintBoundary.toImageChunks(
          convSize: convSize,
          chunkRect: Rect.fromLTWH(
            0,
            convSize.height * 0.95,
            convSize.width,
            convSize.height,
          ),
        );
        image.dispose();
      } catch (e) {}

      ///
      ///This delay sholud increas with Widget tree Size
      ///

      await Future.delayed(delay);

      ///
      ///Check does this require rebuild
      ///
      ///
      if (isDirty) {
        ///
        ///Previous capture has been updated, re-render again.
        ///
        ///
        buildOwner.buildScope(rootElement);
        buildOwner.finalizeTree();
        pipelineOwner.flushLayout();
        pipelineOwner.flushCompositingBits();
        pipelineOwner.flushPaint();
      }
      retryCounter--;

      ///
      ///retry untill capture is successfull
      ///
    } while (isDirty && retryCounter >= 0);
    try {
      /// Dispose All widgets
      // rootElement.visitChildren((Element element) {
      //   rootElement.deactivateChild(element);
      // });
      buildOwner.finalizeTree();
    } catch (e) {
      rethrow;
    }
    repaintBoundary.toImageByChunks(
      outPath: outPath,
      pixelRatio: pixelRatio,
      format: format,
      callback: callback,
    );
  }

  /// 将不在小部件树长widget保存为图片
  ///
  /// [outPath] 图像保存的路径
  /// [chunkHeight] 分块大小
  /// [pixelRatio] 缩放比例
  /// [format] 图像格式
  /// [callback] 保存回调
  void toImageFileFromLongWidget(
    Widget widget, {
    required String outPath,
    double? chunkHeight,
    double pixelRatio = 1.0,
    ImageFormat format = ImageFormat.png,
    void Function(bool result, String message)? callback,
    Duration delay = const Duration(seconds: 1),
    BuildContext? context,
    BoxConstraints constraints = const BoxConstraints(
      maxHeight: double.maxFinite,
    ),
  }){
    final PipelineOwner pipelineOwner = PipelineOwner();
    final _MeasurementView rootView = pipelineOwner.rootNode = _MeasurementView(
      constraints,
    );
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    final RenderObjectToWidgetElement<RenderBox> element =
        RenderObjectToWidgetAdapter<RenderBox>(
          container: rootView,
          debugShortDescription: 'root_render_element_for_size_measurement',
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ).attachToRenderTree(buildOwner);
    try {
      rootView.scheduleInitialLayout();
      pipelineOwner.flushLayout();

      ///
      /// Calculate Size, and capture widget.
      ///

      toImageFileFromWidget(
        widget,
        outPath: outPath,
        pixelRatio: pixelRatio,
        format: format,
        callback: callback,
        targetSize: rootView.size,
        context: context,
        delay: delay,
      );
    } finally {
      // Clean up.
      element.update(
        RenderObjectToWidgetAdapter<RenderBox>(container: rootView),
      );
      buildOwner.finalizeTree();
    }
  }
}

class WidgetToImage extends StatelessWidget {
  final Widget? child;
  final WidgetToImageController controller;

  const WidgetToImage({super.key, required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: controller._containerKey, child: child);
  }
}

///
/// RenderBox widget to calculate size.
///
class _MeasurementView extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  final BoxConstraints boxConstraints;

  _MeasurementView(this.boxConstraints);

  @override
  void performLayout() {
    assert(child != null);
    child!.layout(boxConstraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  void debugAssertDoesMeetConstraints() => true;
}
