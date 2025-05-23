import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> writeContent(String fileName, String textContent) async {
    final File file = File(join(await localPath, fileName));
    return file.writeAsString(textContent);
  }

  static Future<File> saveToPath(String fullPath, String content) async {
    return File(fullPath).create().then((file) => file.writeAsString(content));
    // return;
  }

  static Future<String?> readContent(String fileName) async {
    try {
      final File file = File(join(await localPath, fileName));
      // Read the file
      return file.readAsStringSync();
    } catch (e) {
      // If there is an error reading, return null
      return null;
    }
  }

  static void removeDocument(String fileName) async {
    final File file = File(join(await localPath, fileName));
    file.delete();
  }
}
