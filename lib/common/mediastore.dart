import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

// Class where we call platform specific API about MediaStore
// (https://developer.android.com/reference/android/provider/MediaStore)
class MediaStore {
  static const _channel = MethodChannel("com.jeydolen.take_your_meds");

  static Future<void> addItem(
      {required File file, required String name}) async {
    await _channel.invokeMethod('addItem', {'path': file.path, 'name': name});
  }

  static Future<dynamic> importItem() async {
    dynamic result = await _channel.invokeMethod('importItem');
    if (result is String) {
      return jsonDecode(result);
    }
    return null;
  }
}
