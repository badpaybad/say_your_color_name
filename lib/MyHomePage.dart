import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as DartImage;
import 'package:oktoast/oktoast.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Map<CameraDescription, CameraController?> _camCtlMap = {};
  CameraDescription? camera;

  @override
  void initState() {
    super.initState();
    init() async {
      final cameras = await availableCameras();
      for (var c in cameras) {
        print("camera ${c.name}");
        await _initCameraCtl(c);
        //back camera index=0
        break;
      }
    }

    init().then((value) async{
      if(mounted)setState(() {

      });
    });
  }

  bool _initDoneLocalCam = false;

  Future<void> _initCameraCtl(CameraDescription camera) async {
    var _controller = _camCtlMap[camera];

    _initDoneLocalCam = false;
    this.camera = camera;
    if (_controller == null) {
      _controller = CameraController(
        camera,
        ResolutionPreset.ultraHigh,
      );
      await _controller!.initialize();
      _camCtlMap[camera] = _controller;
    }

    _initDoneLocalCam = true;
  }

  DeviceOrientation _getApplicableOrientation() {
    var _controller = _camCtlMap[this.camera];

    print(_controller!.value.lockedCaptureOrientation);
    print(_controller!.value.previewPauseOrientation);
    return _controller!.value.isRecordingVideo
        ? _controller!.value.recordingOrientation!
        : (_controller!.value.previewPauseOrientation ??
            _controller!.value.lockedCaptureOrientation ??
            _controller!.value.deviceOrientation);
  }

  Widget _buildCamLocal() {
    var controller = _camCtlMap[this.camera];

    if (_initDoneLocalCam == false || controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    var vidOrient = _getApplicableOrientation();
    var orient = MediaQuery.of(context).orientation;

    if (vidOrient == DeviceOrientation.landscapeLeft &&
        this.camera!.sensorOrientation == 0) {
      // cause camera usb for rk3288
      Widget tempCam = controller!.buildPreview();

      tempCam = Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: tempCam);

      //var screenW = MediaQuery.of(context).size.width;
      var screenH = MediaQuery.of(context).size.height;
      var vidW = controller!.value.previewSize!.width;
      var vidH = controller!.value.previewSize!.height;
      var newVidH = screenH - 100; // vidH/2;
      var newVidW = newVidH * vidW / vidH;

      // print("orient ${orient.toString()} $vidOrient");
      // print("vidW $vidW vidH $vidH");
      // print("screenW $screenW screenH $screenH");
      // print("newVidW $newVidW newVidH $newVidH");

      return SizedBox(
        width: newVidW,
        height: newVidH,
        child: tempCam,
      );
    }

    Widget tempCam = CameraPreview(controller!);
    return tempCam;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 120,
              height: 120,
              child: _buildCamLocal(),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
