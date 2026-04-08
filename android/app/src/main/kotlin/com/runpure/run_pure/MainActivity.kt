package com.runpure.run_pure

import android.content.ComponentName
import android.content.ContentValues
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MediaStore 保存到相册
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.runpure.run_pure/media_store")
            .setMethodCallHandler { call, result ->
                if (call.method == "saveToGallery") {
                    val path = call.argument<String>("path") ?: return@setMethodCallHandler result.error("NO_PATH", "path is null", null)
                    val name = call.argument<String>("name") ?: "runpure.png"
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            // Android 10+ 使用 MediaStore API
                            val values = ContentValues().apply {
                                put(MediaStore.Images.Media.DISPLAY_NAME, name)
                                put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                                put(MediaStore.Images.Media.RELATIVE_PATH, "${Environment.DIRECTORY_PICTURES}/Solrun")
                                put(MediaStore.Images.Media.IS_PENDING, 1)
                            }
                            val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                            if (uri != null) {
                                contentResolver.openOutputStream(uri)?.use { output ->
                                    FileInputStream(File(path)).use { input ->
                                        input.copyTo(output)
                                    }
                                }
                                values.clear()
                                values.put(MediaStore.Images.Media.IS_PENDING, 0)
                                contentResolver.update(uri, values, null, null)
                            }
                        } else {
                            // Android 9 及以下直接写文件
                            val dir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "Solrun")
                            if (!dir.exists()) dir.mkdirs()
                            val dest = File(dir, name)
                            File(path).copyTo(dest, overwrite = true)
                            MediaScannerConnection.scanFile(this, arrayOf(dest.absolutePath), arrayOf("image/png"), null)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        // 自启动管理引导
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.runpure.run_pure/autostart")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getManufacturer" -> {
                        result.success(Build.MANUFACTURER)
                    }
                    "openActivity" -> {
                        val pkg = call.argument<String>("package")
                        val cls = call.argument<String>("class")
                        if (pkg != null && cls != null) {
                            try {
                                val intent = Intent().apply {
                                    component = ComponentName(pkg, cls)
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    "openAppSettings" -> {
                        try {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.fromParts("package", packageName, null)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // ── GPS 原生前台服务控制 ──
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.runpure.run_pure/gps")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startTracking" -> {
                        val intent = Intent(this, RunLocationService::class.java).apply {
                            action = RunLocationService.ACTION_START
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    }
                    "stopTracking" -> {
                        val intent = Intent(this, RunLocationService::class.java).apply {
                            action = RunLocationService.ACTION_STOP
                        }
                        startService(intent)
                        result.success(true)
                    }
                    "isRunning" -> {
                        result.success(RunLocationService.isRunning())
                    }
                    else -> result.notImplemented()
                }
            }

        // ── GPS 数据流（EventChannel）──
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.runpure.run_pure/gps_stream")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    RunLocationService.onLocationPoint = { pointMap ->
                        runOnUiThread {
                            events?.success(pointMap)
                        }
                    }
                }
                override fun onCancel(arguments: Any?) {
                    RunLocationService.onLocationPoint = null
                }
            })

        // MediaScanner 回退方案
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.runpure.run_pure/media_scanner")
            .setMethodCallHandler { call, result ->
                if (call.method == "scan") {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        MediaScannerConnection.scanFile(this, arrayOf(path), arrayOf("image/png"), null)
                    }
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
    }
}
