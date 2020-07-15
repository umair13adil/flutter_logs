package com.flutter.logs.plogs.flutter_logs

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Environment
import android.util.Log
import androidx.core.content.ContextCompat
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

    fun setUpLogger(context: Context, logLevelsEnabled: ArrayList<LogLevel>,
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

        if (!permissionsGranted(context)) {
            Log.e(TAG, "setUpLogger: Unable to setup logs. Permissions not granted.")
            return
        }

        createDir(savePath + File.separator + "Logs")

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

        PLog.applyConfigurations(config, saveToFile = true, context = context)
    }

    fun writeLogToFile(context: Context, type: String, data: String?, appendTimeStamp: Boolean) {

        if (!permissionsGranted(context)) {
            Log.e(TAG, "writeLogToFile: Unable to setup logs. Permissions not granted.")
            return
        }

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

    fun overWriteLogToFile(context: Context, type: String, data: String?, appendTimeStamp: Boolean) {

        if (!permissionsGranted(context)) {
            Log.e(TAG, "overWriteLogToFile: Unable to setup logs. Permissions not granted.")
            return
        }

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

    fun setupForELKStack(context: Context,
                         appId: String?,
                         appName: String?,
                         appVersion: String?,
                         deviceId: String?,
                         environmentId: String?,
                         environmentName: String?,
                         organizationId: String?,
                         organizationUnitId: String?,
                         language: String?,
                         userId: String?,
                         userName: String?,
                         userEmail: String?,
                         deviceSerial: String?,
                         deviceBrand: String?,
                         deviceName: String?,
                         deviceManufacturer: String?,
                         deviceModel: String?,
                         deviceSdkInt: String?,
                         deviceBatteryPercent: String?,
                         latitude: String?,
                         longitude: String?,
                         labels: String?
    ) {

        if (!permissionsGranted(context)) {
            Log.e(TAG, "setupForELKStack: Unable to setup logs. Permissions not granted.")
            return
        }

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
                        organizationUnitId = organizationUnitId ?: "",
                        language = language ?: "",
                        userId = userId ?: "",
                        userName = userName ?: "",
                        userEmail = userEmail ?: "",
                        deviceSerial = deviceSerial ?: "",
                        deviceBrand = deviceBrand ?: "",
                        deviceName = deviceName ?: "",
                        deviceManufacturer = deviceManufacturer ?: "",
                        deviceModel = deviceModel ?: "",
                        deviceSdkInt = deviceSdkInt ?: "",
                        batteryPercent = deviceBatteryPercent ?: "",
                        latitude = latitude?.toDouble() ?: 0.0,
                        longitude = longitude?.toDouble() ?: 0.0
                        //labels = labels ?: ""
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
            retained: Boolean?,
            debug: Boolean?,
            initialDelaySecondsForPublishing: Int?

    ) {
        if (!permissionsGranted(context)) {
            Log.e(TAG, "setMQTT: Unable to setup logs. Permissions not granted.")
            return
        }

        if (brokerUrl.isNotEmpty()) {
            PLogMQTTProvider.initMQTTClient(context,
                    writeLogsToLocalStorage = writeLogsToLocalStorage ?: true,
                    topic = topic ?: "",
                    brokerUrl = brokerUrl ?: "",
                    certificateStream = certificateInputStream,
                    clientId = clientId ?: "",
                    port = port ?: "",
                    qos = qos ?: 0,
                    retained = retained ?: false,
                    debug = debug ?: true,
                    initialDelaySecondsForPublishing = initialDelaySecondsForPublishing?.toLong() ?: 30L
            )
        }
    }

    private fun createDir(pathName: String?): String {
        val file = File(Environment.getExternalStorageDirectory().toString() + File.separator + pathName)
        return if (!file.exists()) {
            val result = file.mkdirs()
            file.path
        } else file.path
    }

    fun permissionsGranted(context: Context): Boolean {
        return ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
    }
}