import 'dart:async';

import 'package:flutter/services.dart';

enum DirectoryStructure { FOR_DATE, FOR_EVENT, SINGLE_FILE_FOR_DAY }

enum LogFileExtension { TXT, CSV, LOG, NONE }

enum LogLevel { INFO, WARNING, ERROR, SEVERE }

enum LogType {
  Device,
  Location,
  Notification,
  Network,
  Navigation,
  History,
  Tasks,
  Jobs,
  Errors
}

enum TimeStampFormat {
  DATE_FORMAT_1,
  DATE_FORMAT_2,
  TIME_FORMAT_FULL_JOINED,
  TIME_FORMAT_FULL_1,
  TIME_FORMAT_FULL_2,
  TIME_FORMAT_24_FULL,
  TIME_FORMAT_READABLE,
  TIME_FORMAT_READABLE_2,
  TIME_FORMAT_SIMPLE
}

enum ExportType { TODAY, LAST_HOUR, WEEKS, LAST_24_HOURS, ALL }

enum FilterType { AND, OR }

enum FormatType { FORMAT_CURLY, FORMAT_SQUARE, FORMAT_CSV, FORMAT_CUSTOM }

enum MaskType { FULL_MASK, HASH, PARTIAL }

enum BuiltInPattern { PHONE_NUMBER, EMAIL, CREDIT_CARD, JWT_TOKEN, IP_ADDRESS }

class RedactionRule {
  final String name;
  final String patternString;
  final MaskType maskType;
  final String? replacement;

  const RedactionRule({
    required this.name,
    required this.patternString,
    this.maskType = MaskType.FULL_MASK,
    this.replacement,
  });
}

class BackpressureConfig {
  final int queueCapacity;
  final int warnQueueCapacity;
  final Map<LogLevel, int> perLevelQuotas;
  final int quotaWindowMillis;

  const BackpressureConfig({
    this.queueCapacity = 500,
    this.warnQueueCapacity = 750,
    this.perLevelQuotas = const {},
    this.quotaWindowMillis = 60000,
  });
}

class RedactionConfig {
  final Set<BuiltInPattern> enableBuiltInPatterns;
  final List<RedactionRule> customRules;
  final MaskType defaultMaskType;

  const RedactionConfig({
    this.enableBuiltInPatterns = const {},
    this.customRules = const [],
    this.defaultMaskType = MaskType.FULL_MASK,
  });
}

class FlutterLogs {
  // 0 = no messages, 1 = only errors, 2 = all
  static int _debugLevel = 2;

  /// Set the message level value [value] for debugging purpose. 0 = no messages, 1 = errors, 2 = all
  static void setDebugLevel(int value) {
    _debugLevel = value;
  }

  // Send the message [msg] with the [msgDebugLevel] value. 1 = error, 2 = info
  static void printDebugMessage(String msg, int msgDebugLevel) {
    if (_debugLevel >= msgDebugLevel) {
      print('flutter_logs: $msg');
    }
  }

  static const MethodChannel channel = const MethodChannel('flutter_logs');

