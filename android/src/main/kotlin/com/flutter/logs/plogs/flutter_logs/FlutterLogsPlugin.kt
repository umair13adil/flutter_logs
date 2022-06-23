package com.flutter.logs.plogs.flutter_logs

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.blackbox.plog.pLogs.PLog
import com.blackbox.plog.pLogs.models.LogLevel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.rxkotlin.subscribeBy
import io.reactivex.schedulers.Schedulers


class FlutterLogsPlugin : FlutterPlugin, ActivityAware {

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
        setUpPluginMethods(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger)
    }

    companion object {
        private val TAG = "FlutterLogsPlugin"
        private var channel: MethodChannel? = null
        private var event_channel: EventChannel? = null

        @JvmStatic
        private var currentActivity: Activity? = null

        @JvmStatic
        private var binaryMessenger: BinaryMessenger? = null

        @JvmStatic
        private fun setUpPluginMethods(context: Context, messenger: BinaryMessenger) {
          
            channel = MethodChannel(messenger, "flutter_logs")

            channel?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "initLogs" -> {

                        val logLevelsEnabled = getLogLevelsById("logLevelsEnabled", call)
                        val logTypesEnabled = getListOfStringById("logTypesEnabled", call)
                        val logsRetentionPeriodInDays = getIntValueById("logsRetentionPeriodInDays", call)
                        val zipsRetentionPeriodInDays = getIntValueById("zipsRetentionPeriodInDays", call)
                        val autoDeleteZipOnExport = getBoolValueById("autoDeleteZipOnExport", call)
                        val autoClearLogs = getBoolValueById("autoClearLogs", call)
                        val autoExportErrors = getBoolValueById("autoExportErrors", call)
                        val encryptionEnabled = getBoolValueById("encryptionEnabled", call)
                        val encryptionKey = getStringValueById("encryptionKey", call)
                        val directoryStructure = getStringValueById("directoryStructure", call)
                        val logSystemCrashes = getBoolValueById("logSystemCrashes", call)
                        val isDebuggable = getBoolValueById("isDebuggable", call)
                        val debugFileOperations = getBoolValueById("debugFileOperations", call)
                        val attachTimeStamp = getBoolValueById("attachTimeStamp", call)
                        val attachNoOfFiles = getBoolValueById("attachNoOfFiles", call)
                        val timeStampFormat = getStringValueById("timeStampFormat", call)
                        val logFileExtension = getStringValueById("logFileExtension", call)
                        val zipFilesOnly = getBoolValueById("zipFilesOnly", call)
                        val savePath = getStringValueById("savePath", call)
                        val zipFileName = getStringValueById("zipFileName", call)
                        val exportPath = getStringValueById("exportPath", call)
                        val singleLogFileSize = getIntValueById("singleLogFileSize", call)
                        val enabled = getBoolValueById("enabled", call)

                        LogsHelper.setUpLogger(
                                context = context,
                                logLevelsEnabled = logLevelsEnabled,
                                logTypesEnabled = logTypesEnabled,
                                logsRetentionPeriodInDays = logsRetentionPeriodInDays,
                                zipsRetentionPeriodInDays = zipsRetentionPeriodInDays,
                                autoDeleteZipOnExport = autoDeleteZipOnExport,
                                autoClearLogs = autoClearLogs,
                                autoExportErrors = autoExportErrors,
                                encryptionEnabled = encryptionEnabled,
                                encryptionKey = encryptionKey,
                                directoryStructure = directoryStructure,
                                logSystemCrashes = logSystemCrashes,
                                isDebuggable = isDebuggable,
                                debugFileOperations = debugFileOperations,
                                attachTimeStamp = attachTimeStamp,
                                attachNoOfFiles = attachNoOfFiles,
                                timeStampFormat = timeStampFormat,
                                logFileExtension = logFileExtension,
                                zipFilesOnly = zipFilesOnly,
                                savePath = savePath,
                                zipFileName = zipFileName,
                                exportPath = exportPath,
                                singleLogFileSize = singleLogFileSize,
                                enabled = enabled)

                        result.success("Logs Configuration added.")
                    }
                    "initMQTT" -> {
                        val topic = getStringValueById("topic", call)
                        val brokerUrl = getStringValueById("brokerUrl", call)
                        val certificate = getInputStreamValueById("certificate", call)
                        val clientId = getStringValueById("clientId", call)
                        val port = getStringValueById("port", call)
                        val qos = getIntValueById("qos", call)
                        val retained = getBoolValueById("retained", call)
                        val writeLogsToLocalStorage = getBoolValueById("writeLogsToLocalStorage", call)
                        val debug = getBoolValueById("debug", call)
                        val initialDelaySecondsForPublishing = getIntValueById("initialDelaySecondsForPublishing", call)

                        LogsHelper.setMQTT(context,
                                writeLogsToLocalStorage = writeLogsToLocalStorage,
                                topic = topic,
                                brokerUrl = brokerUrl,
                                certificateInputStream = certificate,
                                clientId = clientId,
                                port = port,
                                qos = qos,
                                retained = retained,
                                debug = debug,
                                initialDelaySecondsForPublishing = initialDelaySecondsForPublishing)

                        result.success("MQTT setup added.")
                    }
                    "setMetaInfo" -> {
                        val appId = getStringValueById("appId", call)
                        val appName = getStringValueById("appName", call)
                        val appVersion = getStringValueById("appVersion", call)
                        val language = getStringValueById("language", call)
                        val deviceId = getStringValueById("deviceId", call)
                        val environmentId = getStringValueById("environmentId", call)
                        val environmentName = getStringValueById("environmentName", call)
                        val organizationId = getStringValueById("organizationId", call)
                        val organizationUnitId = getStringValueById("organizationUnitId", call)
                        val userId = getStringValueById("userId", call)
                        val userName = getStringValueById("userName", call)
                        val userEmail = getStringValueById("userEmail", call)
                        val deviceSerial = getStringValueById("deviceSerial", call)
                        val deviceBrand = getStringValueById("deviceBrand", call)
                        val deviceName = getStringValueById("deviceName", call)
                        val deviceManufacturer = getStringValueById("deviceManufacturer", call)
                        val deviceModel = getStringValueById("deviceModel", call)
                        val deviceSdkInt = getStringValueById("deviceSdkInt", call)
                        val deviceBatteryPercent = getStringValueById("deviceBatteryPercent", call)
                        val latitude = getStringValueById("latitude", call)
                        val longitude = getStringValueById("longitude", call)
                        val labels = getStringValueById("labels", call)

                        LogsHelper.setupForELKStack(
                                appId = appId,
                                appName = appName,
                                appVersion = appVersion,
                                deviceId = deviceId,
                                environmentId = environmentId,
                                environmentName = environmentName,
                                organizationId = organizationId,
                                organizationUnitId = organizationUnitId,
                                language = language,
                                userId = userId,
                                userName = userName,
                                userEmail = userEmail,
                                deviceSerial = deviceSerial,
                                deviceBrand = deviceBrand,
                                deviceName = deviceName,
                                deviceManufacturer = deviceManufacturer,
                                deviceModel = deviceModel,
                                deviceSdkInt = deviceSdkInt,
                                deviceBatteryPercent = deviceBatteryPercent,
                                latitude = latitude,
                                longitude = longitude
                        )

                        result.success("Logs MetaInfo added for ELK stack.")
                    }
                    "logThis" -> {
                        val tag = getStringValueById("tag", call)
                        val subTag = getStringValueById("subTag", call)
                        val logMessage = getStringValueById("logMessage", call)
                        val level = getStringValueById("level", call)
                        val exception = getStringValueById("e", call)

                        when (getLogLevel(level)) {
                            LogLevel.INFO -> {
                                PLog.logThis(tag, subTag, logMessage, LogLevel.INFO)
                            }
                            LogLevel.WARNING -> {
                                PLog.logThis(tag, subTag, logMessage, LogLevel.WARNING)
                            }
                            LogLevel.ERROR -> {
                                if (exception.isNotEmpty()) {
                                    //PLog.logThis(tag, subTag, logMessage, Throwable(exception), LogLevel.ERROR)
                                    PLog.logThis(tag, subTag, exception, LogLevel.ERROR)
                                } else {
                                    PLog.logThis(tag, subTag, logMessage, LogLevel.ERROR)
                                }
                            }
                            LogLevel.SEVERE -> {
                                if (exception.isNotEmpty()) {
                                    //PLog.logThis(tag, subTag, logMessage, Throwable(exception), LogLevel.SEVERE)
                                    PLog.logThis(tag, subTag, exception, LogLevel.SEVERE)
                                } else {
                                    PLog.logThis(tag, subTag, logMessage, LogLevel.SEVERE)
                                }
                            }
                        }
                    }
                    "logToFile" -> {
                        val logFileName = getStringValueById("logFileName", call)
                        val overwrite = getBoolValueById("overwrite", call)
                        val logMessage = getStringValueById("logMessage", call)
                        val appendTimeStamp = getBoolValueById("appendTimeStamp", call)

                        if (overwrite) {
                            LogsHelper.overWriteLogToFile(logFileName, logMessage, appendTimeStamp)
                        } else {
                            LogsHelper.writeLogToFile(logFileName, logMessage, appendTimeStamp)
                        }
                    }
                    "exportLogs" -> {
                        val exportType = getStringValueById("exportType", call)
                        val decryptBeforeExporting = getBoolValueById("decryptBeforeExporting", call)

                        PLog.exportLogsForType(getExportType(exportType), exportDecrypted = decryptBeforeExporting)
                                .subscribeOn(Schedulers.io())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribeBy(
                                        onNext = {
                                            PLog.logThis(TAG, "exportPLogs", "PLogs Path: ${getParentPath(it)}", LogLevel.INFO)

                                            channel?.invokeMethod("logsExported", "${getParentPath(it)}")
                                        },
                                        onError = {
                                            it.printStackTrace()
                                            PLog.logThis(TAG, "exportPLogs", "PLog Error: " + it.message, LogLevel.ERROR)
                                            channel?.invokeMethod("logsExported", it.message)
                                        },
                                        onComplete = { }
                                )
                    }
                    "exportFileLogForName" -> {
                        val logFileName = getStringValueById("logFileName", call)
                        val decryptBeforeExporting = getBoolValueById("decryptBeforeExporting", call)

                        PLog.exportDataLogsForName(logFileName, exportDecrypted = decryptBeforeExporting)
                                .subscribeOn(Schedulers.io())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribeBy(
                                        onNext = {
                                            PLog.logThis(TAG, "exportFileLogForName", "DataLog Path: ${getParentPath(it)}", LogLevel.INFO)

                                            channel?.invokeMethod("logsExported", "${getParentPath(it)}")
                                        },
                                        onError = {
                                            it.printStackTrace()
                                            PLog.logThis(TAG, "exportFileLogForName", "DataLogger Error: " + it.message, LogLevel.ERROR)
                                            channel?.invokeMethod("logsExported", it.message)
                                        },
                                        onComplete = { }
                                )
                    }
                    "exportAllFileLogs" -> {
                        val decryptBeforeExporting = getBoolValueById("decryptBeforeExporting", call)

                        PLog.exportAllDataLogs(exportDecrypted = decryptBeforeExporting)
                                .subscribeOn(Schedulers.io())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribeBy(
                                        onNext = {
                                            PLog.logThis(TAG, "exportAllFileLogs", "DataLog Path: ${getParentPath(it)}", LogLevel.INFO)

                                            channel?.invokeMethod("logsExported", "${getParentPath(it)}")
                                        },
                                        onError = {
                                            it.printStackTrace()
                                            PLog.logThis(TAG, "exportAllFileLogs", "DataLogger Error: " + it.message, LogLevel.ERROR)
                                            channel?.invokeMethod("logsExported", it.message)
                                        },
                                        onComplete = { }
                                )
                    }
                    "printLogs" -> {
                        val exportType = getStringValueById("exportType", call)
                        val decryptBeforeExporting = getBoolValueById("decryptBeforeExporting", call)

                        PLog.printLogsForType(getExportType(exportType), printDecrypted = decryptBeforeExporting)
                                .subscribeOn(Schedulers.io())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribeBy(
                                        onNext = {
                                            Log.i("printLogs", it)

                                            channel?.invokeMethod("logsPrinted", it)
                                        },
                                        onError = {
                                            it.printStackTrace()
                                            PLog.logThis(TAG, "printLogs", "PLog Error: " + it.message, LogLevel.ERROR)
                                            channel?.invokeMethod("logsPrinted", it.message)
                                        },
                                        onComplete = { }
                                )
                    }
                    "printFileLogForName" -> {
                        val logFileName = getStringValueById("logFileName", call)
                        val decryptBeforeExporting = getBoolValueById("decryptBeforeExporting", call)

                        PLog.printDataLogsForName(logFileName, printDecrypted = decryptBeforeExporting)
                                .subscribeOn(Schedulers.io())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribeBy(
                                        onNext = {
                                            Log.i("printFileLogForName", it)

                                            channel?.invokeMethod("logsPrinted", it)
                                        },
                                        onError = {
                                            it.printStackTrace()
                                            PLog.logThis(TAG, "printFileLogForName", "DataLogger Error: " + it.message, LogLevel.ERROR)
                                            channel?.invokeMethod("logsPrinted", it.message)
                                        },
                                        onComplete = { }
                                )
                    }
                    "clearLogs" -> {
                        PLog.clearLogs()
                    }
                    else -> result.notImplemented()
                }
            }

            event_channel = EventChannel(messenger, "flutter_logs_plugin_stream")
            event_channel?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    //callBack?.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {

                }
            })
        }
        
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        currentActivity = null
        channel?.setMethodCallHandler(null)
        event_channel?.setStreamHandler(null)
    }

    override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
        currentActivity = activityPluginBinding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(activityPluginBinding: ActivityPluginBinding) {
        currentActivity = activityPluginBinding.activity
    }

    override fun onDetachedFromActivity() {
        currentActivity = null
    }

}
