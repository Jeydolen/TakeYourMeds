import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:take_your_meds/common/database.dart';

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
            Flexible(child: const Text("no_meds").tr()),
            ElevatedButton(onPressed: addMed, child: const Icon(Icons.add))
          ],
        ),
      );

  void reorderList(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final dynamic item = json.removeAt(oldIndex);
    json.insert(newIndex, item);
    setState(() {});
    FileHandler.writeContent("meds", jsonEncode(json));
  }

  void removeMed(element) async {
    await DatabaseHandler().delete("meds", "uid = ?", [element["uid"]]);

    if (mounted) {
      setState(() {
        json.remove(element);
        if (json.isEmpty) {
          edit = false;
        }
      });
    }
  }

  void showMed(Map<String, dynamic> json) {
    Navigator.pushNamed(
      context,
      "/med_presentation",
      arguments: json,
    );
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
    Map<String, dynamic> updatedEl = Map.from(element);

    updatedEl["favorite"] = element["favorite"] == 0 ? 1 : 0;

    DatabaseHandler().update(
      "meds",
      updatedEl,
      where: "uid = ?",
      whereArgs: [element["uid"]],
    );

    if (mounted) {
      setState(() {
        json[json.indexOf(element)] = updatedEl;
      });
    }
  }

  List<Widget> generateElements(List<dynamic> json, Function onClick) {
    return json.map((element) {
      Color backgroundColor = element["color"] is int && element["color"] != -1
          ? Color(element["color"])
          : Theme.of(context).canvasColor;

      Color foregroundColor =
          backgroundColor.computeLuminance() > .5 ? Colors.black : Colors.white;

      ButtonStyle btnStyle =
          TextButton.styleFrom(foregroundColor: foregroundColor);

      return ListTile(
        tileColor: backgroundColor,
        contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        key: UniqueKey(),
        title: TextButton(
          style: btnStyle,
          onPressed: () => edit ? {} : onClick(element),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(element["name"]),
              Text(element["dose"].toString()),
              Text(element["unit"]).tr(),
              TextButton(
                style: btnStyle,
                onPressed: () => updateFavorite(element),
                child: element["favorite"] == 1
                    ? const Icon(Icons.star)
                    : const Icon(Icons.star_outline),
              )
            ],
          ),
        ),
        trailing: TextButton(
          style: btnStyle,
          child: Icon(
            edit ? Icons.delete : Icons.drag_handle,
            color: foregroundColor,
          ),
          onPressed: () => edit ? onClick(element) : {},
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    json = List.from(widget.json);
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
