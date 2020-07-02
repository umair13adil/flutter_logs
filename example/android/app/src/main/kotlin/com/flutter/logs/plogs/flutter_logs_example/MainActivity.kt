package com.flutter.logs.plogs.flutter_logs_example

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger

class MainActivity : FlutterActivity() , FlutterLogsPlugin.Companion.PluginImpl {

    private val TAG = "FlutterLogs"
    private val REQUEST_STORAGE_PERMISSIONS = 1324

    companion object {

        @JvmStatic
        var mFlutterEngine: FlutterEngine? = null

        @JvmStatic
        var binaryMessenger: BinaryMessenger? = null
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.let {
            mFlutterEngine = flutterEngine

            it.dartExecutor.binaryMessenger.let { messenger ->
                binaryMessenger = messenger
                FlutterLogsPlugin.registerWith(messenger, this, this)
            }
        }
    }

    private fun areStoragePermissionsGranted(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
    }

    override fun requestStoragePermission() {
        if (!areStoragePermissionsGranted()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), REQUEST_STORAGE_PERMISSIONS)
            } else {
                FlutterLogsPlugin.doIfPermissionsGranted()
            }
        } else {
            FlutterLogsPlugin.doIfPermissionsGranted()
        }
    }

    override fun onRequestPermissionsResult(
            requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        if (requestCode == REQUEST_STORAGE_PERMISSIONS && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            FlutterLogsPlugin.doIfPermissionsGranted()
        }
    }
}
