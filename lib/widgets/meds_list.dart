import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:take_your_meds/common/utils.dart';

import '../common/file_handler.dart';

class MedsList extends StatefulWidget {
  late List<dynamic> json;
  MedsList({Key? key, required this.json}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MedsListState();
}

class MedsListState extends State<MedsList> {
  bool edit = false;

  Widget emptyList() => Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No data available, you can add meds here:"),
            ElevatedButton(onPressed: addMed, child: Icon(Icons.add))
          ],
        ),
      );

  void reorderList(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final dynamic item = widget.json.removeAt(oldIndex);
      widget.json.insert(newIndex, item);
    });
    FileHandler.writeContent("meds", jsonEncode(widget.json));
  }

  void removeMed(element) {
    setState(() {
      widget.json.remove(element);
      if (widget.json.isEmpty) {
        edit = false;
      }
    });
    FileHandler.writeContent("meds", jsonEncode(widget.json));
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
      widget.json = result;
    });
  }

  void editList() {
    if (widget.json.isEmpty) {
      return;
    }
    setState(() {
      edit = !edit;
    });
  }

  void removeMedDialog(dynamic element) async {
    AlertDialog dialog = AlertDialog(
      title: Text('Do you really want to remove:  ${element["name"]} ?'),
      content: const Text(
          'If you really want to delete this medication, press Delete otherwise press Cancel.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
              primary: Colors.white, backgroundColor: Colors.red),
          child: const Text('Delete'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );

    bool? doRemove = await Utils.dialogBuilder(context, dialog);

    if (doRemove == true) {
      removeMed(element);
    }
  }

  List<Widget> generateElements(
      List<dynamic> json, Function onClick, bool edit) {
    return json.map((element) {
      return ListTile(
        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        key: UniqueKey(),
        title: TextButton(
          onPressed: () => edit ? {} : onClick(element),
          child: Row(
            children: [
              SizedBox(
                child: Text(element["name"]),
                width: MediaQuery.of(context).size.width / 2.2,
              ),
              SizedBox(
                child: Text(element["dose"]),
                width: MediaQuery.of(context).size.width / 5,
              ),
              SizedBox(
                child: Text(element["unit"]),
                width: 20,
              ),
            ],
          ),
        ),
        trailing: TextButton(
          style: TextButton.styleFrom(
              primary: edit ? Colors.red : null, padding: EdgeInsets.all(0)),
          child: Icon(edit ? Icons.delete : Icons.drag_handle),
          onPressed: () => edit ? onClick(element) : {},
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Took medication"),
        actions: [
          ElevatedButton(
            onPressed: editList,
            child: Icon(edit ? Icons.cancel : Icons.edit),
          )
        ],
      ),
      body: widget.json.isEmpty
          ? emptyList()
          : ReorderableListView(
              children: generateElements(
                  widget.json, edit ? removeMedDialog : showMed, edit),
              onReorder: reorderList,
            ),
    );
  }
}
