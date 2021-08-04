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
  var _tag = "MyApp";
  var _myLogFileName = "MyLogFile";
  var toggle = false;
  var logStatus = '';
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
        logTypesEnabled: [_myLogFileName],
        logFileExtension: LogFileExtension.LOG,
        logsWriteDirectoryName: "MyLogs",
        logsExportDirectoryName: "MyLogs/Exported",
        debugFileOperations: true,
        isDebuggable: true);

    // [IMPORTANT] The first log line must never be called before 'FlutterLogs.initLogs'
    FlutterLogs.logInfo(_tag, "setUpLogs", "setUpLogs: Setting up logs..");

    // Logs Exported Callback
    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        // Contains file name of zip
        FlutterLogs.logInfo(
            _tag, "setUpLogs", "logsExported: ${call.arguments.toString()}");

        setLogsStatus(
            status: "logsExported: ${call.arguments.toString()}", append: true);

        // Notify Future with value
        _completer.complete(call.arguments.toString());
      } else if (call.method == 'logsPrinted') {
        FlutterLogs.logInfo(
            _tag, "setUpLogs", "logsPrinted: ${call.arguments.toString()}");

        setLogsStatus(
            status: "logsPrinted: ${call.arguments.toString()}", append: true);
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                    child: Text(
                  logStatus,
                  maxLines: 10,
                )),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    logData(isException: false);
                  },
                  child: Text('Log Something', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    logData(isException: true);
                  },
                  child: Text('Log Exception', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    logToFile();
                  },
                  child: Text('Log To File', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    printAllLogs();
                  },
                  child: Text('Print All Logs', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Export and then get File Reference
                    await exportAllLogs().then((value) async {
                      Directory? externalDirectory;

                      if (Platform.isIOS) {
                        externalDirectory =
                            await getApplicationDocumentsDirectory();
                      } else {
                        externalDirectory = await getExternalStorageDirectory();
                      }

                      FlutterLogs.logInfo(
                          _tag, "found", 'External Storage:$externalDirectory');

                      File file = File("${externalDirectory!.path}/$value");

                      FlutterLogs.logInfo(
                          _tag, "path", 'Path: \n${file.path.toString()}');

                      if (file.existsSync()) {
                        FlutterLogs.logInfo(_tag, "existsSync",
                            'Logs found and ready to export!');
                      } else {
                        FlutterLogs.logError(
                            _tag, "existsSync", "File not found in storage.");
                      }

                      setLogsStatus(
                          status:
                              "All logs exported to: \n\nPath: ${file.path.toString()}");
                    });
                  },
                  child:
                      Text('Export All Logs', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    printFileLogs();
                  },
                  child:
                      Text('Print File Logs', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    exportFileLogs();
                  },
                  child:
                      Text('Export File Logs', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FlutterLogs.clearLogs();
                    setLogsStatus(status: "");
                  },
                  child: Text('Clear Logs', style: TextStyle(fontSize: 20)),
                )
              ],
            ),
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

  void logData({required bool isException}) {
    var logMessage =
        'This is a log message: ${DateTime.now().millisecondsSinceEpoch}';

    if (!isException) {
      FlutterLogs.logThis(
          tag: _tag,
          subTag: 'logData',
          logMessage: logMessage,
          level: LogLevel.INFO);
    } else {
      try {
        if (toggle) {
          toggle = false;
          var i = 100 ~/ 0;
          print("$i");
        } else {
          toggle = true;
          dynamic i;
          print(i * 10);
        }
      } catch (e) {
        if (e is Error) {
          FlutterLogs.logThis(
              tag: _tag,
              subTag: 'Caught an error.',
              logMessage: 'Caught an exception!',
              error: e,
              level: LogLevel.ERROR);
          logMessage = e.stackTrace.toString();
        } else if (e is Exception) {
          FlutterLogs.logThis(
              tag: _tag,
              subTag: 'Caught an exception.',
              logMessage: 'Caught an exception!',
              exception: e,
              level: LogLevel.ERROR);
          logMessage = e.toString();
        }
      }
    }
    setLogsStatus(status: logMessage);
  }

  void logToFile() {
    var logMessage =
        "This is a log message: ${DateTime.now().millisecondsSinceEpoch}, it will be saved to my log file named: \'$_myLogFileName\'";
    FlutterLogs.logToFile(
        logFileName: _myLogFileName,
        overwrite: false,
        //If set 'true' logger will append instead of overwriting
        logMessage: logMessage,
        appendTimeStamp: true); //Add time stamp at the end of log message
    setLogsStatus(status: logMessage);
  }

  void printAllLogs() {
    FlutterLogs.printLogs(
        exportType: ExportType.ALL, decryptBeforeExporting: true);
    setLogsStatus(status: "All logs printed");
  }

  Future<String> exportAllLogs() async {
    FlutterLogs.exportLogs(exportType: ExportType.ALL);
    return _completer.future as FutureOr<String>;
  }

  void exportFileLogs() {
    FlutterLogs.exportFileLogForName(
        logFileName: _myLogFileName, decryptBeforeExporting: true);
  }

  void printFileLogs() {
    FlutterLogs.printFileLogForName(
        logFileName: _myLogFileName, decryptBeforeExporting: true);
  }

  void setLogsStatus({String status = '', bool append = false}) {
    setState(() {
      logStatus = status;
    });
  }
}
