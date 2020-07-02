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
  var _my_log_file_name = "MyLogFile";

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  setUpLogs();
                  doSetupForELKSchema();
                  doSetupForMQTT();
                },
                child: Text('Setup Logs', style: TextStyle(fontSize: 20)),
              ),
              RaisedButton(
                onPressed: () async {
                  logData();
                },
                child: Text('Log Something', style: TextStyle(fontSize: 20)),
              ),
              RaisedButton(
                onPressed: () async {
                  logToFile();
                },
                child: Text('Log To File', style: TextStyle(fontSize: 20)),
              ),
              RaisedButton(
                onPressed: () async {
                  printAllLogs();
                },
                child: Text('Print All Logs', style: TextStyle(fontSize: 20)),
              ),
              RaisedButton(
                onPressed: () async {
                  exportAllLogs();
                },
                child: Text('Export All Logs', style: TextStyle(fontSize: 20)),
              ),
              RaisedButton(
                onPressed: () async {
                  printFileLogs();
                },
                child: Text('Print File Logs', style: TextStyle(fontSize: 20)),
              ),
              RaisedButton(
                onPressed: () async {
                  exportFileLogs();
                },
                child: Text('Export File Logs', style: TextStyle(fontSize: 20)),
              )
            ],
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
          doSetupForELKSchema();
          doSetupForMQTT();
        } else if (call.method == 'logsExported') {
          print("logsExported: ${call.arguments.toString()}");
        }
      });
    }
  }

  void setUpLogs() async {
    print("setUpLogs: Setting up logs..");
    await FlutterLogs.initLogs(
        logLevelsEnabled: [
          LogLevel.INFO,
          LogLevel.WARNING,
          LogLevel.ERROR,
          LogLevel.SEVERE
        ],
        timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
        directoryStructure: DirectoryStructure.FOR_DATE,
        logTypesEnabled: [_my_log_file_name],
        logFileExtension: LogFileExtension.LOG,
        logsWriteDirectoryName: "MyLogs",
        logsExportDirectoryName: "MyLogs/Exported",
        debugFileOperations: true,
        isDebuggable: true);
  }

  void doSetupForELKSchema() async {
    await FlutterLogs.setMetaInfo(
      appId: "flutter_logs_example",
      appName: "Flutter Logs Demo",
      appVersion: "1.0",
      language: "en-US",
      deviceId: "00012",
      environmentId: "7865",
      environmentName: "dev",
      organizationId: "5767",
      userId: "883023-2832-2323",
      userName: "umair13adil",
      userEmail: "m.umair.adil@gmail.com",
      deviceSerial: "YJBKKSNKDNK676",
      deviceBrand: "LG",
      deviceName: "LG-Y08",
      deviceManufacturer: "LG",
      deviceModel: "989892BBN",
      deviceSdkInt: "26",
      latitude: "0.0",
      longitude: "0.0",
      labels: "",
    );
  }

  void doSetupForMQTT() async {
    await FlutterLogs.initMQTT(
        topic: "YOUR_TOPIC",
        brokerUrl: "", //Add URL without schema
        certificate: "m2mqtt_ca.crt",
        port: "8883");
  }

  void logData() {
    FlutterLogs.logThis(
        tag: 'MyApp',
        subTag: 'logData',
        logMessage:
            'This is a log message: ${DateTime.now().millisecondsSinceEpoch}',
        level: LogLevel.INFO);
  }

  void logToFile() {
    FlutterLogs.logToFile(
        logFileName: _my_log_file_name,
        overwrite: false,
        //If set 'true' logger will append instead of overwriting
        logMessage:
            "This is a log message: ${DateTime.now().millisecondsSinceEpoch}, it will be saved to my log file named: \'$_my_log_file_name\'",
        appendTimeStamp: true); //Add time stamp at the end of log message
  }

  void printAllLogs() {
    FlutterLogs.printLogs(
        exportType: ExportType.ALL, decryptBeforeExporting: true);
  }

  void exportAllLogs() {
    FlutterLogs.exportLogs(
        exportType: ExportType.ALL, decryptBeforeExporting: true);
  }

  void exportFileLogs() {
    FlutterLogs.exportFileLogForName(
        logFileName: _my_log_file_name, decryptBeforeExporting: true);
  }

  void printFileLogs() {
    FlutterLogs.printFileLogForName(
        logFileName: _my_log_file_name, decryptBeforeExporting: true);
  }
}