  static Future<String> initLogs(
      {List<LogLevel>? logLevelsEnabled,
      List<String>? logTypesEnabled,
      int logsRetentionPeriodInDays = 14,
      int zipsRetentionPeriodInDays = 3,
      bool autoDeleteZipOnExport = false,
      bool autoClearLogs = true,
      bool autoExportErrors = true,
      bool encryptionEnabled = false,
      String encryptionKey = "",
      required DirectoryStructure directoryStructure,
      bool logSystemCrashes = true,
      bool isDebuggable = true,
      bool debugFileOperations = true,
      bool attachTimeStamp = true,
      bool attachNoOfFiles = true,
      required TimeStampFormat timeStampFormat,
      required LogFileExtension logFileExtension,
      bool zipFilesOnly = false,
      String logsWriteDirectoryName = "",
      String logsExportZipFileName = "",
      String logsExportDirectoryName = "",
      int singleLogFileSize = 2,
      bool enabled = true,
      bool forceWriteLogs = true,
      bool enableLogsWriteToFile = true,
      FormatType formatType = FormatType.FORMAT_CURLY,
      String customFormatOpen = " ",
      String customFormatClose = " ",
      int logFilesLimit = 100,
      String nameForEventDirectory = "",
      List<String>? autoExportLogTypes,
      int autoExportLogTypesPeriod = 0,
      String csvDelimiter = "",
      bool exportFormatted = true,
      String exportFileNamePostFix = "",
      String exportFileNamePreFix = "",
      BackpressureConfig? backpressureConfig,
      RedactionConfig? redactionConfig}) async {
    var directoryStructureString = _getDirectoryStructure(directoryStructure);
    var timeStampFormatString = _getTimeStampFormat(timeStampFormat);
    var logFileExtensionString = _getLogFileExtension(logFileExtension);
    var logLevelsEnabledList =
        logLevelsEnabled?.map((e) => _getLogLevel(e)) ?? <String>[];

    final String result =
        await channel.invokeMethod('initLogs', <String, dynamic>{
      'logLevelsEnabled': logLevelsEnabledList.join(','),
      'logTypesEnabled': logTypesEnabled?.join(',') ?? '',
      'logsRetentionPeriodInDays': logsRetentionPeriodInDays,
      'zipsRetentionPeriodInDays': zipsRetentionPeriodInDays,
      'autoDeleteZipOnExport': autoDeleteZipOnExport,
      'autoClearLogs': autoClearLogs,
      'autoExportErrors': autoExportErrors,
      'encryptionEnabled': encryptionEnabled,
      'encryptionKey': encryptionKey,
      'directoryStructure': directoryStructureString,
      'logSystemCrashes': logSystemCrashes,
      'isDebuggable': isDebuggable,
      'debugFileOperations': debugFileOperations,
      'attachTimeStamp': attachTimeStamp,
      'attachNoOfFiles': attachNoOfFiles,
      'timeStampFormat': timeStampFormatString,
      'logFileExtension': logFileExtensionString,
      'zipFilesOnly': zipFilesOnly,
      'savePath': logsWriteDirectoryName,
      'zipFileName': logsExportZipFileName,
      'exportPath': logsExportDirectoryName,
      'singleLogFileSize': singleLogFileSize,
      'enabled': enabled,
      'forceWriteLogs': forceWriteLogs,
      'enableLogsWriteToFile': enableLogsWriteToFile,
      'formatType': _getFormatType(formatType),
      'customFormatOpen': customFormatOpen,
      'customFormatClose': customFormatClose,
      'logFilesLimit': logFilesLimit,
      'nameForEventDirectory': nameForEventDirectory,
      'autoExportLogTypes': autoExportLogTypes?.join(',') ?? '',
      'autoExportLogTypesPeriod': autoExportLogTypesPeriod,
      'csvDelimiter': csvDelimiter,
      'exportFormatted': exportFormatted,
      'exportFileNamePostFix': exportFileNamePostFix,
      'exportFileNamePreFix': exportFileNamePreFix,
      'backpressureConfig': backpressureConfig != null
          ? _encodeBackpressureConfig(backpressureConfig)
          : null,
      'redactionConfig': redactionConfig != null
          ? _encodeRedactionConfig(redactionConfig)
          : null,
    });
    printDebugMessage(result, 2);
    return result;
  }

  static Future<String?> initMQTT(
      {String topic = "",
      String brokerUrl = "",
      String certificate = "",
      String clientId = "",
      String port = "",
      int qos = 0,
      bool retained = false,
      bool writeLogsToLocalStorage = true,
      bool debug = true,
      int initialDelaySecondsForPublishing = 30}) async {
    if (brokerUrl.isNotEmpty && certificate.isNotEmpty) {
      final ByteData bytes = await rootBundle.load('$certificate');
      return await channel.invokeMethod('initMQTT', <String, dynamic>{
        'topic': topic,
        'brokerUrl': brokerUrl,
        'certificate': bytes.buffer.asUint8List(),
        'clientId': clientId,
        'port': port,
        'qos': qos,
        'retained': retained,
        'writeLogsToLocalStorage': writeLogsToLocalStorage,
        'debug': debug,
        'initialDelaySecondsForPublishing': initialDelaySecondsForPublishing
      });
    }
  }

  static Future<String> setMetaInfo({
    String appId = "",
    String appName = "",
    String appVersion = "",
    String language = "",
    String deviceId = "",
    String environmentId = "",
    String environmentName = "",
    String organizationId = "",
    String organizationName = "",
    String organizationUnitId = "",
    String userId = "",
    String userName = "",
    String userEmail = "",
    String deviceSerial = "",
    String deviceBrand = "",
    String deviceName = "",
    String deviceManufacturer = "",
    String deviceModel = "",
    String deviceSdkInt = "",
    String deviceBatteryPercent = "",
    String latitude = "",
    String longitude = "",
    Map<String, String>? labels,
  }) async {
    return await channel.invokeMethod('setMetaInfo', <String, dynamic>{
      'appId': appId,
      'appName': appName,
      'appVersion': appVersion,
      'language': language,
      'deviceId': deviceId,
      'environmentId': environmentId,
      'environmentName': environmentName,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'organizationUnitId': organizationUnitId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'deviceSerial': deviceSerial,
      'deviceBrand': deviceBrand,
      'deviceName': deviceName,
      'deviceManufacturer': deviceManufacturer,
      'deviceModel': deviceModel,
      'deviceSdkInt': deviceSdkInt,
      'deviceBatteryPercent': deviceBatteryPercent,
      'latitude': latitude,
      'longitude': longitude,
      'labels': labels ?? <String, String>{},
    });
  }

