package com.flutter.logs.plogs.flutter_logs_example

import android.util.Log
import io.flutter.plugin.common.MethodCall
import java.io.ByteArrayInputStream
import java.io.InputStream

fun getStringValueById(key: String, call: MethodCall): String? {
    call.argument<String>(key)?.let {
        if (it.isNotEmpty())
            Log.i("getStringValueById", "$key: $it")
        return it
    }
    return null
}

fun getIntValueById(key: String, call: MethodCall): Int? {
    call.argument<Int>(key)?.let {
        Log.i("getIntValueById", "$key: $it")
        return it
    }
    return null
}

fun getBoolValueById(key: String, call: MethodCall): Boolean? {
    call.argument<Boolean>(key)?.let {
        Log.i("getBoolValueById", "$key: $it")
        return it
    }
    return null
}

fun getInputStreamValueById(key: String, call: MethodCall): InputStream? {
    call.argument<ByteArray>(key)?.let {
        return ByteArrayInputStream(it)
    }
    return null
}