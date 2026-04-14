package com.example.new_project_2025

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "save_drive/channel"

    private val CREATE_FILE_REQ = 5001
    private val PICK_JSON_REQUEST = 2001

    private var resultCallback: MethodChannel.Result? = null
    private var pendingPickResult: MethodChannel.Result? = null

    // ================================
    // ✅ SharedPreferences Keys
    // ================================
    private val PREF_BACKUP = "backup_prefs"
    private val KEY_LAST_URI = "last_backup_uri"

    private val PREF_LOGIN = "login_prefs"

    // ================================
    // 🚀 MethodChannel Setup
    // ================================
    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {

                    // =====================================
                    // 🔐 LOGIN STORAGE (ANDROID PREFS)
                    // =====================================
                    "saveLoginData" -> {
                        val status = call.argument<Int>("status") ?: 0
                        val token = call.argument<String>("token")
                        val userId = call.argument<String>("userid")

                        val prefs = getSharedPreferences(PREF_LOGIN, MODE_PRIVATE)
                        prefs.edit()
                            .putInt("status", status)
                            .putString("token", token)
                            .putString("userid", userId)
                            .apply()

                        result.success(true)
                    }

                    "getLoginData" -> {
                        val prefs = getSharedPreferences(PREF_LOGIN, MODE_PRIVATE)

                        val status = prefs.getInt("status", 0)
                        val token = prefs.getString("token", null)
                        val userId = prefs.getString("userid", null)

                        result.success(
                            mapOf(
                                "status" to status,
                                "token" to token,
                                "userid" to userId
                            )
                        )
                    }

                    "clearLoginData" -> {
                        val prefs = getSharedPreferences(PREF_LOGIN, MODE_PRIVATE)
                        prefs.edit().clear().apply()
                        result.success(true)
                    }

                    // =====================================
                    // 📁 CREATE FILE (SAF)
                    // =====================================
                    "createFile" -> {
                        resultCallback = result

                        val mime = call.argument<String>("mime") ?: "application/json"
                        val fileName = call.argument<String>("fileName") ?: "backup.json"

                        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = mime
                            putExtra(Intent.EXTRA_TITLE, fileName)
                        }

                        startActivityForResult(intent, CREATE_FILE_REQ)
                    }

                    // =====================================
                    // ✍️ WRITE FILE
                    // =====================================
                    "writeFile" -> {
                        val uri = call.argument<String>("uri")
                        val data = call.argument<String>("data") ?: ""

                        if (uri == null) {
                            result.error("NO_URI", "URI missing", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val output: OutputStream? =
                                contentResolver.openOutputStream(Uri.parse(uri))

                            output?.use {
                                it.write(data.toByteArray())
                            }

                            saveLastBackupUri(uri)

                            Log.d("Backup", "Saved URI: $uri")

                            result.success(true)

                        } catch (e: Exception) {
                            result.error("WRITE_ERROR", e.message, null)
                        }
                    }

                    // =====================================
                    // 📂 PICK JSON FILE
                    // =====================================
                    "pickFile" -> {
                        pendingPickResult = result

                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "application/json"
                        }

                        startActivityForResult(intent, PICK_JSON_REQUEST)
                    }

                    // =====================================
                    // 📖 READ FILE BY URI
                    // =====================================
                    "readFileByUri" -> {
                        val uriString = call.argument<String>("uri")

                        if (uriString == null) {
                            result.error("NO_URI", "URI missing", null)
                            return@setMethodCallHandler
                        }

                        val content = readFile(Uri.parse(uriString))

                        result.success(
                            mapOf(
                                "uri" to uriString,
                                "content" to content
                            )
                        )
                    }

                    // =====================================
                    // 🔄 AUTO RESTORE BACKUP
                    // =====================================
                    "getLastBackup" -> {
                        val lastUriString = getLastBackupUri()

                        if (lastUriString != null) {
                            try {
                                val uri = Uri.parse(lastUriString)

                                contentResolver.takePersistableUriPermission(
                                    uri,
                                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                                )

                                val content = readFile(uri)

                                Log.d("Backup", "Restored URI: $lastUriString")

                                result.success(content)

                            } catch (e: SecurityException) {
                                clearLastBackup()
                                result.success(null)

                            } catch (e: Exception) {
                                result.success(null)
                            }

                        } else {
                            result.success(null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // =====================================
    // 📌 SharedPreferences (Backup)
    // =====================================
    private fun saveLastBackupUri(uri: String) {
        val prefs = getSharedPreferences(PREF_BACKUP, MODE_PRIVATE)
        prefs.edit().putString(KEY_LAST_URI, uri).apply()
    }

    private fun getLastBackupUri(): String? {
        val prefs = getSharedPreferences(PREF_BACKUP, MODE_PRIVATE)
        return prefs.getString(KEY_LAST_URI, null)
    }

    private fun clearLastBackup() {
        val prefs = getSharedPreferences(PREF_BACKUP, MODE_PRIVATE)
        prefs.edit().remove(KEY_LAST_URI).apply()
    }

    // =====================================
    // 📖 READ FILE HELPER
    // =====================================
    private fun readFile(uri: Uri): String {
        val inputStream = contentResolver.openInputStream(uri)
        val reader = BufferedReader(InputStreamReader(inputStream))
        val builder = StringBuilder()

        var line: String? = reader.readLine()
        while (line != null) {
            builder.append(line).append("\n")
            line = reader.readLine()
        }

        reader.close()
        return builder.toString().trim()
    }

    // =====================================
    // 📌 ACTIVITY RESULT
    // =====================================
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        // CREATE FILE
        if (requestCode == CREATE_FILE_REQ) {
            if (resultCode == Activity.RESULT_OK && data?.data != null) {

                val uri = data.data!!

                contentResolver.takePersistableUriPermission(
                    uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                )

                saveLastBackupUri(uri.toString())

                resultCallback?.success(uri.toString())

            } else {
                resultCallback?.success(null)
            }

            resultCallback = null
            return
        }

        // PICK JSON FILE
        if (requestCode == PICK_JSON_REQUEST) {
            if (resultCode == Activity.RESULT_OK && data?.data != null) {

                val uri = data.data!!

                contentResolver.takePersistableUriPermission(
                    uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                )

                val json = readFile(uri)
                pendingPickResult?.success(json)

            } else {
                pendingPickResult?.success(null)
            }

            pendingPickResult = null
            return
        }
    }
}

//old code
////package com.example.new_project_2025
////
////import android.app.Activity
////import android.content.Intent
////import android.net.Uri
////import android.os.Bundle
////import io.flutter.embedding.android.FlutterActivity
////import io.flutter.plugin.common.MethodChannel
////import java.io.BufferedReader
////import java.io.InputStreamReader
////import java.io.OutputStream
////
////class MainActivity : FlutterActivity() {
////
////    private val CHANNEL = "save_drive/channel"
////
////    private val CREATE_FILE_REQ = 5001
////    private val OPEN_FILE_REQ = 5002
////
////    private val PICK_JSON_REQUEST = 2001
////
////    private var resultCallback: MethodChannel.Result? = null
////    private var pendingPickResult: MethodChannel.Result? = null
////
////    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
////        super.configureFlutterEngine(flutterEngine)
////
////        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
////            .setMethodCallHandler { call, result ->
////
////                when (call.method) {
////
////                    // --------------------------------------------------
////                    // 1️⃣ CREATE NEW FILE IN GOOGLE DRIVE (SAF)
////                    // --------------------------------------------------
////                    "createFile" -> {
////                        resultCallback = result
////
////                        val mime = call.argument<String>("mime") ?: "application/json"
////                        val fileName = call.argument<String>("fileName") ?: "backup.json"
////
////                        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
////                            addCategory(Intent.CATEGORY_OPENABLE)
////                            type = mime
////                            putExtra(Intent.EXTRA_TITLE, fileName)
////                        }
////
////                        startActivityForResult(intent, CREATE_FILE_REQ)
////                    }
////
////                    // --------------------------------------------------
////                    // 2️⃣ WRITE DATA TO FILE (URI from createFile)
////                    // --------------------------------------------------
////                    "writeFile" -> {
////                        val uri = call.argument<String>("uri")
////                        val data = call.argument<String>("data") ?: ""
////
////                        if (uri == null) {
////                            result.error("NO_URI", "URI missing", null)
////                            return@setMethodCallHandler
////                        }
////
////                        try {
////                            val output: OutputStream? =
////                                contentResolver.openOutputStream(Uri.parse(uri))
////
////                            output?.use { it.write(data.toByteArray()) }
////                            result.success(true)
////
////                        } catch (e: Exception) {
////                            result.error("WRITE_ERROR", e.message, null)
////                        }
////                    }
////
////                    // --------------------------------------------------
////                    // 3️⃣ OPEN FILE PICKER (ANY FILE)
////                    // --------------------------------------------------
////                    "openFile" -> {
////                        resultCallback = result
////
////                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
////                            addCategory(Intent.CATEGORY_OPENABLE)
////                            type = "*/*"
////                        }
////
////                        startActivityForResult(intent, OPEN_FILE_REQ)
////                    }
////
////                    // --------------------------------------------------
////                    // 4️⃣ PICK ONLY JSON FILE
////                    // --------------------------------------------------
////                    "pickFile" -> {
////                        pendingPickResult = result
////                        pickJsonFile()
////                    }
////                    "getLastBackup" -> {
////                        // For example: read the last saved JSON file URI from SharedPreferences
////                        val prefs = getSharedPreferences("backup_prefs", MODE_PRIVATE)
////                        val lastUriString = prefs.getString("last_backup_uri", null)
////
////                        if (lastUriString != null) {
////                            val content = readFile(Uri.parse(lastUriString))
////                            result.success(content)
////                        } else {
////                            result.success(null)
////                        }
////                    }
////                    // --------------------------------------------------
////                    // 5️⃣ READ FILE BY URI
////                    // --------------------------------------------------
////                    "readFileByUri" -> {
////                        val uriString = call.argument<String>("uri")
////                        val uri = Uri.parse(uriString)
////
////                        val content = readFile(uri)
////                        result.success(
////                            mapOf(
////                                "uri" to uriString,
////                                "content" to content
////                            )
////                        )
////                    }
////
////                    else -> result.notImplemented()
////                }
////            }
////    }
////
////    // --------------------------------------------------
////    // 📌 PICK ONLY JSON FILES
////    // --------------------------------------------------
////    private fun pickJsonFile() {
////        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
////            addCategory(Intent.CATEGORY_OPENABLE)
////            type = "application/json"
////        }
////        startActivityForResult(intent, PICK_JSON_REQUEST)
////    }
////
////    // --------------------------------------------------
////    // 📌 READ FILE HELPERS
////    // --------------------------------------------------
////    private fun readFile(uri: Uri): String {
////        val inputStream = contentResolver.openInputStream(uri)
////        val reader = BufferedReader(InputStreamReader(inputStream))
////        val builder = StringBuilder()
////
////        var line: String? = reader.readLine()
////        while (line != null) {
////            builder.append(line).append("\n")
////            line = reader.readLine()
////        }
////
////        reader.close()
////        return builder.toString().trim()
////    }
////
////    // --------------------------------------------------
////    // 📌 ACTIVITY RESULT HANDLER
////    // --------------------------------------------------
////    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
////        super.onActivityResult(requestCode, resultCode, data)
////
////        // --- CREATE FILE ---
////        if (requestCode == CREATE_FILE_REQ) {
////            resultCallback?.success(
////                if (resultCode == Activity.RESULT_OK) data?.data.toString()
////                else null
////            )
////            resultCallback = null
////            return
////        }
////
////        // --- OPEN ANY FILE ---
////        if (requestCode == OPEN_FILE_REQ) {
////            resultCallback?.success(
////                if (resultCode == Activity.RESULT_OK) data?.data.toString()
////                else null
////            )
////            resultCallback = null
////            return
////        }
////
////        // --- PICK JSON FILE ---
////        if (requestCode == PICK_JSON_REQUEST) {
////            if (resultCode == Activity.RESULT_OK && data?.data != null) {
////                val uri = data.data!!
////                val json = readFile(uri)
////                pendingPickResult?.success(json)
////            } else {
////                pendingPickResult?.success(null)
////            }
////            pendingPickResult = null
////            return
////        }
////    }
////}
//
//package com.example.new_project_2025
//
//import android.app.Activity
//import android.content.Intent
//import android.net.Uri
//import android.os.Bundle
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.plugin.common.MethodChannel
//import java.io.BufferedReader
//import java.io.InputStreamReader
//import java.io.OutputStream
//
//class MainActivity : FlutterActivity() {
//
//    private val CHANNEL = "save_drive/channel"
//    private val CREATE_FILE_REQ = 5001
//    private val PICK_JSON_REQUEST = 2001
//
//    private var resultCallback: MethodChannel.Result? = null
//    private var pendingPickResult: MethodChannel.Result? = null
//
//    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//            .setMethodCallHandler { call, result ->
//
//                when (call.method) {
//
//                    // --------------------------------------------------
//                    // 1️⃣ CREATE NEW FILE IN DRIVE
//                    // --------------------------------------------------
//                    "createFile" -> {
//                        resultCallback = result
//                        val mime = call.argument<String>("mime") ?: "application/json"
//                        val fileName = call.argument<String>("fileName") ?: "backup.json"
//
//                        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
//                            addCategory(Intent.CATEGORY_OPENABLE)
//                            type = mime
//                            putExtra(Intent.EXTRA_TITLE, fileName)
//                        }
//
//                        startActivityForResult(intent, CREATE_FILE_REQ)
//                    }
//
//                    // --------------------------------------------------
//                    // 2️⃣ WRITE DATA TO FILE
//                    // --------------------------------------------------
//                    "writeFile" -> {
//                        val uri = call.argument<String>("uri")
//                        val data = call.argument<String>("data") ?: ""
//
//                        if (uri == null) {
//                            result.error("NO_URI", "URI missing", null)
//                            return@setMethodCallHandler
//                        }
//
//                        try {
//                            val output: OutputStream? = contentResolver.openOutputStream(Uri.parse(uri))
//                            output?.use { it.write(data.toByteArray()) }
//
//                            // Save last URI in SharedPreferences for auto-restore
//                            val prefs = getSharedPreferences("backup_prefs", MODE_PRIVATE)
//                            prefs.edit().putString("last_backup_uri", uri).apply()
//
//                            result.success(true)
//
//                        } catch (e: Exception) {
//                            result.error("WRITE_ERROR", e.message, null)
//                        }
//                    }
//
//                    // --------------------------------------------------
//                    // 3️⃣ PICK JSON FILE
//                    // --------------------------------------------------
//                    "pickFile" -> {
//                        pendingPickResult = result
//                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
//                            addCategory(Intent.CATEGORY_OPENABLE)
//                            type = "application/json"
//                        }
//                        startActivityForResult(intent, PICK_JSON_REQUEST)
//                    }
//
//                    // --------------------------------------------------
//                    // 4️⃣ READ FILE BY URI
//                    // --------------------------------------------------
//                    "readFileByUri" -> {
//                        val uriString = call.argument<String>("uri")
//                        if (uriString == null) {
//                            result.error("NO_URI", "URI missing", null)
//                            return@setMethodCallHandler
//                        }
//                        val content = readFile(Uri.parse(uriString))
//                        result.success(mapOf("uri" to uriString, "content" to content))
//                    }
//
//                    // --------------------------------------------------
//                    // 5️⃣ GET LAST BACKUP
//                    // --------------------------------------------------
////                    "getLastBackup" -> {
////                        val prefs = getSharedPreferences("backup_prefs", MODE_PRIVATE)
////                        val lastUriString = prefs.getString("last_backup_uri", null)
////                        if (lastUriString != null) {
////                            val content = readFile(Uri.parse(lastUriString))
////                            result.success(content)
////                        } else {
////                            result.success(null)
////                        }
////                    }
//                    "getLastBackup" -> {
//                        val prefs = getSharedPreferences("backup_prefs", MODE_PRIVATE)
//                        val lastUriString = prefs.getString("last_backup_uri", null)
//
//                        if (lastUriString != null) {
//
//                            try {
//                                val uri = Uri.parse(lastUriString)
//
//                                // 🔥 Ensure persisted permission
//                                contentResolver.takePersistableUriPermission(
//                                    uri,
//                                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
//                                )
//
//                                val content = readFile(uri)     // Read JSON
//                                result.success(content)         // Return JSON to Flutter
//
//                            } catch (e: Exception) {
//                                result.success(null)
//                            }
//
//                        } else {
//                            result.success(null)
//                        }
//                    }
//                    else -> result.notImplemented()
//                }
//            }
//    }
//
//    private fun readFile(uri: Uri): String {
//        val inputStream = contentResolver.openInputStream(uri)
//        val reader = BufferedReader(InputStreamReader(inputStream))
//        val builder = StringBuilder()
//        var line: String? = reader.readLine()
//        while (line != null) {
//            builder.append(line).append("\n")
//            line = reader.readLine()
//        }
//        reader.close()
//        return builder.toString().trim()
//    }
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//
//        // CREATE FILE
//        if (requestCode == CREATE_FILE_REQ) {
//            if (resultCode == Activity.RESULT_OK && data?.data != null) {
//                val uri = data.data!!
//
//                // 🔥 IMPORTANT FIX: Persist permission
//                contentResolver.takePersistableUriPermission(
//                    uri,
//                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
//                )
//
//                resultCallback?.success(uri.toString())
//            } else {
//                resultCallback?.success(null)
//            }
//            resultCallback = null
//            return
//        }
//
//        // PICK JSON FILE
//        if (requestCode == PICK_JSON_REQUEST) {
//            if (resultCode == Activity.RESULT_OK && data?.data != null) {
//                val uri = data.data!!
//
//                // 🔥 FIX: Persist permission
//                contentResolver.takePersistableUriPermission(
//                    uri,
//                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
//                )
//
//                val json = readFile(uri)
//                pendingPickResult?.success(json)
//            } else {
//                pendingPickResult?.success(null)
//            }
//            pendingPickResult = null
//            return
//        }
//    }
////    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
////        super.onActivityResult(requestCode, resultCode, data)
////
////        // CREATE FILE
////        if (requestCode == CREATE_FILE_REQ) {
////            resultCallback?.success(if (resultCode == Activity.RESULT_OK) data?.data.toString() else null)
////            resultCallback = null
////            return
////        }
////
////        // PICK JSON FILE
////        if (requestCode == PICK_JSON_REQUEST) {
////            if (resultCode == Activity.RESULT_OK && data?.data != null) {
////                val uri = data.data!!
////                val json = readFile(uri)
////                pendingPickResult?.success(json)
////            } else {
////                pendingPickResult?.success(null)
////            }
////            pendingPickResult = null
////        }
////    }
//}
//
////package com.example.new_project_2025
////
////import android.app.Activity
////import android.content.Intent
////import android.net.Uri
////import android.os.Bundle
////import io.flutter.embedding.android.FlutterActivity
////import io.flutter.plugin.common.MethodChannel
////import java.io.BufferedReader
////import java.io.InputStreamReader
////import java.io.OutputStream
////
////class MainActivity : FlutterActivity() {
////
////    private val CHANNEL = "save_drive/channel"
////    private val CREATE_FILE_REQ = 5001
////    private val OPEN_FILE_REQ = 5002
////    private val PICK_JSON_REQUEST = 2001
////    private val CREATE_JSON_REQUEST = 2002
////
////
////    private var pendingPickResult: MethodChannel.Result? = null
////    private var resultCallback: MethodChannel.Result? = null
////    private var pendingAction: String? = null
////    private val SAVE_BACKUP_REQUEST = 202
////    private var backupBytes: ByteArray? = null
////    private var pendingSaveResult: MethodChannel.Result? = null
////    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
////        super.configureFlutterEngine(flutterEngine)
////
////        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
////            .setMethodCallHandler { call, result ->
////
////                when (call.method) {
////
////                    // ---------------------------
////                    // CREATE FILE
////                    // ---------------------------
////                    "createFile" -> {
////                        resultCallback = result
////                        pendingAction = "create"
////
////                        val mime = call.argument<String>("mime") ?: "application/json"
////                        val fileName = call.argument<String>("fileName") ?: "backup.json"
////
////                        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
////                            addCategory(Intent.CATEGORY_OPENABLE)
////                            type = mime
////                            putExtra(Intent.EXTRA_TITLE, fileName)
////                        }
////
////                        startActivityForResult(intent, CREATE_FILE_REQ)
////                    }
////
////                    // ---------------------------
////                    // WRITE FILE
////                    // ---------------------------
////                    "writeFile" -> {
////                        val uri = call.argument<String>("uri")
////                        val data = call.argument<String>("data") ?: ""
////
////                        if (uri == null) {
////                            result.error("NO_URI", "URI missing", null)
////                            return@setMethodCallHandler
////                        }
////
////                        try {
////                            val output: OutputStream? =
////                                contentResolver.openOutputStream(Uri.parse(uri))
////
////                            output?.use {
////                                it.write(data.toByteArray())
////                            }
////
////                            result.success(true)
////                        } catch (e: Exception) {
////                            result.error("WRITE_ERROR", e.message, null)
////                        }
////                    }
////
////                    // ---------------------------
////                    // OPEN FILE PICKER
////                    // ---------------------------
////                    "openFile" -> {
////                        resultCallback = result
////                        pendingAction = "open"
////
////                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
////                            addCategory(Intent.CATEGORY_OPENABLE)
////                            type = "*/*"
////                        }
////
////                        startActivityForResult(intent, OPEN_FILE_REQ)
////                    }
////
////
////
////                    "pickFile" -> {
////                        pendingPickResult = result
////                        pickJsonFile()
////                    }
////
////                    else -> result.notImplemented()
////                }
////                    // ---------------------------
////                    // READ FILE BY URI
////                    // ---------------------------
////                    "readFileByUri" -> {
////                        val uriString = call.argument<String>("uri")!!
////                        val uri = Uri.parse(uriString)
////
////                        val content = readFile(uri)
////                        result.success(
////                            mapOf(
////                                "uri" to uriString,
////                                "content" to content
////                            )
////                        )
////                    }
////
////                    else -> result.notImplemented()
////                }
////            }
////    }
////
////    // ---------------------------
////    // READ FILE HELPER
////    // ---------------------------
////    private fun readFile(uri: Uri): String {
////        val inputStream = contentResolver.openInputStream(uri)
////        val reader = BufferedReader(InputStreamReader(inputStream))
////        val builder = StringBuilder()
////
////        var line = reader.readLine()
////        while (line != null) {
////            builder.append(line).append("\n")
////            line = reader.readLine()
////        }
////
////        reader.close()
////        return builder.toString().trim()
////    }
////
////    // ---------------------------
////    // HANDLE RESULTS
////    // ---------------------------
////    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
////        super.onActivityResult(requestCode, resultCode, data)
////
////        if (requestCode == CREATE_FILE_REQ) {
////            resultCallback?.success(if (resultCode == Activity.RESULT_OK) data?.data.toString() else null)
////        }
////        if (requestCode == SAVE_BACKUP_REQUEST && resultCode == Activity.RESULT_OK) {
////            val uri: Uri? = data?.data
////            if (uri != null && backupBytes != null) {
////                val os = contentResolver.openOutputStream(uri)
////                os?.write(backupBytes)
////                os?.close()
////                pendingSaveResult?.success(true)
////            } else {
////                pendingSaveResult?.success(false)
////            }
////        }
////        if (requestCode == OPEN_FILE_REQ) {
////            resultCallback?.success(if (resultCode == Activity.RESULT_OK) data?.data.toString() else null)
////        }
////
////        resultCallback = null
////        pendingAction = null
////    }
////}
////
////
//////package com.example.new_project_2025
//////
//////import android.app.Activity
//////import android.content.Intent
//////import android.net.Uri
//////import android.os.Bundle
//////import io.flutter.embedding.android.FlutterActivity
//////import io.flutter.plugin.common.MethodChannel
//////import java.io.BufferedReader
//////import java.io.InputStreamReader
//////import java.io.OutputStream
//////
//////class MainActivity : FlutterActivity() {
//////
//////    private val CHANNEL = "save_drive/channel"
//////    private val CREATE_FILE_REQUEST_CODE = 5001
//////    private val OPEN_FILE_REQUEST_CODE = 5002
//////
//////    private var pendingResult: MethodChannel.Result? = null
//////    private var selectedUri: Uri? = null
//////
//////    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
//////        super.configureFlutterEngine(flutterEngine)
//////
//////        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//////            .setMethodCallHandler { call, result ->
//////
//////                when (call.method) {
//////
//////                    // 1️⃣ Create JSON file in Google Drive
//////                    "createFile" -> {
//////                        pendingResult = result
//////
//////                        val mime = call.argument<String>("mime") ?: "application/json"
//////                        val fileName = call.argument<String>("fileName") ?: "backup.json"
//////
//////                        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
//////                            addCategory(Intent.CATEGORY_OPENABLE)
//////                            type = mime
//////                            putExtra(Intent.EXTRA_TITLE, fileName)
//////                        }
//////
//////                        startActivityForResult(intent, CREATE_FILE_REQUEST_CODE)
//////                    }
//////
//////                    // 2️⃣ Write JSON to file
//////                    "writeFile" -> {
//////                        val uriString = call.argument<String>("uri")  // MUST be "uri"
//////                        val data = call.argument<String>("data") ?: ""
//////
//////                        if (uriString == null) {
//////                            result.error("NO_URI", "URI is null", null)
//////                            return@setMethodCallHandler
//////                        }
//////
//////                        try {
//////                            val uri = Uri.parse(uriString)
//////                            val outputStream: OutputStream? = contentResolver.openOutputStream(uri)
//////                            outputStream?.use {
//////                                it.write(data.toByteArray(Charsets.UTF_8))
//////                            }
//////                            result.success(true)
//////                        } catch (e: Exception) {
//////                            result.error("WRITE_ERROR", e.message, null)
//////                        }
//////                    }
//////
////////                    "writeFile" -> {
////////                        val uriString = call.argument<String>("uri")  // FIXED
////////                        val data = call.argument<String>("data") ?: ""
////////
////////                        if (uriString == null) {
////////                            result.error("NO_URI", "URI is null", null)
////////                            return@setMethodCallHandler
////////                        }
////////
////////                        try {
////////                            val uri = Uri.parse(uriString)
////////
////////                            val outputStream: OutputStream? = contentResolver.openOutputStream(uri)
////////                            outputStream?.use {
////////                                it.write(data.toByteArray(Charsets.UTF_8))
////////                            }
////////
////////                            result.success(true)
////////
////////                        } catch (e: Exception) {
////////                            result.error("WRITE_ERROR", e.message, null)
////////                        }
////////                    }
//////
//////                    // 3️⃣ Open previously saved file
//////                    "openFile" -> {
//////                        val uriString = call.argument<String>("uri")
//////
//////                        if (uriString == null) {
//////                            result.error("NO_URI", "Uri is missing", null)
//////                            return@setMethodCallHandler
//////                        }
//////
//////                        try {
//////                            val uri = Uri.parse(uriString)
//////
//////                            // Re-grant permissions
//////                            contentResolver.takePersistableUriPermission(
//////                                uri,
//////                                Intent.FLAG_GRANT_READ_URI_PERMISSION
//////                            )
//////
//////                            // Open Viewer
//////                            val intent = Intent(Intent.ACTION_VIEW).apply {
//////                                setDataAndType(uri, "application/json")
//////                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
//////                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//////                            }
//////
//////                            startActivity(intent)
//////                            result.success(true)
//////
//////                        } catch (e: Exception) {
//////                            result.error("OPEN_ERROR", e.message, null)
//////                        }
//////                    }
//////
//////                    // 4️⃣ Pick any file from Drive
//////                    "pickFile" -> {
//////                        pendingResult = result
//////                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
//////                            addCategory(Intent.CATEGORY_OPENABLE)
//////                            type = "application/json"
//////                        }
//////                        startActivityForResult(intent, OPEN_FILE_REQUEST_CODE)
//////                    }
//////
//////                    // 5️⃣ Read selected JSON file
//////                    "readFile" -> {
//////                        val uriString = call.argument<String>("uri")
//////
//////                        if (uriString == null) {
//////                            result.error("NO_URI", "URI is null", null)
//////                            return@setMethodCallHandler
//////                        }
//////
//////                        try {
//////                            val uri = Uri.parse(uriString)
//////                            val inputStream = contentResolver.openInputStream(uri)
//////
//////                            val reader = BufferedReader(InputStreamReader(inputStream, Charsets.UTF_8))
//////                            val text = reader.readText()
//////                            reader.close()
//////
//////                            result.success(text)
//////
//////                        } catch (e: Exception) {
//////                            result.error("READ_ERROR", e.message, null)
//////                        }
//////                    }
//////
//////                    else -> result.notImplemented()
//////                }
//////            }
//////    }
//////
//////    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//////        super.onActivityResult(requestCode, resultCode, data)
//////
//////        if (resultCode != Activity.RESULT_OK) {
//////            pendingResult?.success(null)
//////            pendingResult = null
//////            return
//////        }
//////
//////        val uri = data?.data ?: return
//////
//////        // save permission permanently
//////        contentResolver.takePersistableUriPermission(
//////            uri,
//////            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
//////        )
//////
//////        pendingResult?.success(uri.toString())
//////        pendingResult = null
//////    }
//////}
//////
//////
////////package com.example.new_project_2025
////////
////////import android.app.Activity
////////import android.content.Intent
////////import android.net.Uri
////////import android.os.Bundle
////////import io.flutter.embedding.android.FlutterActivity
////////import io.flutter.plugin.common.MethodChannel
////////import java.io.OutputStream
////////
////////class MainActivity : FlutterActivity() {
////////
////////    private val CHANNEL = "save_drive/channel"
////////
////////    private var createResult: MethodChannel.Result? = null
////////    private var openResult: MethodChannel.Result? = null
////////    private var writeResult: MethodChannel.Result? = null
////////    private var cachedData: String = ""
////////
////////    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
////////        super.configureFlutterEngine(flutterEngine)
////////
////////        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
////////            .setMethodCallHandler { call, result ->
////////
////////                when (call.method) {
////////
////////                    // 1️⃣ Create file in Google Drive
////////                    "createFile" -> {
////////                        createResult = result
////////                        val mime = call.argument<String>("mime")!!
////////                        val fileName = call.argument<String>("fileName")!!
////////
////////                        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
////////                            addCategory(Intent.CATEGORY_OPENABLE)
////////                            type = mime
////////                            putExtra(Intent.EXTRA_TITLE, fileName)
////////                        }
////////                        startActivityForResult(intent, 3000)
////////                    }
////////
////////                    // 2️⃣ Write JSON data to selected URI
////////                    "writeFile" -> {
////////                        writeResult = result
////////                        cachedData = call.argument<String>("data")!!
////////                        val uriString = call.argument<String>("uri")!!
////////                        writeToUri(Uri.parse(uriString))
////////                    }
////////
////////                    // 3️⃣ Open saved file
////////                    "openFile" -> {
////////                        openResult = result
////////                        val uriString = call.argument<String>("uri")!!
////////                        openUri(Uri.parse(uriString))
////////                        result.success(true)
////////                    }
////////                }
////////            }
////////    }
////////
////////    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
////////        if (requestCode == 3000 && resultCode == Activity.RESULT_OK) {
////////            val uri = data?.data.toString()
////////            createResult?.success(uri)
////////        } else {
////////            createResult?.success(null)
////////        }
////////        super.onActivityResult(requestCode, resultCode, data)
////////    }
////////
////////    private fun writeToUri(uri: Uri) {
////////        try {
////////            val outputStream: OutputStream? = contentResolver.openOutputStream(uri)
////////            outputStream?.write(cachedData.toByteArray())
////////            outputStream?.close()
////////            writeResult?.success(true)
////////        } catch (e: Exception) {
////////            writeResult?.error("WRITE_ERROR", e.message, null)
////////        }
////////    }
////////
////////    private fun openUri(uri: Uri) {
////////        val intent = Intent(Intent.ACTION_VIEW).apply {
////////            setDataAndType(uri, "application/json")
////////            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
////////        }
////////        startActivity(intent)
////////    }
////////}
