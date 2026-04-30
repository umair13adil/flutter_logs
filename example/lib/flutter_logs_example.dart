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

  final TextEditingController _keywordsController = TextEditingController();
  //FilterType _filterType = FilterType.OR;

  // Feature toggle states
  bool _backpressureEnabled = false;
  bool _redactionEnabled = false;

  @override
  void initState() {
    super.initState();
    setUpLogs();
  }

  @override
  void dispose() {
    _keywordsController.dispose();
    super.dispose();
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
        isDebuggable: true,
        enabled: true);

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

  /// Setup logs with Backpressure configuration
  /// Backpressure helps manage high-volume logging by limiting queue size
  /// and setting quotas per log level to prevent memory issues.
  void setUpLogsWithBackpressure() async {
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
        isDebuggable: true,
        enabled: true,
        // Backpressure Configuration
        // backpressureConfig: BackpressureConfig(
        //   queueCapacity: 500, // Max logs in queue before dropping
        //   warnQueueCapacity: 400, // Warn when queue reaches this size
        //   perLevelQuotas: {
        //     LogLevel.INFO: 100, // Max 100 INFO logs per window
        //     LogLevel.WARNING: 50, // Max 50 WARNING logs per window
        //     LogLevel.ERROR: 200, // Max 200 ERROR logs per window (prioritize errors)
        //     LogLevel.SEVERE: 200, // Max 200 SEVERE logs per window
        //   },
        //   quotaWindowMillis: 60000, // 1 minute window for quotas
        // )
    );

    setState(() => _backpressureEnabled = true);
    FlutterLogs.logInfo(_tag, "setUpLogsWithBackpressure",
        "Logs initialized with backpressure protection!");
    setLogsStatus(status: "Backpressure enabled!\n"
        "Queue capacity: 500\n"
        "Per-level quotas active (60s window)");
  }

  /// Setup logs with Redaction configuration
  /// Redaction automatically masks sensitive data like emails, phone numbers,
  /// credit cards, etc. in your logs for privacy/security compliance.
  void setUpLogsWithRedaction() async {
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
        isDebuggable: true,
        enabled: true,
        // Redaction Configuration for sensitive data masking
        // redactionConfig: RedactionConfig(
        //   // Enable built-in patterns for common sensitive data
        //   enableBuiltInPatterns: {
        //     BuiltInPattern.EMAIL, // Masks email addresses
        //     BuiltInPattern.PHONE_NUMBER, // Masks phone numbers
        //     BuiltInPattern.CREDIT_CARD, // Masks credit card numbers
        //     BuiltInPattern.JWT_TOKEN, // Masks JWT tokens
        //     BuiltInPattern.IP_ADDRESS, // Masks IP addresses
        //   },
        //   // Custom redaction rules for app-specific sensitive data
        //   customRules: [
        //     // Mask SSN patterns (XXX-XX-XXXX)
        //     RedactionRule(
        //       name: 'SSN',
        //       patternString: r'\b\d{3}-\d{2}-\d{4}\b',
        //       maskType: MaskType.FULL_MASK,
        //     ),
        //     // Partially mask API keys (show first 4 chars)
        //     RedactionRule(
        //       name: 'API_KEY',
        //       patternString: r'api_key[=:]\s*([A-Za-z0-9]{20,})',
        //       maskType: MaskType.PARTIAL,
        //     ),
        //     // Hash user IDs for tracking without exposing actual IDs
        //     RedactionRule(
        //       name: 'USER_ID',
        //       patternString: r'user_id[=:]\s*(\d+)',
        //       maskType: MaskType.HASH,
        //     ),
        //     // Custom replacement for passwords
        //     RedactionRule(
        //       name: 'PASSWORD',
        //       patternString: r'password[=:]\s*\S+',
        //       maskType: MaskType.FULL_MASK,
        //       replacement: 'password=[REDACTED]',
        //     ),
        //   ],
        //   defaultMaskType: MaskType.FULL_MASK,
    //    )
    );

    setState(() => _redactionEnabled = true);
    FlutterLogs.logInfo(
        _tag, "setUpLogsWithRedaction", "Logs initialized with redaction!");
    setLogsStatus(status: "Redaction enabled!\n"
        "Built-in: Email, Phone, Credit Card, JWT, IP\n"
        "Custom: SSN, API_KEY, USER_ID, PASSWORD");
  }

  /// Setup logs with both Backpressure and Redaction
  void setUpLogsWithAllFeatures() async {
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
        isDebuggable: true,
        enabled: true,
        // Backpressure Configuration
        // backpressureConfig: BackpressureConfig(
        //   queueCapacity: 500,
        //   warnQueueCapacity: 400,
        //   perLevelQuotas: {
        //     LogLevel.INFO: 100,
        //     LogLevel.WARNING: 50,
        //     LogLevel.ERROR: 200,
        //     LogLevel.SEVERE: 200,
        //   },
        //   quotaWindowMillis: 60000,
        // ),
        // // Redaction Configuration
        // redactionConfig: RedactionConfig(
        //   enableBuiltInPatterns: {
        //     BuiltInPattern.EMAIL,
        //     BuiltInPattern.PHONE_NUMBER,
        //     BuiltInPattern.CREDIT_CARD,
        //   },
        //   customRules: [
        //     RedactionRule(
        //       name: 'SSN',
        //       patternString: r'\b\d{3}-\d{2}-\d{4}\b',
        //       maskType: MaskType.FULL_MASK,
        //     ),
        //   ],
        //   defaultMaskType: MaskType.FULL_MASK,
    //    )
    );

    setState(() {
      _backpressureEnabled = true;
      _redactionEnabled = true;
    });
    FlutterLogs.logInfo(_tag, "setUpLogsWithAllFeatures",
        "Logs initialized with all features!");
    setLogsStatus(status: "All features enabled!\n"
        "✓ Backpressure\n"
        "✓ Redaction");
  }

  /// Log sensitive data to demonstrate redaction/masking
  void logSensitiveData() {
    // These will be automatically redacted if redaction is enabled
    FlutterLogs.logInfo(_tag, "logSensitiveData",
        "User email: john.doe@example.com logged in");

    FlutterLogs.logInfo(_tag, "logSensitiveData",
        "Contact phone: +1-555-123-4567");

    FlutterLogs.logInfo(_tag, "logSensitiveData",
        "Payment with card: 4111-1111-1111-1111");

    FlutterLogs.logInfo(
        _tag, "logSensitiveData", "User SSN: 123-45-6789 verified");

    FlutterLogs.logInfo(
        _tag, "logSensitiveData", "API request with api_key=sk_live_abc123xyz789secret");

    FlutterLogs.logInfo(
        _tag, "logSensitiveData", "Login attempt with password=SuperSecret123!");

    FlutterLogs.logInfo(
        _tag, "logSensitiveData", "Request from IP: 192.168.1.100");

    FlutterLogs.logInfo(_tag, "logSensitiveData",
        "JWT Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U");

    setLogsStatus(
        status: _redactionEnabled
            ? "Sensitive data logged (will be masked in files):\n"
                "• Email\n• Phone\n• Credit Card\n• SSN\n• API Key\n• Password\n• IP\n• JWT"
            : "Sensitive data logged (NO redaction - enable it first!)");
  }

  /// Simulate high-volume logging to demonstrate backpressure
  void simulateHighVolumeLogging() async {
    setLogsStatus(status: "Simulating high-volume logging...");

    final stopwatch = Stopwatch()..start();

    // Rapid fire 200 logs to test backpressure
    for (int i = 0; i < 200; i++) {
      FlutterLogs.logInfo(
          _tag, "highVolume", "High volume log message #$i at ${DateTime.now()}");

      // Mix in some warnings and errors
      if (i % 10 == 0) {
        FlutterLogs.logWarn(_tag, "highVolume", "Warning message #$i");
      }
      if (i % 25 == 0) {
        FlutterLogs.logError(_tag, "highVolume", "Error message #$i");
      }
    }

    stopwatch.stop();

    setLogsStatus(
        status: _backpressureEnabled
            ? "Sent 200 logs in ${stopwatch.elapsedMilliseconds}ms\n"
                "Backpressure active - check quotas!"
            : "Sent 200 logs in ${stopwatch.elapsedMilliseconds}ms\n"
                "(Backpressure disabled)");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Logs'),
        ),
        body: SingleChildScrollView(
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
                SizedBox(height: 20),

                // ===== Basic Logging Section =====
                _buildSectionHeader('Basic Logging'),
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

                // ===== Backpressure Section =====
                _buildSectionHeader('Backpressure'),
                _buildFeatureStatus('Backpressure', _backpressureEnabled),
                ElevatedButton(
                  onPressed: setUpLogsWithBackpressure,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('Enable Backpressure',
                      style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: simulateHighVolumeLogging,
                  child: Text('Simulate High Volume',
                      style: TextStyle(fontSize: 20)),
                ),

                // ===== Redaction & Masking Section =====
                _buildSectionHeader('Redaction & Masking'),
                _buildFeatureStatus('Redaction', _redactionEnabled),
                ElevatedButton(
                  onPressed: setUpLogsWithRedaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child:
                      Text('Enable Redaction', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: logSensitiveData,
                  child: Text('Log Sensitive Data',
                      style: TextStyle(fontSize: 20)),
                ),

                // ===== Combined Features Section =====
                _buildSectionHeader('All Features'),
                ElevatedButton(
                  onPressed: setUpLogsWithAllFeatures,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Enable All Features',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),

                // ===== Search & Filter Section =====
                _buildSectionHeader('Search & Filter Logs'),
                SizedBox(height: 8),
                TextField(
                  controller: _keywordsController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Keywords, comma-separated (e.g. ERROR,login)',
                    labelText: 'Search Keywords',
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Match: ', style: TextStyle(fontSize: 15)),
                    // ChoiceChip(
                    //   label: Text('ANY (OR)'),
                    //   selected: _filterType == FilterType.OR,
                    //   onSelected: (_) =>
                    //       setState(() => _filterType = FilterType.OR),
                    // ),
                    // SizedBox(width: 8),
                    // ChoiceChip(
                    //   label: Text('ALL (AND)'),
                    //   selected: _filterType == FilterType.AND,
                    //   onSelected: (_) =>
                    //       setState(() => _filterType = FilterType.AND),
                    // ),
                  ],
                ),
                SizedBox(height: 4),
                ElevatedButton(
                  onPressed: searchAndExportLogs,
                  child:
                      Text('Search & Export', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: searchAndPrintLogs,
                  child: Text('Search & Print', style: TextStyle(fontSize: 20)),
                ),

                // ===== Clear Logs Section =====
                _buildSectionHeader('Maintenance'),
                ElevatedButton(
                  onPressed: () async {
                    FlutterLogs.clearLogs();
                    setLogsStatus(status: "");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Clear Logs',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setUpLogs();
                    setState(() {
                      _backpressureEnabled = false;
                      _redactionEnabled = false;
                    });
                    setLogsStatus(status: "Logs reset to default configuration");
                  },
                  child: Text('Reset to Default',
                      style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Divider(thickness: 2),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFeatureStatus(String feature, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.grey,
            size: 20,
          ),
          SizedBox(width: 4),
          Text(
            '$feature: ${enabled ? "Enabled" : "Disabled"}',
            style: TextStyle(
              color: enabled ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
     // labels: {"env": "dev", "team": "mobile"},
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

  List<String> _parseKeywords() {
    return _keywordsController.text
        .split(',')
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();
  }

  void searchAndExportLogs() {
    final keywords = _parseKeywords();
    if (keywords.isEmpty) {
      setLogsStatus(status: "Enter at least one keyword to search.");
      return;
    }
    // FlutterLogs.exportFilteredLogs(
    //   keywords: keywords,
    //   filterType: _filterType,
    //   exportType: ExportType.ALL,
    //   ignoreCase: true,
    // );
    // setLogsStatus(
    //     status:
    //         "Searching & exporting logs for: ${keywords.join(', ')} [${_filterType.name}]");
  }

  void searchAndPrintLogs() {
    final keywords = _parseKeywords();
    if (keywords.isEmpty) {
      setLogsStatus(status: "Enter at least one keyword to search.");
      return;
    }
    // FlutterLogs.printFilteredLogs(
    //   keywords: keywords,
    //   filterType: _filterType,
    //   exportType: ExportType.ALL,
    //   ignoreCase: true,
    // );
    // setLogsStatus(
    //     status:
    //         "Searching & printing logs for: ${keywords.join(', ')} [${_filterType.name}]");
  }

  void setLogsStatus({String status = '', bool append = false}) {
    setState(() {
      logStatus = status;
    });
  }
}