  static Future<void> logThis(
      {String tag = "",
      String subTag = "",
      String logMessage = "",
      LogLevel level = LogLevel.INFO,
      Exception? exception,
      Error? error,
      String errorMessage = ""}) async {
    if (exception != null) {
      final String result =
          await channel.invokeMethod('logThis', <String, dynamic>{
        'tag': tag,
        'subTag': subTag,
        'logMessage': "$logMessage , Error: ${error.toString()}",
        'level': _getLogLevel(level),
        'e': exception.toString()
      });
      printDebugMessage(result, 2);
    } else if (error != null) {
      final String result =
          await channel.invokeMethod('logThis', <String, dynamic>{
        'tag': tag,
        'subTag': subTag,
        'logMessage': "$logMessage , Error: ${error.toString()}",
        'level': _getLogLevel(level),
        'e': error.stackTrace.toString()
      });
      printDebugMessage(result, 2);
    } else if (errorMessage != null && errorMessage.isNotEmpty) {
      final String result =
          await channel.invokeMethod('logThis', <String, dynamic>{
        'tag': tag,
        'subTag': subTag,
        'logMessage': "$logMessage , Error: $errorMessage",
        'level': _getLogLevel(level)
      });
      printDebugMessage(result, 2);
    } else {
      final String result =
          await channel.invokeMethod('logThis', <String, dynamic>{
        'tag': tag,
        'subTag': subTag,
        'logMessage': logMessage,
        'level': _getLogLevel(level)
      });
      printDebugMessage(result, 2);
    }
  }

  static Future<void> logInfo(
      String tag, String subTag, String logMessage) async {
    final String result =
        await channel.invokeMethod('logThis', <String, dynamic>{
      'tag': tag,
      'subTag': subTag,
      'logMessage': logMessage,
      'level': _getLogLevel(LogLevel.INFO)
    });
    printDebugMessage(result, 2);
  }

  static Future<void> logWarn(
      String tag, String subTag, String logMessage) async {
    final String result =
        await channel.invokeMethod('logThis', <String, dynamic>{
      'tag': tag,
      'subTag': subTag,
      'logMessage': logMessage,
      'level': _getLogLevel(LogLevel.WARNING)
    });
    printDebugMessage(result, 2);
  }

  static Future<void> logError(
      String tag, String subTag, String logMessage) async {
    final String result =
        await channel.invokeMethod('logThis', <String, dynamic>{
      'tag': tag,
      'subTag': subTag,
      'logMessage': logMessage,
      'level': _getLogLevel(LogLevel.ERROR)
    });
    printDebugMessage(result, 2);
  }

  static Future<void> logErrorTrace(
      String tag, String subTag, String logMessage, Error e) async {
    final String result =
        await channel.invokeMethod('logThis', <String, dynamic>{
      'tag': tag,
      'subTag': subTag,
      'logMessage': logMessage,
      'e': e.stackTrace.toString(),
      'level': _getLogLevel(LogLevel.ERROR)
    });
    printDebugMessage(result, 2);
  }

  static Future<void> logToFile(
      {String logFileName = "",
      bool overwrite = false,
      String logMessage = "",
      bool appendTimeStamp = false}) async {
    if (logFileName.isNotEmpty) {
      final String result =
          await channel.invokeMethod('logToFile', <String, dynamic>{
        'logFileName': logFileName,
        'overwrite': overwrite,
        'logMessage': logMessage,
        'appendTimeStamp': appendTimeStamp
      });
      printDebugMessage(result, 2);
    } else {
      print("Error: \'logFileName\' required.");
    }
  }

  static Future<void> exportLogs(
      {ExportType exportType = ExportType.ALL,
      bool decryptBeforeExporting = false}) async {
    final String? result =
        await channel.invokeMethod<String>('exportLogs', <String, dynamic>{
      'exportType': _getExportType(exportType),
      'decryptBeforeExporting': decryptBeforeExporting
    });
    printDebugMessage(result ?? '', 2);
  }

  static Future<void> printLogs(
      {ExportType exportType = ExportType.ALL,
      bool decryptBeforeExporting = false}) async {
    final String result =
        await channel.invokeMethod('printLogs', <String, dynamic>{
      'exportType': _getExportType(exportType),
      'decryptBeforeExporting': decryptBeforeExporting
    });
    printDebugMessage(result, 2);
  }

  static Future<void> exportFileLogForName(
      {String logFileName = "", bool decryptBeforeExporting = false}) async {
    if (logFileName.isNotEmpty) {
      final String result = await channel.invokeMethod(
          'exportFileLogForName', <String, dynamic>{
        'logFileName': logFileName,
        'decryptBeforeExporting': decryptBeforeExporting
      });
      printDebugMessage(result, 2);
    } else {
      print("Error: \'logFileName\' required.");
    }
  }

