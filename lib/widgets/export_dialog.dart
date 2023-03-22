import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/enums/supported_formats.dart';
import 'package:take_your_meds/widgets/cancel_button.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({
    super.key,
    required this.doShare,
    required this.changeMoodExport,
  });

  final bool doShare;
  final Function changeMoodExport;

  @override
  State<StatefulWidget> createState() => ExportDialogState();
}

class ExportDialogState extends State<ExportDialog> {
  bool addMoods = true;

  void switchAddMoods(_) {
    setState(() {
      addMoods = _!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("export_summary").tr(),
      content: const Text("select_format").tr(
        args: [
          widget.doShare ? "share".tr() : "export".tr(),
        ],
      ),
      actions: [
        CheckboxListTile(
          title: const Text("summary_contains_mood").tr(),
          value: addMoods,
          onChanged: (_) {
            widget.changeMoodExport();
            switchAddMoods(_);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CancelButton(),
            Row(
              children: SupportedFormats.values
                  .map(
                    (e) => ElevatedButton(
                      child: Text(e.name.toUpperCase()),
                      onPressed: () => Navigator.of(context).pop(e.index),
                    ),
                  )
                  .toList(),
            )
          ],
        )
      ],
    );
  }
}
