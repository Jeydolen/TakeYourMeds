import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) => TextButton(
        child: const Text("cancel").tr(),
        onPressed: () => Navigator.of(context).pop(),
      );
}
