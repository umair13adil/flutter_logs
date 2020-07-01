import 'dart:async';

import 'package:flutter/services.dart';

class FlutterLogs {
  static const MethodChannel channel = const MethodChannel('flutter_logs');

  static Future<String> initLogs(
      {List<String> logLevelsEnabled,
      List<String> logTypesEnabled,
      int logsRetentionPeriodInDays = 14,
      int zipsRetentionPeriodInDays = 3,
      bool autoDeleteZipOnExport = false,
      bool autoClearLogs = true,
      bool autoExportErrors = true,
      bool encryptionEnabled = false,
      String encryptionKey = "",
      //directoryStructure = DirectoryStructure.FOR_DATE,
      bool logSystemCrashes = true,
      bool isDebuggable = true,
      bool debugFileOperations = true,
      bool attachTimeStamp = true,
      bool attachNoOfFiles = true,
      //bool timeStampFormat = TimeStampFormat.TIME_FORMAT_READABLE,
      //logFileExtension = LogExtension.LOG,
      bool zipFilesOnly = false,
      String savePath = "",
      String zipFileName = "",
      String exportPath = "",
      int singleLogFileSize = 2,
      bool enabled = true}) async {
    return await channel.invokeMethod('initLogs', <String, dynamic>{
      'logLevelsEnabled': logLevelsEnabled,
      'logTypesEnabled': logTypesEnabled,
      'logsRetentionPeriodInDays': logsRetentionPeriodInDays,
      'zipsRetentionPeriodInDays': zipsRetentionPeriodInDays,
      'autoDeleteZipOnExport': autoDeleteZipOnExport,
      'autoClearLogs': autoClearLogs,
      'autoExportErrors': autoExportErrors,
      'encryptionEnabled': encryptionEnabled,
      'encryptionKey': encryptionKey,
      'logSystemCrashes': logSystemCrashes,
      'isDebuggable': isDebuggable,
      'debugFileOperations': debugFileOperations,
      'attachTimeStamp': attachTimeStamp,
      'attachNoOfFiles': attachNoOfFiles,
      'zipFilesOnly': zipFilesOnly,
      'savePath': savePath,
      'zipFileName': zipFileName,
      'exportPath': exportPath,
      'singleLogFileSize': singleLogFileSize,
      'enabled': enabled,
    });
  }

  static Future<String> initMQTT(
      {String topic = "",
      String brokerUrl = "",
      String certificate = "",
      String clientId = ""}) async {
    final ByteData bytes = await rootBundle.load('assets/$certificate');
    return await channel.invokeMethod('initMQTT', <String, dynamic>{
      'topic': topic,
      'brokerUrl': brokerUrl,
      'certificate': bytes.buffer.asUint8List(),
      'clientId': clientId
    });
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
    String userId = "",
    String userName = "",
    String userEmail = "",
    String deviceSerial = "",
    String deviceBrand = "",
    String deviceName = "",
    String deviceManufacturer = "",
    String deviceModel = "",
    String deviceSdkInt = "",
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
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'deviceSerial': deviceSerial,
      'deviceBrand': deviceBrand,
      'deviceName': deviceName,
      'deviceManufacturer': deviceManufacturer,
      'deviceModel': deviceModel,
      'deviceSdkInt': deviceSdkInt,
      'latitude': latitude,
      'longitude': longitude,
      'labels': labels
    });
  }
}
