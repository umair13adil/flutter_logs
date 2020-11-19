import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var TAG = "MyApp";
  var _my_log_file_name = "MyLogFile";
  var toggle = false;
  static Completer _completer = new Completer<String>();

  @override
  void initState() {
    super.initState();
    setUpLogs();
  }

  void setUpLogs() async {
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

    // [IMPORTANT] The first log line must never be called before 'FlutterLogs.initLogs'
    FlutterLogs.logInfo(TAG, "setUpLogs", "setUpLogs: Setting up logs..");

    // Logs Exported Callback
    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        // Contains file name of zip
        FlutterLogs.logInfo(
            TAG, "setUpLogs", "logsExported: ${call.arguments.toString()}");

        // Notify Future with value
        _completer.complete(call.arguments.toString());
      } else if (call.method == 'logsPrinted') {
        FlutterLogs.logInfo(
            TAG, "setUpLogs", "logsPrinted: ${call.arguments.toString()}");
      }
    });
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
                  logData(isException: false);
                },
                child: Text('Log Something', style: TextStyle(fontSize: 20)),
              ),
              RaisedButton(
                onPressed: () async {
                  logData(isException: true);
                },
                child: Text('Log Exception', style: TextStyle(fontSize: 20)),
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
                  // Export and then get File Reference
                  await exportAllLogs().then((value) async {

                    Directory externalDirectory;

                    if (Platform.isIOS) {
                      externalDirectory = await getApplicationDocumentsDirectory();
                    } else {
                      externalDirectory = await getExternalStorageDirectory();
                    }

                    FlutterLogs.logInfo(TAG, "found", 'External Storage:$externalDirectory');

                    File file = File("${externalDirectory.path}/$value");

                    FlutterLogs.logInfo(
                        TAG, "path", 'Path: \n${file.path.toString()}');

                    if (file.existsSync()) {
                      FlutterLogs.logInfo(
                          TAG, "existsSync", 'Logs found and ready to export!');
                    } else {
                      FlutterLogs.logError(
                          TAG, "existsSync", "File not found in storage.");
                    }
                  });
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
              ),
              RaisedButton(
                onPressed: () async {
                  FlutterLogs.clearLogs();
                },
                child: Text('Clear Logs', style: TextStyle(fontSize: 20)),
              )
            ],
          ),
        ),
      ),
    );
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
      organizationUnitId: "5767",
      userId: "883023-2832-2323",
      userName: "umair13adil",
      userEmail: "m.umair.adil@gmail.com",
      deviceSerial: "YJBKKSNKDNK676",
      deviceBrand: "LG",
      deviceName: "LG-Y08",
      deviceManufacturer: "LG",
      deviceModel: "989892BBN",
      deviceSdkInt: "26",
      deviceBatteryPercent: "27",
      latitude: "55.0",
      longitude: "-76.0",
      labels: "",
    );
  }

  void doSetupForMQTT() async {
    await FlutterLogs.initMQTT(
        topic: "",
        brokerUrl: "",
        //Add URL without schema
        certificate: "assets/m2mqtt_ca.crt",
        port: "8883",
        writeLogsToLocalStorage: true,
        debug: true,
        initialDelaySecondsForPublishing: 10);
  }

  void logData({bool isException}) {
    if (!isException) {
      FlutterLogs.logThis(
          tag: TAG,
          subTag: 'logData',
          logMessage:
              'This is a log message: ${DateTime.now().millisecondsSinceEpoch}',
          level: LogLevel.INFO);
    } else {
      try {
        if (toggle) {
          toggle = false;
          var i = 100 ~/ 0;
          print("$i");
        } else {
          toggle = true;
          var i = null;
          print(i * 10);
        }
      } catch (e) {
        if (e is Error) {
          FlutterLogs.logThis(
              tag: TAG,
              subTag: 'Caught an error.',
              logMessage: 'Caught an exception!',
              error: e,
              level: LogLevel.ERROR);
        } else {
          FlutterLogs.logThis(
              tag: TAG,
              subTag: 'Caught an exception.',
              logMessage: 'Caught an exception!',
              exception: e,
              level: LogLevel.ERROR);
        }
      }
    }
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

  Future<String> exportAllLogs() async {
    FlutterLogs.exportLogs(exportType: ExportType.ALL);
    return _completer.future;
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
