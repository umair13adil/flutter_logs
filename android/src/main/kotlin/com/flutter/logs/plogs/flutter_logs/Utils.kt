package com.flutter.logs.plogs.flutter_logs

import com.blackbox.plog.pLogs.exporter.ExportType
import com.blackbox.plog.pLogs.formatter.TimeStampFormat
import com.blackbox.plog.pLogs.models.LogExtension
import com.blackbox.plog.pLogs.models.LogLevel
import com.blackbox.plog.pLogs.structure.DirectoryStructure
import io.flutter.plugin.common.MethodCall
import java.io.ByteArrayInputStream
import java.io.File
import java.io.InputStream

fun getLogLevelsById(key: String, call: MethodCall): ArrayList<LogLevel> {
    val listOfLogLevels = arrayListOf<LogLevel>()
    call.argument<String>(key)?.let {
        it.split(",").forEach {
            listOfLogLevels.add(getLogLevel(it))
        }
        return listOfLogLevels
    }
    return arrayListOf()
}

fun getListOfStringById(key: String, call: MethodCall): ArrayList<String> {
    val logTypesList = arrayListOf<String>()
    call.argument<String>(key)?.let {
        it.split(",").forEach {
            logTypesList.add(it)
        }
        return logTypesList
    }
    return arrayListOf()
}

fun getStringValueById(key: String, call: MethodCall): String {
    call.argument<String>(key)?.let {
        return it
    }
    return ""
}

fun getIntValueById(key: String, call: MethodCall): Int? {
    call.argument<Int>(key)?.let {
        return it
    }
    return null
}

fun getBoolValueById(key: String, call: MethodCall): Boolean {
    call.argument<Boolean>(key)?.let {
        return it
    }
    return false
}

fun getInputStreamValueById(key: String, call: MethodCall): InputStream? {
    call.argument<ByteArray>(key)?.let {
        return ByteArrayInputStream(it)
    }
    return null
}


fun getDirectoryStructure(type: String?): DirectoryStructure {
    when (type) {
        "FOR_DATE" -> {
            return DirectoryStructure.FOR_DATE
        }
        "FOR_EVENT" -> {
            return DirectoryStructure.FOR_EVENT
        }
        "SINGLE_FILE_FOR_DAY" -> {
            return DirectoryStructure.SINGLE_FILE_FOR_DAY
        }
    }
    return DirectoryStructure.SINGLE_FILE_FOR_DAY
}

fun getLogFileExtension(type: String?): String {
    when (type) {
        "TXT" -> {
            return LogExtension.TXT
        }
        "CSV" -> {
            return LogExtension.CSV
        }
        "LOG" -> {
            return LogExtension.LOG
        }
        "NONE" -> {
            return LogExtension.NONE
        }
    }
    return LogExtension.LOG
}

fun getLogLevel(type: String?): LogLevel {
    when (type) {
        "INFO" -> {
            return LogLevel.INFO
        }
        "WARNING" -> {
            return LogLevel.WARNING
        }
        "ERROR" -> {
            return LogLevel.ERROR
        }
        "SEVERE" -> {
            return LogLevel.SEVERE
        }
    }
    return LogLevel.INFO
}

fun getExportType(type: String?): ExportType {
    when (type) {
        "TODAY" -> {
            return ExportType.TODAY
        }
        "LAST_HOUR" -> {
            return ExportType.LAST_HOUR
        }
        "WEEKS" -> {
            return ExportType.WEEKS
        }
        "LAST_24_HOURS" -> {
            return ExportType.LAST_24_HOURS
        }
        "ALL" -> {
            return ExportType.ALL
        }
    }
    return ExportType.ALL
}

fun getTimeStampFormat(type: String?): String {
    when (type) {
        "DATE_FORMAT_1" -> {
            return TimeStampFormat.DATE_FORMAT_1
        }
        "DATE_FORMAT_2" -> {
            return TimeStampFormat.DATE_FORMAT_2
        }
        "TIME_FORMAT_FULL_JOINED" -> {
            return TimeStampFormat.TIME_FORMAT_FULL_JOINED
        }
        "TIME_FORMAT_FULL_1" -> {
            return TimeStampFormat.TIME_FORMAT_FULL_1
        }
        "TIME_FORMAT_FULL_2" -> {
            return TimeStampFormat.TIME_FORMAT_FULL_2
        }
        "TIME_FORMAT_24_FULL" -> {
            return TimeStampFormat.TIME_FORMAT_24_FULL
        }
        "TIME_FORMAT_READABLE" -> {
            return TimeStampFormat.TIME_FORMAT_READABLE
        }
        "TIME_FORMAT_READABLE_2" -> {
            return TimeStampFormat.TIME_FORMAT_READABLE_2
        }
        "TIME_FORMAT_SIMPLE" -> {
            return TimeStampFormat.TIME_FORMAT_SIMPLE
        }
    }
    return TimeStampFormat.TIME_FORMAT_24_FULL
}

fun getParentPath(path: String): String {
    val parentFile = File(path)
    return "${LogsHelper.savePathProvided}${File.separator}${LogsHelper.exportPathProvided}${File.separator}${parentFile.name}"
}