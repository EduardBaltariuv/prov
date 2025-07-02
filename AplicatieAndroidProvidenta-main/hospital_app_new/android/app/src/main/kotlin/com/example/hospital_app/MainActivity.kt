package com.example.hospital_app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.hospital_app/ota_update"
    private val TAG = "OTA_UPDATE"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "installApk" -> {
                    val apkPath = call.argument<String>("apkPath")
                    if (apkPath != null) {
                        installApk(apkPath, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "APK path is required", null)
                    }
                }
                "canInstallFromUnknownSources" -> {
                    result.success(canInstallFromUnknownSources())
                }
                "openInstallPermissionSettings" -> {
                    openInstallPermissionSettings()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun installApk(apkPath: String, result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Attempting to install APK at path: $apkPath")
            
            val apkFile = File(apkPath)
            if (!apkFile.exists()) {
                Log.e(TAG, "APK file not found at path: $apkPath")
                result.error("FILE_NOT_FOUND", "APK file not found at path: $apkPath", null)
                return
            }

            val fileSize = apkFile.length()
            Log.d(TAG, "APK file size: $fileSize bytes")
            
            if (fileSize == 0L) {
                Log.e(TAG, "APK file is empty")
                result.error("FILE_EMPTY", "APK file is empty", null)
                return
            }

            // Check if we can install from unknown sources
            if (!canInstallFromUnknownSources()) {
                Log.w(TAG, "Cannot install from unknown sources")
                result.error("PERMISSION_DENIED", "Installation from unknown sources not allowed", null)
                return
            }

            val intent = Intent(Intent.ACTION_VIEW)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                try {
                    val apkUri = FileProvider.getUriForFile(
                        this,
                        "${packageName}.fileprovider",
                        apkFile
                    )
                    Log.d(TAG, "Created FileProvider URI: $apkUri")
                    intent.setDataAndType(apkUri, "application/vnd.android.package-archive")
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                } catch (e: IllegalArgumentException) {
                    Log.e(TAG, "Failed to create FileProvider URI: ${e.message}")
                    result.error("FILEPROVIDER_ERROR", "Failed to create FileProvider URI: ${e.message}", null)
                    return
                }
            } else {
                val fileUri = Uri.fromFile(apkFile)
                Log.d(TAG, "Created file URI: $fileUri")
                intent.setDataAndType(fileUri, "application/vnd.android.package-archive")
            }

            Log.d(TAG, "Starting install activity with intent: ${intent.data}")
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to install APK: ${e.message}", e)
            result.error("INSTALL_ERROR", "Failed to install APK: ${e.message}", null)
        }
    }

    private fun canInstallFromUnknownSources(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageManager.canRequestPackageInstalls()
        } else {
            @Suppress("DEPRECATION")
            Settings.Secure.getInt(contentResolver, Settings.Secure.INSTALL_NON_MARKET_APPS, 0) == 1
        }
    }

    private fun openInstallPermissionSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
            intent.data = Uri.parse("package:$packageName")
            startActivity(intent)
        } else {
            val intent = Intent(Settings.ACTION_SECURITY_SETTINGS)
            startActivity(intent)
        }
    }
}
