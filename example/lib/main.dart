import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chunked_widget_to_image/chunked_widget_to_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // here
      navigatorObservers: [FlutterSmartDialog.observer],
      // here
      builder: FlutterSmartDialog.init(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WidgetToImageController widgetToImageController = WidgetToImageController();
  double width = 9999;
  final TextEditingController _widthController = TextEditingController();
  FocusNode textFieldFocusNode = FocusNode();
  String? exportedFilePath;

  @override
  void initState() {
    super.initState();
    _widthController.text = width.toString();

    // 添加焦点监听器
    textFieldFocusNode.addListener(() {
      if (!textFieldFocusNode.hasFocus) {
        setState(() {
          width = double.tryParse(_widthController.text) ?? width;
          width = width.clamp(2048, 16384);
          _widthController.text = width.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    _widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击屏幕任意位置收起键盘
        textFieldFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Widget to Image example')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                focusNode: textFieldFocusNode,
                controller: _widthController,
                decoration: const InputDecoration(
                  labelText: '图片宽度',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
            ),
            Expanded(
              child: FittedBox(
                child: WidgetToImage(
                  controller: widgetToImageController,
                  child: Image.asset(
                    'assets/test_img.jpg',
                    width: width,
                    fit: BoxFit.fitWidth,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (frame == null) {
                            return const SizedBox(
                              width: 400,
                              height: 400,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return child;
                        },
                  ),
                ),
              ),
            ),
            if (exportedFilePath != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  '导出路径: $exportedFilePath',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _exportImage(ImageFormat.png),
                    child: const Text('导出 PNG'),
                  ),
                  ElevatedButton(
                    onPressed: () => _exportImage(ImageFormat.jpg),
                    child: const Text('导出 JPEG'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _exportImageOffScreen(ImageFormat.png),
                    child: const Text('离屏 PNG'),
                  ),
                  ElevatedButton(
                    onPressed: () => _exportImageOffScreen(ImageFormat.jpg),
                    child: const Text('离屏 JPEG'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _exportLongImageOffScreen(ImageFormat.png),
                    child: const Text('离屏长图PNG'),
                  ),
                  ElevatedButton(
                    onPressed: () => _exportLongImageOffScreen(ImageFormat.jpg),
                    child: const Text('离屏长图JPEG'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 导出图片
  Future<void> _exportImage(ImageFormat format) async {
    // 记录开始时间
    final startTime = DateTime.now();
    // 获取临时目录
    Directory tempDir = await getTemporaryDirectory();
    if (Platform.isAndroid) {
      tempDir = (await getExternalStorageDirectory())!;
    } else {
      tempDir = await getTemporaryDirectory();
    }
    String path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.${format.name}';
    print('输出路径：$path');
    SmartDialog.showLoading(msg: '正在导出');
    widgetToImageController.toImageFile(
      outPath: path,
      pixelRatio: 1,
      format: format,
      callback: (result, message) {
        // 计算耗时
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        SmartDialog.dismiss();
        if (result) {
          setState(() {
            exportedFilePath = path;
          });
          if (width > 10000) {
            SmartDialog.showToast(
              '导出成功，低端机上不能显示太大图',
              alignment: Alignment.center,
            );
            return;
          }
          _showFullScreenPreview(path, duration);
        } else {
          setState(() {
            exportedFilePath = null;
          });
          SmartDialog.showToast(message, alignment: Alignment.center);
        }
      },
    );
  }

  /// 离屏导出图片
  Future<void> _exportImageOffScreen(ImageFormat format) async {
    // 记录开始时间
    final startTime = DateTime.now();
    // 获取临时目录
    Directory tempDir = await getTemporaryDirectory();
    if (Platform.isAndroid) {
      tempDir = (await getExternalStorageDirectory())!;
    } else {
      tempDir = await getTemporaryDirectory();
    }
    String path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.${format.name}';
    print('输出路径：$path');
    SmartDialog.showLoading(msg: '正在导出');
    widgetToImageController.toImageFileFromWidget(
      Image.asset('assets/test_img.jpg', width: width, fit: BoxFit.fitWidth),
      outPath: path,
      pixelRatio: 1,
      format: format,
      targetSize: Size(width, width),
      delay: Duration(seconds: 2),
      callback: (result, message) {
        // 计算耗时
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        SmartDialog.dismiss();
        if (result) {
          setState(() {
            exportedFilePath = path;
          });
          if (width > 10000) {
            SmartDialog.showToast(
              '导出成功，低端机上不能显示太大图',
              alignment: Alignment.center,
            );
            return;
          }
          _showFullScreenPreview(path, duration);
        } else {
          setState(() {
            exportedFilePath = null;
          });
          SmartDialog.showToast(message, alignment: Alignment.center);
        }
      },
    );
  }

  /// 离屏长图导出图片
  Future<void> _exportLongImageOffScreen(ImageFormat format) async {
    var randomItemCount = 200;
    var myLongWidget = Builder(builder: (context) {
      return Container(
          padding: const EdgeInsets.all(30.0),
          decoration: BoxDecoration(
            border:
            Border.all(color: Colors.blueAccent, width: 5.0),
            color: Colors.redAccent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < randomItemCount; i++)
                Text("Tile Index $i",style: TextStyle(fontSize: 60.0),),
            ],
          ));
    });
    // 记录开始时间
    final startTime = DateTime.now();
    // 获取临时目录
    Directory tempDir = await getTemporaryDirectory();
    if (Platform.isAndroid) {
      tempDir = (await getExternalStorageDirectory())!;
    } else {
      tempDir = await getTemporaryDirectory();
    }
    String path =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.${format.name}';
    print('输出路径：$path');
    SmartDialog.showLoading(msg: '正在导出');
    widgetToImageController
        .toImageFileFromLongWidget(
      Material(
        child: myLongWidget,
      ),
      outPath: path,
      pixelRatio: 1,
      format: format,
      delay: Duration(seconds: 1),
      context: context,
      callback: (result, message) {
        // 计算耗时
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        SmartDialog.dismiss();
        if (result) {
          setState(() {
            exportedFilePath = path;
          });
          if (width > 10000) {
            SmartDialog.showToast(
              '导出成功，低端机上不能显示太大图',
              alignment: Alignment.center,
            );
            return;
          }
          _showFullScreenPreview(path, duration);
        } else {
          setState(() {
            exportedFilePath = null;
          });
          SmartDialog.showToast(message, alignment: Alignment.center);
        }
      },
    );
  }

  /// 图片预览
  Future<void> _showFullScreenPreview(
    String imagePath,
    Duration duration,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black87,
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(alignment: Alignment.center,child: Image.file(File(imagePath))),
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.black54,
                      child: Text(
                        '耗时: ${duration.inMilliseconds} ms',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
