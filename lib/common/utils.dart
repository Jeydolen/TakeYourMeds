import 'package:flutter/material.dart';

class Utils {
  static Future<bool?> dialogBuilder(BuildContext context, AlertDialog dialog) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }
}
