package com.jeydolen.take_your_meds

import android.Manifest
import android.content.ContentValues
import android.os.Build
import android.os.Build.VERSION
import android.os.Environment
import android.webkit.MimeTypeMap
import java.io.File
import java.io.IOException
import java.io.InputStream
import android.content.Intent
import android.content.pm.PackageManager
import android.widget.Toast

import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.jeydolen.take_your_meds"
  private val WRITE_EXTERNAL_STORAGE = Manifest.permission.WRITE_EXTERNAL_STORAGE;
  private val WRITE_REQUEST_CODE = 1;
  private val READ_EXTERNAL_STORAGE = Manifest.permission.READ_EXTERNAL_STORAGE;
  private val READ_REQUEST_CODE = 2;
  private var temp_path = "";
  private var channelRes :  MethodChannel.Result? = null;

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      when (call.method) {
        "addItem" -> {
      
          // No need to ask permission with API under 22
          if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.LOLLIPOP) {
            askPermission(WRITE_EXTERNAL_STORAGE, WRITE_REQUEST_CODE);
          }
          
          if (hasPermission(WRITE_EXTERNAL_STORAGE)) {
            addItem(call.argument("path")!!, call.argument("name")!!)
            result.success(null)
          }
          else {
            showPermissionError()
            if (VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
              askPermission(WRITE_EXTERNAL_STORAGE, WRITE_REQUEST_CODE);
            }
          }
        }

        "importItem" -> {
          channelRes = result;

          // No need to ask permission with API under 22
          if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.LOLLIPOP) {
            askPermission(READ_EXTERNAL_STORAGE, READ_REQUEST_CODE);
          }

          if (hasPermission(READ_EXTERNAL_STORAGE)) {
            importItem();
          }
          else {
            showPermissionError()
            if (VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
              askPermission(READ_EXTERNAL_STORAGE, READ_REQUEST_CODE);
            }
          }
        }
      }
    }
  }

  private fun showPermissionError() {
    val text = "Permission Denied!\n You have to permit access to external files";
    Toast.makeText(activity, text, Toast.LENGTH_SHORT).show();
  }

  private fun askPermission(permission: String, permissionRequestCode: Int) {
    val PERMISSIONS = Array<String>(1) { permission };
    ActivityCompat.requestPermissions(activity, PERMISSIONS, permissionRequestCode);
  }

  private fun hasPermission(permission: String) : Boolean {
    if (ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED) {
      return true;
    }

    return false;
  }

  private fun addItem(path: String, fileName: String) {
    // Didn't found any better way yet.
    this.temp_path = path;

    val extension = MimeTypeMap.getFileExtensionFromUrl(path)
    var mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)

    // Fallback
    if (mimeType == null) {
      mimeType = "*/*";
    }

    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT);
    intent.setType(mimeType);
    intent.putExtra(Intent.EXTRA_TITLE, fileName);
    startActivityForResult(intent, WRITE_REQUEST_CODE);
  }

  private fun importItem() {
    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT);
    intent.setType("application/json");
    startActivityForResult(intent, READ_REQUEST_CODE);
  }


  
  override fun onActivityResult(requestCode : Int, resultCode : Int, data : Intent?) {
    super.onActivityResult(requestCode, resultCode, data);
    if (resultCode == RESULT_CANCELED || data == null) {
      return;
    }

    if (resultCode == RESULT_OK) {
      if (requestCode == WRITE_REQUEST_CODE) {
        val uri = data.getData();
        if (uri == null) {
          return;
        }
  
        if (temp_path == "") {
          return;
        }
        
        getContentResolver().openOutputStream(uri).use { 
          os -> File(temp_path).inputStream().use { it.copyTo(os!!) }
        }
      }
      
      if (requestCode == READ_REQUEST_CODE) {
        val uri = data.getData();
        if (uri == null) {
          return;
        }

        val iS = getContentResolver().openInputStream(uri);

        if (iS == null) {
          return;
        }

        val byteArr = iS.readBytes()

        channelRes!!.success(String(byteArr));
      }
    }
  }
}
