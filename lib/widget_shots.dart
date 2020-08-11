library widget_shots;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart';
import 'dart:io';
import 'dart:isolate';

class WidgetShotsController {
  GlobalKey _containerKey;
  WidgetShotsController() {
    _containerKey = GlobalKey();
  }

  static Uint8List png2jpg(ByteData png) {
    var imageInt = decodeImage(png.buffer.asUint8List());
    return Uint8List.fromList(encodeJpg(imageInt));
  }

  static TransferableTypedData png2jpgLargePixelRatio(TransferableTypedData png) {
    var imageInt = decodeImage(png.materialize().asUint8List());
    return TransferableTypedData.fromList([Uint8List.fromList(encodeJpg(imageInt))]);
  }

  Future<Uint8List> capture({
    double pixelRatio: 1,
  }) async {
    RenderRepaintBoundary boundary =
    this._containerKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData.lengthInBytes > 100 * 1024 * 1024) {
      TransferableTypedData transferableTypedData = TransferableTypedData.fromList([byteData]);
      TransferableTypedData res = await compute<TransferableTypedData, TransferableTypedData>(WidgetShotsController.png2jpgLargePixelRatio, transferableTypedData);
      return res.materialize().asUint8List();
    } else {
      return compute<ByteData, Uint8List>(WidgetShotsController.png2jpg, byteData);
    }
  }

  Future<File> captureFile({
    String path,
    double pixelRatio: 1,
  }) async {
    assert(path != null);

    Uint8List png = await capture(pixelRatio: pixelRatio);
    String fileName = DateTime.now().toIso8601String();
    path = '$path/$fileName.jpg';

    File imgFile = new File(path);
    await imgFile.writeAsBytes(png).then((onValue) {});
    return imgFile;
  }
}

class WidgetShots<T> extends StatefulWidget {
  final Widget child;
  final WidgetShotsController controller;
  const WidgetShots({Key key, this.child, this.controller,})
      : super(key: key);
  @override
  State<WidgetShots> createState() {
    return new _State();
  }
}

class _State extends State<WidgetShots> {
  WidgetShotsController _controller;
  GlobalKey _globalKey;

  @override
  void initState() {
    super.initState();

    _globalKey = GlobalKey(debugLabel: "WidgetShots");

    if (widget.controller == null) {
      _controller = WidgetShotsController();
    } else {
      _controller = widget.controller;
    }

    _controller._containerKey = _globalKey;
  }

  @override
  void didUpdateWidget(WidgetShots oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      widget.controller._containerKey = _globalKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: widget.child,
    );
  }
}