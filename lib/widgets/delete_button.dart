import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.black,
      ),
      onPressed: () => Navigator.of(context).pop(true),
      child: const Text("delete").tr(),
    );
  }
}
