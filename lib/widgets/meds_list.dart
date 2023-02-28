import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/widgets/cancel_button.dart';
import 'package:take_your_meds/widgets/delete_button.dart';

class MedsList extends StatefulWidget {
  const MedsList({Key? key, required this.json}) : super(key: key);
  final List<dynamic> json;

  @override
  State<StatefulWidget> createState() => MedsListState();
}

class MedsListState extends State<MedsList> {
  bool edit = false;
  late List<dynamic> json;

  Widget emptyList() => Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: const Text("no_meds").tr(),
            ),
            ElevatedButton(onPressed: addMed, child: const Icon(Icons.add))
          ],
        ),
      );

  void reorderList(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final dynamic item = json.removeAt(oldIndex);
      json.insert(newIndex, item);
    });
    FileHandler.writeContent("meds", jsonEncode(json));
  }

  void removeMed(element) {
    setState(() {
      json.remove(element);
      if (json.isEmpty) {
        edit = false;
      }
    });
    FileHandler.writeContent("meds", jsonEncode(json));
  }

  void showMed(Map<String, dynamic> json) {
    Navigator.pushNamed(context, "/med_presentation", arguments: json);
  }

  void addMed() async {
    dynamic result = await Navigator.pushNamed(context, "/add_med");
    if (result == null) {
      return;
    }
    setState(() {
      json = result;
    });
  }

  void editList() {
    if (json.isEmpty) {
      return;
    }
    setState(() {
      edit = !edit;
    });
  }

  void removeMedDialog(dynamic element) async {
    AlertDialog dialog = AlertDialog(
      title: const Text("del_med_title").tr(args: [element["name"]]),
      content: const Text("del_med").tr(),
      actions: const <Widget>[CancelButton(), DeleteButton()],
    );

    bool? doRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => dialog,
    );

    if (doRemove == true) {
      removeMed(element);
    }
  }

  void updateFavorite(Map<String, dynamic> element) async {
    if (!edit) {
      return;
    }

    element["favorite"] =
        element["favorite"] is! bool ? true : !element["favorite"];

    setState(() {
      json[json.indexOf(element)] = element;
    });

    FileHandler.writeContent("meds", jsonEncode(json));
  }

  List<Widget> generateElements(List<dynamic> json, Function onClick) {
    return json
        .map((element) => ListTile(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              key: UniqueKey(),
              title: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      element["color"] is int ? Color(element["color"]) : null,
                ),
                onPressed: () => edit ? {} : onClick(element),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(element["name"]),
                    Text(element["dose"]),
                    Text(element["unit"]).tr(),
                    edit == true
                        ? TextButton(
                            onPressed: () => updateFavorite(element),
                            child: element["favorite"] == true
                                ? const Icon(Icons.star)
                                : const Icon(Icons.star_outline),
                          )
                        : element["favorite"] == true
                            ? const Icon(Icons.star)
                            : const Icon(Icons.star_outline)
                  ],
                ),
              ),
              trailing: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: edit ? Colors.red : null,
                  padding: const EdgeInsets.all(0),
                ),
                child: Icon(edit ? Icons.delete : Icons.drag_handle),
                onPressed: () => edit ? onClick(element) : {},
              ),
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    json = widget.json;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("took_med_general").tr(),
        actions: [
          ElevatedButton(
            onPressed: editList,
            child: Icon(edit ? Icons.cancel : Icons.edit),
          )
        ],
      ),
      body: json.isEmpty
          ? emptyList()
          : ReorderableListView(
              onReorder: reorderList,
              children: generateElements(
                json,
                edit ? removeMedDialog : showMed,
              ),
            ),
    );
  }
}
