library widget_shots;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart';
import 'dart:io';

class WidgetShotsController {
  GlobalKey _containerKey;
  WidgetShotsController() {
    _containerKey = GlobalKey();
  }

  Future<Uint8List> capture({
    double pixelRatio: 1,
  }) async {
    RenderRepaintBoundary boundary =
    this._containerKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var imageInt = decodeImage(Int8List.sublistView(byteData));
    List<int> jpg = encodeJpg(imageInt);
    return Uint8List.fromList(jpg);
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