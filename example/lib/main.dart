import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_logs/flutter_logs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setUpLogsIfPermissionsGranted();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Logs'),
        ),
        body: Center(
          child: RaisedButton(
            onPressed: () async {
              setUpLogs();
            },
            child: Text('Setup Logs', style: TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }

  void setUpLogsIfPermissionsGranted() async {
    if (Platform.isAndroid) {
      FlutterLogs.channel.setMethodCallHandler((call) async {
        if (call.method == 'storagePermissionsGranted') {
          print("setUpLogsIfPermissionsGranted: storagePermissionsGranted");
          setUpLogs();
        }
      });
    }
  }

  void setUpLogs() async {
    try {
      print("setUpLogs: Setting up logs..");
      await FlutterLogs.initLogs(
          savePath: "MyLogs", debugFileOperations: true, isDebuggable: true);
    } on PlatformException {
      print("initState: PlatformException");
    }
  }
}