  static Future<void> exportAllFileLogs(
      {bool decryptBeforeExporting = false}) async {
    final String result = await channel.invokeMethod('exportAllFileLogs',
        <String, dynamic>{'decryptBeforeExporting': decryptBeforeExporting});
    printDebugMessage(result, 2);
  }

  static Future<void> printFileLogForName(
      {String logFileName = "", bool decryptBeforeExporting = false}) async {
    if (logFileName.isNotEmpty) {
      final String result = await channel.invokeMethod(
          'printFileLogForName', <String, dynamic>{
        'logFileName': logFileName,
        'decryptBeforeExporting': decryptBeforeExporting
      });
      printDebugMessage(result, 2);
    } else {
      print("Error: \'logFileName\' required.");
    }
  }

  /// Searches all log files for lines containing [keywords] and exports only
  /// matching lines to a zip file. Use [filterType] to require ALL keywords
  /// to match (AND) or ANY keyword to match (OR). Set [ignoreCase] to true
  /// for case-insensitive matching.
  static Future<void> exportFilteredLogs({
    required List<String> keywords,
    FilterType filterType = FilterType.OR,
    ExportType exportType = ExportType.ALL,
    bool decryptBeforeExporting = false,
    bool ignoreCase = true,
  }) async {
    if (keywords.isEmpty) {
      print("Error: 'keywords' must not be empty.");
      return;
    }
    final String result =
        await channel.invokeMethod('exportFilteredLogs', <String, dynamic>{
      'keywords': keywords.join(','),
      'filterType': _getFilterType(filterType),
      'exportType': _getExportType(exportType),
      'decryptBeforeExporting': decryptBeforeExporting,
      'ignoreCase': ignoreCase,
    });
    printDebugMessage(result, 2);
  }

  /// Searches all log files for lines containing [keywords] and prints only
  /// matching lines to the debug console. Use [filterType] to require ALL
  /// keywords to match (AND) or ANY keyword to match (OR). Set [ignoreCase]
  /// to true for case-insensitive matching.
  static Future<void> printFilteredLogs({
    required List<String> keywords,
    FilterType filterType = FilterType.OR,
    ExportType exportType = ExportType.ALL,
    bool decryptBeforeExporting = false,
    bool ignoreCase = true,
  }) async {
    if (keywords.isEmpty) {
      print("Error: 'keywords' must not be empty.");
      return;
    }
    final String result =
        await channel.invokeMethod('printFilteredLogs', <String, dynamic>{
      'keywords': keywords.join(','),
      'filterType': _getFilterType(filterType),
      'exportType': _getExportType(exportType),
      'decryptBeforeExporting': decryptBeforeExporting,
      'ignoreCase': ignoreCase,
    });
    printDebugMessage(result, 2);
  }

  static Future<void> clearLogs() async {
    final String result = await channel.invokeMethod('clearLogs');
    printDebugMessage(result, 2);
  }

  static String _getDirectoryStructure(DirectoryStructure type) {
    return type.toString().split('.').last;
  }

  static String _getLogFileExtension(LogFileExtension type) {
    return type.toString().split('.').last;
  }

  static String _getLogLevel(LogLevel type) {
    return type.toString().split('.').last;
  }

  static String _getLogType(LogType type) {
    return type.toString().split('.').last;
  }

  static String _getTimeStampFormat(TimeStampFormat type) {
    return type.toString().split('.').last;
  }

  static String _getExportType(ExportType type) {
    return type.toString().split('.').last;
  }

  static String _getFilterType(FilterType type) {
    return type.toString().split('.').last;
  }

  static String _getFormatType(FormatType type) {
    return type.toString().split('.').last;
  }

  static String _getMaskType(MaskType type) {
    return type.toString().split('.').last;
  }

  static Map<String, dynamic> _encodeBackpressureConfig(
      BackpressureConfig config) {
    return {
      'queueCapacity': config.queueCapacity,
      'warnQueueCapacity': config.warnQueueCapacity,
      'perLevelQuotas': config.perLevelQuotas
          .map((k, v) => MapEntry(_getLogLevel(k), v)),
      'quotaWindowMillis': config.quotaWindowMillis,
    };
  }

  static Map<String, dynamic> _encodeRedactionConfig(RedactionConfig config) {
    return {
      'enableBuiltInPatterns': config.enableBuiltInPatterns
          .map((p) => p.toString().split('.').last)
          .toList(),
      'customRules': config.customRules
          .map((r) => {
                'name': r.name,
                'patternString': r.patternString,
                'maskType': _getMaskType(r.maskType),
                'replacement': r.replacement,
              })
          .toList(),
      'defaultMaskType': _getMaskType(config.defaultMaskType),
    };
  }
}
