import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:take_your_meds/common/file_handler.dart';

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
            const Text("no_meds").tr(),
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
      actions: <Widget>[
        TextButton(
          child: const Text("cancel").tr(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          child: const Text("delete").tr(),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    bool? doRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => dialog,
    );

    if (doRemove == true) {
      removeMed(element);
    }
  }

  List<Widget> generateElements(List<dynamic> json, Function onClick) {
    return json
        .map((element) => ListTile(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              key: UniqueKey(),
              title: TextButton(
                onPressed: () => edit ? {} : onClick(element),
                child: Row(
                  children: [
                    // TODO: Better space splitting between categories
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Text(element["name"]),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 10,
                      child: Text(element["dose"]),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      child: Text(element["unit"]),
                    ),
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
