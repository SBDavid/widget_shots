library widget_shots;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

class ScreenshotController {
  GlobalKey _containerKey;
  ScreenshotController() {
    _containerKey = GlobalKey();
  }

  Future<Uint8List> capture({
    double pixelRatio: 1,
  }) async {
    RenderRepaintBoundary boundary =
    this._containerKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }
}

class WidgetShots<T> extends StatefulWidget {
  final Widget child;
  final ScreenshotController controller;
  const WidgetShots({Key key, this.child, this.controller,})
      : super(key: key);
  @override
  State<WidgetShots> createState() {
    return new _State();
  }
}

class _State extends State<WidgetShots> {
  ScreenshotController _controller;
  GlobalKey _globalKey;

  @override
  void initState() {
    super.initState();

    _globalKey = GlobalKey(debugLabel: "WidgetShots");

    if (widget.controller == null) {
      _controller = ScreenshotController();
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