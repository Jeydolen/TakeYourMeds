import 'package:flutter/material.dart';

import 'package:take_your_meds/common/database.dart';
import 'package:take_your_meds/widgets/meds_list.dart';

class TookMedPage extends StatefulWidget {
  const TookMedPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TookMedPageState();
}

class TookMedPageState extends State<TookMedPage> {
  List<dynamic>? meds;

  @override
  void initState() {
    super.initState();
    getMeds();
  }

  void getMeds() async {
    List meds = await DatabaseHandler().selectAll("meds");
    setState(() {
      this.meds = meds;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (meds == null) {
      return const CircularProgressIndicator();
    }

    return MedsList(json: meds ?? []);
  }
}
