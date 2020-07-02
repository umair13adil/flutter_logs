package com.flutter.logs.plogs.flutter_logs_example

import android.content.Context
import android.os.Environment
import android.util.Log
import com.blackbox.plog.elk.PLogMetaInfoProvider
import com.blackbox.plog.elk.models.fields.MetaInfo
import com.blackbox.plog.mqtt.PLogMQTTProvider
import com.blackbox.plog.pLogs.PLog
import com.blackbox.plog.pLogs.config.LogsConfig
import com.blackbox.plog.pLogs.models.LogLevel
import com.blackbox.plog.utils.DateTimeUtils
import java.io.File
import java.io.InputStream


object LogsHelper {

    private val TAG = "LogsHelper"

    fun setUpLogger(logLevelsEnabled: ArrayList<LogLevel>,
                    logTypesEnabled: ArrayList<String>,
                    logsRetentionPeriodInDays: Int?,
                    zipsRetentionPeriodInDays: Int?,
                    autoDeleteZipOnExport: Boolean?,
                    autoClearLogs: Boolean?,
                    autoExportErrors: Boolean?,
                    encryptionEnabled: Boolean?,
                    encryptionKey: String?,
                    directoryStructure: String?,
                    logSystemCrashes: Boolean?,
                    isDebuggable: Boolean?,
                    debugFileOperations: Boolean?,
                    attachTimeStamp: Boolean?,
                    attachNoOfFiles: Boolean?,
                    timeStampFormat: String?,
                    logFileExtension: String?,
                    zipFilesOnly: Boolean?,
                    savePath: String?,
                    zipFileName: String?,
                    exportPath: String?,
                    singleLogFileSize: Int?,
                    enabled: Boolean?) {

        val config = LogsConfig(
                logLevelsEnabled = logLevelsEnabled,
                logTypesEnabled = logTypesEnabled,
                logsRetentionPeriodInDays = logsRetentionPeriodInDays ?: 7,
                zipsRetentionPeriodInDays = zipsRetentionPeriodInDays ?: 7,
                autoDeleteZipOnExport = autoDeleteZipOnExport ?: false,
                autoClearLogs = autoClearLogs ?: false,
                autoExportErrors = autoExportErrors ?: false,
                encryptionEnabled = encryptionEnabled ?: false,
                encryptionKey = encryptionKey ?: "",
                directoryStructure = getDirectoryStructure(directoryStructure),
                logSystemCrashes = logSystemCrashes ?: false,
                isDebuggable = isDebuggable ?: false,
                debugFileOperations = debugFileOperations ?: false,
                attachTimeStamp = attachTimeStamp ?: false,
                attachNoOfFiles = attachNoOfFiles ?: false,
                timeStampFormat = getTimeStampFormat(timeStampFormat),
                logFileExtension = getLogFileExtension(logFileExtension),
                zipFilesOnly = zipFilesOnly ?: false,
                savePath = createDir(savePath),
                zipFileName = zipFileName ?: "",
                exportPath = createDir(exportPath),
                singleLogFileSize = singleLogFileSize ?: 1,
                enabled = enabled ?: true
        )

        PLog.applyConfigurations(config, saveToFile = true)
    }

    fun writeLogToFile(type: String, data: String?, appendTimeStamp: Boolean) {
        try {
            if (appendTimeStamp) {
                PLog.getLoggerFor(type)
                        ?.appendToFile("$data [${DateTimeUtils.getTimeFormatted()}]")
            } else {
                PLog.getLoggerFor(type)
                        ?.appendToFile("$data")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun overWriteLogToFile(type: String, data: String?, appendTimeStamp: Boolean) {
        try {
            if (appendTimeStamp) {
                PLog.getLoggerFor(type)?.overwriteToFile("$data [${DateTimeUtils.getTimeFormatted()}]")
            } else {
                PLog.getLoggerFor(type)?.overwriteToFile(data!!)
            }
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }
    }

    fun setupForELKStack(appId: String?,
                         appName: String?,
                         appVersion: String?,
                         deviceId: String?,
                         environmentId: String?,
                         environmentName: String?,
                         organizationId: String?,
                         language: String?,
                         userId: String?,
                         userName: String?,
                         userEmail: String?,
                         deviceSerial: String?,
                         deviceBrand: String?,
                         deviceName: String?,
                         deviceManufacturer: String?,
                         deviceModel: String?,
                         deviceSdkInt: String?) {
        PLogMetaInfoProvider.elkStackSupported = true

        PLogMetaInfoProvider.setMetaInfo(
                MetaInfo(
                        appId = appId ?: "",
                        appName = appName ?: "",
                        appVersion = appVersion ?: "",
                        deviceId = deviceId ?: "",
                        environmentId = environmentId ?: "",
                        environmentName = environmentName ?: "",
                        organizationId = organizationId ?: "",
                        language = language ?: "",
                        userId = userId ?: "",
                        userName = userName ?: "",
                        userEmail = userEmail ?: "",
                        deviceSerial = deviceSerial ?: "",
                        deviceBrand = deviceBrand ?: "",
                        deviceName = deviceName ?: "",
                        deviceManufacturer = deviceManufacturer ?: "",
                        deviceModel = deviceModel ?: "",
                        deviceSdkInt = deviceSdkInt ?: ""
                )
        )
    }

    fun setMQTT(
            context: Context,
            writeLogsToLocalStorage: Boolean?,
            topic: String?,
            brokerUrl: String,
            certificateInputStream: InputStream?,
            clientId: String?,
            port: String?,
            qos: Int?,
            retained: Boolean?

    ) {
        if (brokerUrl.isNotEmpty()) {
            PLogMQTTProvider.initMQTTClient(context,
                    writeLogsToLocalStorage = writeLogsToLocalStorage ?: true,
                    topic = topic ?: "",
                    brokerUrl = brokerUrl ?: "",
                    certificateStream = certificateInputStream,
                    clientId = clientId ?: "",
                    port = port ?: "",
                    qos = qos ?: 0,
                    retained = retained ?: false
            )
        }
    }

    private fun createDir(pathName: String?): String {
        val file = File(Environment.getExternalStorageDirectory().toString() + File.separator + pathName)
        return if (!file.exists()) {
            val result = file.mkdirs()
            Log.i(TAG, "Path: ${file.path}, Result: $result")
            file.path
        } else file.path
    }
}