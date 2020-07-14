import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:typed_data';
import 'package:widget_shots/widget_shots.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  WidgetShotsController _controller;
  Uint8List _image;

  _capturePng() async {

    _image = await _controller.capture(pixelRatio: MediaQuery.of(context).devicePixelRatio);
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    _controller = WidgetShotsController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: WidgetShots(
                  controller: _controller,
                  child: Container(
                      alignment: Alignment.center,
                      color: Colors.blueAccent,
                      child: Image.network("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594385262181&di=9dc7d7bc9a60572cfee46a1bd33a825e&imgtype=0&src=http%3A%2F%2Ft8.baidu.com%2Fit%2Fu%3D3571592872%2C3353494284%26fm%3D79%26app%3D86%26f%3DJPEG%3Fw%3D1200%26h%3D1290")),
                ),
              ),
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    _capturePng();
                  },
                  child: Container(
                    child: _image == null ? Container(color: Colors.amber,) : Image.memory(
                      _image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            ],
          ),
        )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
