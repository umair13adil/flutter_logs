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
  TIME_FORMAT_SIMPLE
}
enum ExportType { TODAY, LAST_HOUR, WEEKS, LAST_24_HOURS, ALL }

class FlutterLogs {
  // 0 = no messages, 1 = only errors, 2 = all
  static int _debugLevel = 2;

  /// Set the message level value [value] for debugging purpose. 0 = no messages, 1 = errors, 2 = all
  static void setDebugLevel(int value) {
    _debugLevel = value;
  }

  // Send the message [msg] with the [msgDebugLevel] value. 1 = error, 2 = info
  static void printDebugMessage(String? msg, int msgDebugLevel) {
    if (_debugLevel >= msgDebugLevel) {
      print('flutter_logs: $msg');
    }
  }

  static const MethodChannel channel = const MethodChannel('flutter_logs');

  static Future<String?> initLogs(
      {required List<LogLevel> logLevelsEnabled,
      required List<String> logTypesEnabled,
      int logsRetentionPeriodInDays = 14,
      int zipsRetentionPeriodInDays = 3,
      bool autoDeleteZipOnExport = false,
      bool autoClearLogs = true,
      bool autoExportErrors = true,
      bool encryptionEnabled = false,
      String encryptionKey = "",
      DirectoryStructure? directoryStructure,
      bool logSystemCrashes = true,
      bool isDebuggable = true,
      bool debugFileOperations = true,
      bool attachTimeStamp = true,
      bool attachNoOfFiles = true,
      TimeStampFormat? timeStampFormat,
      LogFileExtension? logFileExtension,
      bool zipFilesOnly = false,
      String logsWriteDirectoryName = "",
      String logsExportZipFileName = "",
      String logsExportDirectoryName = "",
      int singleLogFileSize = 2,
      bool enabled = true}) async {
    var directoryStructureString = _getDirectoryStructure(directoryStructure);
    var timeStampFormatString = _getTimeStampFormat(timeStampFormat);
    var logFileExtensionString = _getLogFileExtension(logFileExtension);
    var logLevelsEnabledList = logLevelsEnabled.map((e) => _getLogLevel(e));

    final String? result =
        await channel.invokeMethod('initLogs', <String, dynamic>{
      'logLevelsEnabled': logLevelsEnabledList.join(','),
      'logTypesEnabled': logTypesEnabled.join(','),
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

  static Future<String?> setMetaInfo({
    String appId = "",
    String appName = "",
    String appVersion = "",
    String language = "",
    String deviceId = "",
    String environmentId = "",
    String environmentName = "",
    String organizationId = "",
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
    String labels = "",
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
      'labels': labels
    });
  }

  static void logThis(
      {String tag = "",
      String subTag = "",
      String logMessage = "",
      LogLevel level = LogLevel.INFO,
      Exception? exception = null,
      Error? error = null,
      String errorMessage = ""}) async {
    if (exception != null) {
      final String? result =
          await channel.invokeMethod('logThis', <String, dynamic>{
        'tag': tag,
        'subTag': subTag,
        'logMessage': "$logMessage , Error: ${error.toString()}",
        'level': _getLogLevel(level),
        'e': exception.toString()
      });
      printDebugMessage(result, 2);
    } else if (error != null) {
      final String? result =
          await channel.invokeMethod('logThis', <String, dynamic>{
        'tag': tag,
        'subTag': subTag,
        'logMessage': "$logMessage , Error: ${error.toString()}",
        'level': _getLogLevel(level),
        'e': error.stackTrace.toString()
      });
      printDebugMessage(result, 2);
    } else if (errorMessage != null && errorMessage.isNotEmpty) {
      final String? result =
          await channel.invokeMethod('logThis', <String, dynamic>{
        'tag': tag,
        'subTag': subTag,
        'logMessage': "$logMessage , Error: $errorMessage",
        'level': _getLogLevel(level)
      });
      printDebugMessage(result, 2);
    } else {
      final String? result =
          await channel.invokeMethod('logThis', <String, dynamic>{
        'tag': tag,
        'subTag': subTag,
        'logMessage': logMessage,
        'level': _getLogLevel(level)
      });
      printDebugMessage(result, 2);
    }
  }

  static void logInfo(String tag, String subTag, String logMessage) async {
    final String? result =
        await channel.invokeMethod('logThis', <String, dynamic>{
      'tag': tag,
      'subTag': subTag,
      'logMessage': logMessage,
      'level': _getLogLevel(LogLevel.INFO)
    });
    printDebugMessage(result, 2);
  }

  static void logWarn(String tag, String subTag, String logMessage) async {
    final String? result =
        await channel.invokeMethod('logThis', <String, dynamic>{
      'tag': tag,
      'subTag': subTag,
      'logMessage': logMessage,
      'level': _getLogLevel(LogLevel.WARNING)
    });
    printDebugMessage(result, 2);
  }

  static void logError(String tag, String subTag, String logMessage) async {
    final String? result =
        await channel.invokeMethod('logThis', <String, dynamic>{
      'tag': tag,
      'subTag': subTag,
      'logMessage': logMessage,
      'level': _getLogLevel(LogLevel.ERROR)
    });
    printDebugMessage(result, 2);
  }

  static void logErrorTrace(
      String tag, String subTag, String logMessage, Error e) async {
    final String? result =
        await channel.invokeMethod('logThis', <String, dynamic>{
      'tag': tag,
      'subTag': subTag,
      'logMessage': logMessage,
      'e': e.stackTrace.toString(),
      'level': _getLogLevel(LogLevel.ERROR)
    });
    printDebugMessage(result, 2);
  }

  static void logToFile(
      {String logFileName = "",
      bool overwrite = false,
      String logMessage = "",
      bool appendTimeStamp = false}) async {
    if (logFileName.isNotEmpty) {
      final String? result =
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

  static void exportLogs(
      {ExportType exportType = ExportType.ALL,
      bool decryptBeforeExporting = false}) async {
    final String? result =
        await channel.invokeMethod('exportLogs', <String, dynamic>{
      'exportType': _getExportType(exportType),
      'decryptBeforeExporting': decryptBeforeExporting
    });
    printDebugMessage(result, 2);
  }

  static void printLogs(
      {ExportType exportType = ExportType.ALL,
      bool decryptBeforeExporting = false}) async {
    final String? result =
        await channel.invokeMethod('printLogs', <String, dynamic>{
      'exportType': _getExportType(exportType),
      'decryptBeforeExporting': decryptBeforeExporting
    });
    printDebugMessage(result, 2);
  }

  static void exportFileLogForName(
      {String logFileName = "", bool decryptBeforeExporting = false}) async {
    if (logFileName.isNotEmpty) {
      final String? result = await channel.invokeMethod(
          'exportFileLogForName', <String, dynamic>{
        'logFileName': logFileName,
        'decryptBeforeExporting': decryptBeforeExporting
      });
      printDebugMessage(result, 2);
    } else {
      print("Error: \'logFileName\' required.");
    }
  }

  static void exportAllFileLogs({bool decryptBeforeExporting = false}) async {
    final String? result = await channel.invokeMethod('exportAllFileLogs',
        <String, dynamic>{'decryptBeforeExporting': decryptBeforeExporting});
    printDebugMessage(result, 2);
  }

  static void printFileLogForName(
      {String logFileName = "", bool decryptBeforeExporting = false}) async {
    if (logFileName.isNotEmpty) {
      final String? result = await channel.invokeMethod(
          'printFileLogForName', <String, dynamic>{
        'logFileName': logFileName,
        'decryptBeforeExporting': decryptBeforeExporting
      });
      printDebugMessage(result, 2);
    } else {
      print("Error: \'logFileName\' required.");
    }
  }

  static void clearLogs() async {
    final String? result = await channel.invokeMethod('clearLogs');
    printDebugMessage(result, 2);
  }

  static String _getDirectoryStructure(DirectoryStructure? type) {
    return type.toString().split('.').last;
  }

  static String _getLogFileExtension(LogFileExtension? type) {
    return type.toString().split('.').last;
  }

  static String _getLogLevel(LogLevel type) {
    return type.toString().split('.').last;
  }

  static String _getLogType(LogType type) {
    return type.toString().split('.').last;
  }

  static String _getTimeStampFormat(TimeStampFormat? type) {
    return type.toString().split('.').last;
  }

  static String _getExportType(ExportType type) {
    return type.toString().split('.').last;
  }
}
