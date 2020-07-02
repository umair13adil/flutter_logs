package com.flutter.logs.plogs.flutter_logs_example

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import com.blackbox.plog.pLogs.PLog
import com.blackbox.plog.pLogs.impl.PLogImpl
import com.blackbox.plog.pLogs.models.LogLevel
import com.blackbox.plog.pLogs.models.LogType
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.lang.Exception

class MainActivity : FlutterActivity() {

    private val TAG = "MainActivity"
    private val REQUEST_STORAGE_PERMISSIONS = 1324

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    companion object {
        private var channel: MethodChannel? = null
        private var eventChannel: EventChannel? = null
        var eventSink: EventChannel.EventSink? = null

        @JvmStatic
        var mFlutterEngine: FlutterEngine? = null

        @JvmStatic
        var binaryMessenger: BinaryMessenger? = null
    }

    private fun registerWith(messenger: BinaryMessenger?) {
        messenger?.let {
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

                        LogsHelper.setMQTT(this,
                                writeLogsToLocalStorage = true,
                                topic = topic,
                                brokerUrl = brokerUrl,
                                certificateInputStream = certificate,
                                clientId = clientId)

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
                        val userId = getStringValueById("userId", call)
                        val userName = getStringValueById("userName", call)
                        val userEmail = getStringValueById("userEmail", call)
                        val deviceSerial = getStringValueById("deviceSerial", call)
                        val deviceBrand = getStringValueById("deviceBrand", call)
                        val deviceName = getStringValueById("deviceName", call)
                        val deviceManufacturer = getStringValueById("deviceManufacturer", call)
                        val deviceModel = getStringValueById("deviceModel", call)
                        val deviceSdkInt = getStringValueById("deviceSdkInt", call)
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
                                language = language,
                                userId = userId,
                                userName = userName,
                                userEmail = userEmail,
                                deviceSerial = deviceSerial,
                                deviceBrand = deviceBrand,
                                deviceName = deviceName,
                                deviceManufacturer = deviceManufacturer,
                                deviceModel = deviceModel,
                                deviceSdkInt = deviceSdkInt
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
                                    PLog.logThis(tag, subTag, logMessage, Exception(exception), LogLevel.ERROR)
                                } else {
                                    PLog.logThis(tag, subTag, logMessage, LogLevel.ERROR)
                                }
                            }
                            LogLevel.SEVERE -> {
                                if (exception.isNotEmpty()) {
                                    PLog.logThis(tag, subTag, logMessage, Exception(exception), LogLevel.SEVERE)
                                } else {
                                    PLog.logThis(tag, subTag, logMessage, LogLevel.SEVERE)
                                }
                            }
                        }
                    }
                    "exportLogs" -> {
                        eventSink?.endOfStream()
                        eventSink = null
                        result.success("Logs exported.")
                    }
                    else -> result.notImplemented()
                }
            }

            eventChannel = EventChannel(messenger, "flutter_logs_stream")
            eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {

                }
            })
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        requestStoragePermission()

        flutterEngine?.let {
            mFlutterEngine = flutterEngine

            it.dartExecutor.binaryMessenger.let { messenger ->
                binaryMessenger = messenger
                registerWith(messenger)
            }
        }
    }


    private fun requestStoragePermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), REQUEST_STORAGE_PERMISSIONS)
            } else {
                doIfPermissionsGranted()
            }
        } else {
            doIfPermissionsGranted()
        }
    }

    override fun onRequestPermissionsResult(
            requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        if (requestCode == REQUEST_STORAGE_PERMISSIONS && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            doIfPermissionsGranted()
        }
    }

    private fun doIfPermissionsGranted() {
        Log.i(TAG, "doIfPermissionsGranted: Send event.")
        channel?.invokeMethod("storagePermissionsGranted", "")
    }
}
